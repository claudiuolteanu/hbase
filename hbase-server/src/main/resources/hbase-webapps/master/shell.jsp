<%--
/**
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
--%>
<%@ page contentType="text/html;charset=UTF-8"
  import="org.apache.hadoop.hbase.master.HMaster" 
  import="org.apache.hadoop.hbase.rest.TableResource"
  import="org.apache.hadoop.hbase.rest.VersionResource"
  import="org.apache.hadoop.hbase.client.HBaseAdmin"
  import="org.apache.hadoop.hbase.client.HConnectionManager"
  import="org.apache.hadoop.conf.Configuration"
  import="org.w3c.dom.*"
  import="java.io.File"
  import="javax.xml.parsers.*"%>
<%
HMaster master = (HMaster)getServletContext().getAttribute(HMaster.MASTER);
Configuration conf = master.getConfiguration();
HBaseAdmin hbadmin = new HBaseAdmin(conf); 
TableResource tableR = new TableResource("tableResource");
int enabled = 1;

try {
  String hbaseHome = System.getenv("HBASE_HOME");
  String filename = hbaseHome + "/conf/hbase-site.xml";
  File file = new File(filename);
  DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
  DocumentBuilder builder = factory.newDocumentBuilder();
  Document doc = builder.parse(file);
  doc.getDocumentElement().normalize();
  NodeList list = doc.getElementsByTagName("property");
      
  for(int i = 0; i < list.getLength(); i++) {
    Node node1 = list.item(i);
	if (node1.getNodeType() == Node.ELEMENT_NODE) {
      Element element = (Element) node1;
      NodeList firstNodeElementList = element.getElementsByTagName("name");
      Element element1 = (Element) firstNodeElementList.item(0);
      NodeList firstNodeList = element1.getChildNodes();
      String xname = ((Node) firstNodeList.item(0)).getNodeValue();
      if(xname.compareTo("hbase.webshell") == 0) {
        NodeList lastNodeElementList = element.getElementsByTagName("value");
        Element element2 = (Element) lastNodeElementList.item(0);
        NodeList lastNodeList = element2.getChildNodes();
        String xvalue = ((Node) lastNodeList.item(0)).getNodeValue();
          if(xvalue.compareTo("true") == 0) {
		    enabled = 0;
		  }
        }
      }

  }
} catch(Exception e) { 
  enabled = -1;  
}
%>  
<?xml version="1.0" encoding="UTF-8" ?>

<html lang="en">
<head>
<meta charset="utf-8">
  <title>HBase Master: <%= master.getServerName() %></title>
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <meta name="description" content="">
  <meta name="author" content="">


  <link href="/static/css/bootstrap.css" rel="stylesheet">
  <link href="/static/css/hbase.css" rel="stylesheet">
  <link href="/static/css/bootstrap-responsive.css" rel="stylesheet">
  <!--[if lt IE 9]>
    <script src="http://html5shim.googlecode.com/svn/trunk/html5.js"></script>
  <![endif]-->

<script language="JavaScript" type="text/javascript" src="termlib.js"></script>

<script language="JavaScript" type="text/javascript">
  var changed=false;
  var access=true; 
  var lines = 2;
  var helpPage="HBase Shell; type 'help<RETURN>' for list of supported commands.\nType 'resize x y' to resize the terminal (x - cols number; y - rows number).\nType 'stop shell' to stop acces to shell.Type 'start shell' to start acces to shell\n\n";
  var output=helpPage;
  var conf= {
            x: 100,
            y: 100,
            cols: 92,
            rows: 24,
            greeting: helpPage,
            crsrBlinkMode: true,
            handler: termHandler,
            timeout: 100000,
            frameWidth: 1
  }
  var term = new Terminal(conf);

  function termOpen() {
    term.open();
  }
  
  function termHandler() {
    this.newLine();
    var line = this.lineBuffer;
    if (line == 'clear' && access == true) {
      this.clear();
      lines = 2;
      this.resizeTo(92,24);
      this.write(helpPage);
      output = helpPage;
    }
    else if (line.substring(0,6) == 'resize' && access == true) {
	  if(line[6] != " ") {
        this.write("You should type 'resize x y' if you want to resize the terminal.\n");
	  } else {
	    var linesplit = line.split(" ");
	    if(linesplit.length != 3) {
	      this.write("Wrong number of parameters! The correct format is 'resize x y'.\n");
	    } else {
		  var x = parseInt(linesplit[1], 10);
	      var y = parseInt(linesplit[2], 10);
	      this.resizeTo(x,y);
	      //this.write(helpPage);
	      output += "\n> ";
	      output += line;
	      lines = output.split("\n").length;
	      this.write(output);
	    }
	  }	  
	}
	else if (line == 'stop shell') {
	  access = false;
	  output+="\n> stop shell\n";
	  output+="Shell access stopped\n";
	  printout(output);
	}
	else if (line == 'start shell') {
	  access = true;
	  output+="\n>start shell\n";
	  output+="Shell access started\n";
	  printout(output);
	}
    else if (line != "" && access == true) {
      var command = encodeURIComponent(line);
      var myUrl = "http://localhost:60010/shellendpoint?" + command;
      output+="> "+line+"\n";
      this.send(
        {
          url: myUrl,
          method: 'get',
          callback: mySocketCallback,
        }
      );
     return;
    }
    else if(access == false) {
	  output+="> "+line+"\n";
	  output+="You don't have access!\n";
	  printout(output);
	}
    else { 
      output+="\nType 'help<RETURN>' for help\n";
      printout(output);
	}
		
    this.prompt();
  }
  
  function mySocketCallback() {
    var response=this.socket;
    if (response.succes) {
      // status 200 OK
      this.write(response.responseText);
    }
    else if (response.errno) {
     // connection failed
     this.write("Connection error: " + response.errstring);
    }
    else {
     // connection succeeded, but server returned other status than 2xx
      output += response.responseText;
      printout(output);
    }
    this.prompt();
  }
 
function printout(result) {
  lines = result.split("\n").length;
  if (term.maxLines < (lines + 10))
    term.maxLines = lines + 10;
  term.resizeTo(92, term.maxLines); 
  term.write(result);
  var elem = document.getElementById('termDiv');
  elem.scrollTop = elem.scrollHeight;
} 
</script>

<style type="text/css">
/* essential terminal styles */
.term {
  font-family: courier,fixed,monospace;
  font-size: 14px;
  color: #000000;
  background: none;
}
.termReverse {
  color: #FFFFFF;
  background: #000000;
}

div.scroll {
  width:750px;
  height:390px;
  overflow-x:hidden;
  overflow-y:auto;
}
</style>

</head>
<body>
    <div class="navbar navbar-fixed-top">
      <div class="navbar-inner">
        <div class="container">
          <a class="btn btn-navbar" data-toggle="collapse" data-target=".nav-collapse">
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
            <span class="icon-bar"></span>
          </a>
          <a class="brand" href="/master-status">HBase Master</a>
          <div class="nav-collapse">
            <ul class="nav">
                <li><a href="/master-status">Home</a></li>
                <li><a href="/tablesDetailed.jsp">Table Details</a></li>
                <li><a href="/logs/">Local logs</a></li>
                <li><a href="/stacks">Thread Dump</a></li>
                <li><a href="/logLevel">Log Level</a></li>
                <li><a href="/dump">Debug dump</a></li>
                <li class="active"><a href="/shell.jsp">Shell</a></li>
            </ul>
          </div><!--/.nav-collapse -->
        </div>
      </div>
    </div>

    <div class="container">
    <div class="row inner_header">
        <div class="span8">
            <h1>HBase Shell</h1>
        </div>
        <div class="span4 logo">
            <img src="/static/hbase_logo.png" height="66" width="266" alt="HBase logo"/>
        </div>
    </div>
    </div>

  <div class="scroll" id="termDiv" style="position: absolute; visibility: hidden; z-index: 1;"></div>
  <% if(enabled == 0) {
    %>
  <script language="JavaScript" type="text/javascript">
	  termOpen();
  </script>
  <% } else if(enabled == -1) {
    %>
    <div class="container">
    <div class="row inner_header">
      <div class="span8">
        <h3>
           ERROR! Couldn't open file <code>$HBASE_HOME/conf/hbase-site.xml</code>.
         </h3>
      </div>
    </div>
    </div>
  <% } else {
	%>
	<div class="container">
	<div class="row inner_header">
	<div class="span8">
       <h4>
         Sorry! The shell has been disabled!<br/> 
         If you want to enable it edit <code class="filename">$HBASE_HOME/conf/hbase-site.xml</code> 
         and set <code>hbase.webshell</code> to <code>true</code>.<br/><br/>
         Example : 
		<pre class="programlisting">
  &lt;?xml version="1.0"?&gt;
  &lt;?xml-stylesheet type="text/xsl" href="configuration.xsl"?&gt;
  &lt;configuration&gt;
    &lt;property&gt;
      &lt;name&gt;hbase.webshell&lt;/name&gt;
      &lt;value&gt;true
    &lt;/property&gt;
  &lt;/configuration&gt;
      </pre>
       </h4>
    </div>
    </div>
    </div>
  <%
    }
    %>	  
</body>
</html>



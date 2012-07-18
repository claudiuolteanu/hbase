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
  import="org.apache.hadoop.conf.Configuration"%>
<%
HMaster master = (HMaster)getServletContext().getAttribute(HMaster.MASTER);
Configuration conf = master.getConfiguration();
HBaseAdmin hbadmin = new HBaseAdmin(conf); 
TableResource tableR = new TableResource("tableResource"); 
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
  var helpPage="HBase Shell; type 'help<RETURN>' for list of supported commands.\nType 'exit<RETURN>' to leave the HBase Shell";
  var conf= {
            x: 100,
            y: 100,
            cols: 85,
            rows: 50,
            greeting: helpPage,
            crsrBlinkMode: true,
            handler: termHandler,
            timeout: 50000,
            frameWidth: 1
  }
  var term = new Terminal(conf);

  function termOpen() {
    term.open();
  }
  
  function termHandler() {
    this.newLine();
    var line = this.lineBuffer;
    if (line == 'clear') {
      this.clear();
      this.write(helpPage);
    }
    else if (line != "") {
      var command = encodeURIComponent(line);
      var myUrl = "http://localhost:60010/shell?" + command;
      this.send(
        {
          url: myUrl,
          method: 'get',
          callback: mySocketCallback,
        }
      );
     return;
    }
    else 
      this.write("Type 'help<RETURN>' for help");
		
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
     this.write(response.responseText);
    }
       
    this.prompt();
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

  <div id="termDiv" style="position: absolute; visibility: hidden; z-index: 1;"></div>
  <script language="JavaScript" type="text/javascript">
	termOpen();
  </script>

</body>
</html>



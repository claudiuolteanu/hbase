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
  import="org.apache.hadoop.hbase.HBaseConfiguration"
  import="org.apache.hadoop.conf.Configuration"
  import="org.apache.hadoop.hbase.util.HBaseFsck"
  import="java.io.ByteArrayOutputStream"
  import="java.io.PrintStream"
  import="org.apache.hadoop.fs.Path"
  import="org.apache.hadoop.hbase.HConstants"
  import="java.net.URI"
  import="org.apache.hadoop.hbase.ClusterStatus"
  import="java.io.InputStream"%>
<%
HMaster master = (HMaster)getServletContext().getAttribute(HMaster.MASTER);
Configuration conf = master.getConfiguration();
Path hbasedir = new Path(conf.get(HConstants.HBASE_DIR));
URI defaultFs = hbasedir.getFileSystem(conf).getUri();
conf.set("fs.defaultFS", defaultFs.toString());     // for hadoop 0.21+
conf.set("fs.default.name", defaultFs.toString());  // for hadoop 0.20
HBaseFsck fsck = new HBaseFsck(conf);
long sleepBeforeRerun = fsck.DEFAULT_SLEEP_BEFORE_RERUN;
fsck.setDisplayFullReport();
//fsck.connect();
//int code = fsck.onlineHbck();
HBaseAdmin admin = new HBaseAdmin(conf);
ClusterStatus status = admin.getClusterStatus();
String version = status.getHBaseVersion();
out.println(version);

ByteArrayOutputStream baos = new ByteArrayOutputStream();
PrintStream ps = new PrintStream(baos);
// Save the old System.out!
PrintStream old = System.out;
// Tell Java to use your special stream
System.setOut(ps);
// capture the output
Process proc = Runtime.getRuntime().exec("/home/claudiu/Documents/hbase/bin/hbase hbck -details");
InputStream input = proc.getInputStream();
System.out.println(input.toString());

 String rez = "";
 int i,nl;
 nl = 0;
while((i = input.read()) != -1) {
  char c = (char)i;
  rez += c;
  if(i == 10)
   nl++;
}
//out.println(rez);
//out.println("\nNEW LINES: " + nl);
//Runtime.getRuntime().exit(code);
// Put things back
System.out.flush();
System.setOut(old);
// Show what happened
out.println(baos.toString());
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
            <h1>Cluster informations</h1>
            <pre><%= rez %></pre>
        </div>
        <div class="span4 logo">
            <img src="/static/hbase_logo.png" height="66" width="266" alt="HBase logo"/>
        </div>
    </div>
    </div>
</body>
</html>



/**
 * Copyright 2011 The Apache Software Foundation
 *
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
package org.apache.hadoop.hbase.master;

import java.io.InputStream;
import java.io.IOException;
import java.io.PrintWriter;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServlet;

public class RunHbckServlet extends HttpServlet {
 
  
  private String getClusterInfo() 
  {	
    String clusterOutput = "";

    String hbaseHome = System.getenv("HBASE_HOME");
    
    if(hbaseHome == null)
      return "HBASE_HOME is not defined!";
    
    try {
      String hbckScript = hbaseHome + "/bin/hbase hbck -details";
      Process proc = Runtime.getRuntime().exec(hbckScript);
      InputStream input = proc.getInputStream();
  
      int i;
      while((i = input.read()) != -1) {
        char c = (char)i;
        clusterOutput += c;
      }
      proc.destroy();
    } catch (IOException e) {
	  clusterOutput = "Failed running 'hbase hbck -details'";
	}
    
    return clusterOutput;
  }

  public void doGet(HttpServletRequest request, HttpServletResponse response)
    throws IOException {
		
    response.setContentType("text/plain");
    response.setHeader("Access-Control-Allow-Origin", "*");

    request.getSession().setMaxInactiveInterval(30*60);

    String output = "";
  
    output = getClusterInfo();	   
    PrintWriter out = response.getWriter();
    out.println(output);
  }
  
}


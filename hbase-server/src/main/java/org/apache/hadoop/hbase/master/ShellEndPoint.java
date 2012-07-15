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

import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.io.Reader;
import java.lang.String;
import java.net.URLDecoder;
import java.util.Date;
import java.util.Map;
import java.util.NavigableMap;
import org.jruby.embed.PathType;

import javax.script.ScriptContext;
import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;
import javax.script.Invocable;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServlet;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import org.jruby.embed.ScriptingContainer;

public class ShellEndPoint extends HttpServlet {
  private final static String jrubyhome = "/usr/lib/jruby/";
  private String rubySources;
  private String hirbSource;
  private String myEngine;
  private boolean loaded = false;
	
  private void loadPaths() {
    String userDir;
		
    userDir = System.getProperty("user.dir");
    rubySources = userDir + "/../hbase-server/src/main/ruby";
    hirbSource = userDir + "/hirb.rb";
    myEngine = rubySources + "/engine.rb";
		
    System.setProperty("jruby.home", jrubyhome);
    System.setProperty("org.jruby.embed.class.path", rubySources+":"+hirbSource);
    System.setProperty("hbase.ruby.sources", rubySources+":"+hirbSource);
  }
  
  private String commandResponse(String command) 
    throws FileNotFoundException
  {	
    String response;
    final Log LOG = LogFactory.getLog(ShellEndPoint.class.getName());
    
    loadPaths();
    
    ScriptEngineManager manager = new ScriptEngineManager();
    ScriptEngine engine = manager.getEngineByName("jruby");
    ScriptingContainer container = new ScriptingContainer();

    Reader reader = new FileReader(myEngine);
    
    try {
      engine.eval(new FileReader(hirbSource));
      Object receiver = engine.eval(reader);
      Object ob = container.callMethod(receiver,"run_code",command);
      response = ob.toString();
    } catch(ScriptException e) {
      LOG.debug(e.getMessage());
      response ="ERROR";
	}
	  
    return response;
  }

  public void doGet(HttpServletRequest request, HttpServletResponse response)
    throws IOException {

    response.setContentType("text/plain");
    response.setHeader("Access-Control-Allow-Origin", "*");

    String commandEncoded = request.getQueryString();
    String commandDecoded = URLDecoder.decode(commandEncoded, "UTF-8");
    String command = "";
    String output = "";
	
    //extrag comanda din URL
    int i = 0;	
    while(commandDecoded.substring(i,i + 15)
						.compareTo("&_termlib_reqid") != 0) {
      command += commandDecoded.charAt(i++);
    }
    output = commandResponse(command);	   
    PrintWriter out = response.getWriter();
    out.println(output);
  }  
}


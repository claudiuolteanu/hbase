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

import java.io.IOException;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileReader;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.io.Reader;
import java.lang.String;
import java.net.URLDecoder;
import java.util.concurrent.*;

import javax.script.ScriptContext;
import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpServlet;

import org.apache.commons.logging.Log;
import org.apache.commons.logging.LogFactory;

import org.jruby.embed.PathType;
import org.jruby.embed.ScriptingContainer;

public class ShellEndPoint extends HttpServlet {
  private static String jrubyHome;
  private String rubySources;
  private String hirbSource;
  private String myEngine;
  private boolean loaded = false;
  private Object myReceiver;
  private static int TIMEOUT = 6;
  
  private int loadPaths() {
    
    //define path for ruby sources
    String hbaseHome = System.getenv("HBASE_HOME");
    
    if(hbaseHome != null) {
	  rubySources = hbaseHome + "/hbase-server/src/main/ruby";
      hirbSource = hbaseHome + "/bin/hirb.rb";
      myEngine = rubySources + "/engine.rb";
	} else {
      String userDir;
		
      userDir = System.getProperty("user.dir");
      rubySources = userDir + "/../hbase-server/src/main/ruby";
      hirbSource = userDir + "/hirb.rb";
      myEngine = rubySources + "/engine.rb";
    }
	
	//check if jruby is installed
	File file=new File("/usr/lib/jruby/");
    boolean exists = file.exists();
    if(exists) {
	  jrubyHome = "/usr/lib/jruby/";
	} else {
	  jrubyHome = System.getenv("JRUBY_HOME");
	}
	
	if(jrubyHome != null) {	
      System.setProperty("jruby.home", jrubyHome);
      System.setProperty("org.jruby.embed.class.path", rubySources+":"+hirbSource);
      System.setProperty("hbase.ruby.sources", rubySources+":"+hirbSource);
      return 0;
    } else {
	  return 1;
	}
  }
  
  private String commandResponse(String command) 
    throws FileNotFoundException, IOException
  {	
    final StringBuffer response = new StringBuffer();
    Object ob;
    Reader reader = null;
    int checked;
    final Log LOG = LogFactory.getLog(ShellEndPoint.class.getName());
    final String commandFinal = command;
    
    checked = loadPaths();
    if(checked == 1) {
	  final String warning = "Warning! Please verify if jruby is installed in '/usr/lib/jruby', or set your JRUBY_HOME path!";
	  return warning;
	}
    
    ScriptEngineManager manager = new ScriptEngineManager();
    ScriptEngine engine = manager.getEngineByName("jruby");
    ScriptingContainer container = new ScriptingContainer();
    final ScriptingContainer containerFinal = container;
    
    if(!loaded) {
      try {
	    reader = new FileReader(myEngine);
	    myReceiver = engine.eval(reader);
      } catch (ScriptException e) {
        LOG.debug(e.getMessage());
	    response.append(e.toString());
	  }
	  loaded = true;
    }
    
    
    Runnable r = new Runnable() {
      public void run() {
          final String responseFinal = containerFinal.callMethod(myReceiver,
                                    "run_code",commandFinal).toString();
          response.append(responseFinal);
      }
    };
    
    BlockingQueue<Runnable> queue = new ArrayBlockingQueue<Runnable>(100, true);
    ThreadPoolExecutor executor = new ThreadPoolExecutor(10, 20, TIMEOUT, 
                                                 TimeUnit.SECONDS, queue);
     
    final Future<?> f = executor.submit(r);
    try {
        final Object result = f.get( TIMEOUT, TimeUnit.SECONDS );
    }
    catch ( InterruptedException e ) {
        response.append( "\nJava: Interrupted while waiting for script...\n" );
        LOG.debug(e.getMessage());
    }
    catch ( ExecutionException e ) {
        response.append( "\nJava: Script threw exception: " + e.getMessage() +"\n" );
        LOG.debug(e.getMessage());
    }
    catch ( TimeoutException e ) {
        response.append( "Java: Timeout! trying to future.cancel()..." );
        LOG.debug(e.getMessage());
        boolean failed = f.cancel( true );
        executor.shutdown();
    } 
    
    if(!executor.isShutdown())
      executor.shutdown();
    
    return response.toString();
  }

  public void doGet(HttpServletRequest request, HttpServletResponse response)
    throws IOException {

    response.setContentType("text/plain");
    response.setHeader("Access-Control-Allow-Origin", "*");

    request.getSession().setMaxInactiveInterval(30*60);
    
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


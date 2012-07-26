/* ===================================================
 * bootstrap-transition.js v2.0.4
 * http://twitter.github.com/bootstrap/javascript.html#transitions
 * ===================================================
 * Copyright 2012 Twitter, Inc.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 * ========================================================== */
 
function runHbckFunction(){
  var ajaxRequest;  // The variable that makes Ajax possible!
  	
  try {
    // Opera 8.0+, Firefox, Safari
    ajaxRequest = new XMLHttpRequest();
  } catch (e){
    // Internet Explorer Browsers
    try {
      ajaxRequest = new ActiveXObject("Msxml2.XMLHTTP");
    } catch (e) {
      try {
        ajaxRequest = new ActiveXObject("Microsoft.XMLHTTP");
      } catch (e) {
		// Something went wrong
        alert("Your browser broke!");
        return false;
      }
    }
  }
  
  // Create a function that will receive data sent from the server
  ajaxRequest.onreadystatechange = function() {
    if(ajaxRequest.readyState == 4) {
      document.getElementById('runHbckId').innerHTML = ajaxRequest.responseText;
    }
  }
  
  ajaxRequest.open("GET", "http://localhost:60010/run-hbck", true);
  ajaxRequest.send(null); 
}

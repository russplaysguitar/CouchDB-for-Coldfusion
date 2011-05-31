<!--- --------------------------------------------------------------------------------------- ----
	
Copyright (c) 2009, Russell Spivey (http://cfruss.blogspot.com)
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of the project nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	
---- --------------------------------------------------------------------------------------- --->

<!--- PROJECT HOMEPAGE: http://couchdb.riaforge.org/ --->

<!--- READ ME: 
		This file is for testing purposes only. This file is not intended for use in production environments.

		Before you can use this file you must: 
		1. Install CouchDB
		2. Create a database in CouchDB (you may use the utility client @ http://localhost:5984/_utils/ to to do)
		3. Set the db_name in document.cfc or use init(db_name)
		4. You must allow HTTP PUT and DELETE operations (in your web server settings)
	--->	
	
<!--- quick links: 
	CouchDB Document API documentation: http://wiki.apache.org/couchdb/HTTP_Document_API
	local couchdb admin: http://localhost:5984/_utils/
	Start couchdb in linux terminal: sudo /etc/init.d/couchdb start
--->

<!--- TODOs: 
	- improve error handler to include all possible errors
	- make copy method work with username and password
	--->

<!--- design notes:
	This CFC has been constructed in such a way to allow the greatest flexibility when manipulating it.
	If you make modifications, please follow the design pattern already in use:
		* Document properties are available publicly (with the "this." scope)
		* Arguments of public methods default to the object properties of same name
		* Values passed to public methods are set as object properties before method processing begins
	Please comment your code, use descriptive variable names, and use the hints attribute for methods and arguments.
--->

<cfcomponent hint="This CFC allows access to CouchDB documents. You may use it as an object or run cfinvoke on individual methods.">
	
	<!--- private variables --->
	<!--- couch+database connection parameters --->
	<cfmodule template="connection_defaults.cfm" result="conn">
	<cfset variables.db_name = conn.db_name>
	<cfset variables.couch_port = conn.couch_port>
	<cfset variables.couch_host = conn.couch_host>
	<cfset variables.couch_url = conn.couch_url>
	<cfset variables.couch_username = conn.couch_username>
	<cfset variables.couch_password = conn.couch_password>
	
	<!--- public variables --->
	<cfset this.id = ''>
	<cfset this.revision = ''>
	<cfset this.content_type = 'application/json'>
	<cfset this.data = ''>
	
	
	<!--- init --->
	<cffunction name="init" access="public" returntype="Any"
				hint="Initializes this CFC. Returns this object.">
		<cfargument name="db_name" type="String" required="true" hint="Database name.">
		<cfargument name="couch_port" type="String" required="false" default="#variables.couch_port#" hint="CouchDB port.">
		<cfargument name="couch_host" type="String" required="false" default="#variables.couch_host#" hint="CouchDB host.">
		<cfargument name="couch_username" type="string" required="false" default="#variables.couch_username#" hint="Your CouchDB username">
		<cfargument name="couch_password" type="string" required="false" default="#variables.couch_password#" hint="Your CouchDB password">		

		<!--- map arguments to private variables --->
		<cfset variables.db_name = arguments.db_name>
		<cfset variables.couch_host = arguments.couch_host>
		<cfset variables.couch_port = arguments.couch_port>
		<cfset variables.couch_url = 'http://#variables.couch_host#'>
		<cfset variables.couch_username = arguments.couch_username>
		<cfset variables.couch_password = arguments.couch_password>

		<cfreturn this />
	</cffunction>
	
	
	<!--- validate object --->
	<!--- TODO: since this really just validates the database settings, i'd like to move this to the future database API wrapper
				and call it only once from onApplicationStart. --->
	<cffunction name="validateObject" access="private" returntype="void" hint="Validates this object.">
		
		<cfset var cfhttp = ''>
		
		<!--- is database set? --->
		<cfif variables.db_name is ''>
			<cfthrow message="Database not yet set. Call init('my_database_name') before using this CFC.">
		</cfif>
		
		<!--- try connecting to CouchDB --->
		<!--- (note: it needs a / at the end of the url. weird?) --->
		<cfhttp url="#variables.couch_url#/" port="#variables.couch_port#" method="GET" username="#variables.couch_username#" password="#variables.couch_password#" />
	
		<!--- could not connect to CouchDB --->
		<cfif cfhttp.statusCode contains 'Connection Failure'>
			<cfthrow message="Could not connect to CouchDB. CouchDB was not found at: #variables.couch_url#:#variables.couch_port#">
		</cfif>
		
		<!--- try connecting to database --->
		<cfhttp url="#variables.couch_url#/#variables.db_name#" port="#variables.couch_port#" method="GET" username="#variables.couch_username#" password="#variables.couch_password#" />

		<!--- handle CouchDB errors --->
		<cfif cfhttp.statuscode neq '200 OK'>
			<cfset errorHandler("database", cfhttp)>
		</cfif>
		
		<cfreturn />
	</cffunction>


	<!--- load --->
	<cffunction name="load" access="public" returntype="String" hint="Loads existing document data into This object. Returns document data." >
		<cfargument name="id" type="String" required="true" default="#this.id#" hint="Document ID." />
		<cfargument name="revision" type="String" required="false" default="#this.revision#" hint="Document revision number." />

		<cfset var cfhttp = ''>
		<cfset var revision_string = ''>
		
		<!--- validate object --->
		<cfset variables.validateObject()>
		
		<!--- update object data --->
		<cfset this.id = arguments.id>
		<cfset this.revision = arguments.revision>
		
		<cfif this.revision neq ''>
			<cfset revision_string = "?rev=#arguments.revision#">
		</cfif>
		
		<!--- get that document --->
		<cfhttp url="#variables.couch_url#/#variables.db_name#/#arguments.id##revision_string#" port="#variables.couch_port#" method="GET"  username="#variables.couch_username#" password="#variables.couch_password#" />

		<!--- handle errors --->
		<cfif cfhttp.statuscode neq '200 OK'>
			<cfset errorHandler("load", cfhttp)>
		</cfif>

		<!--- update object data --->
		<cfset this.data = cfhttp.filecontent>
		<cfset this.revision = replace(cfhttp.responseHeader.Etag,'"','','all')>
		
		<cfreturn this.data />
	</cffunction>


	<!--- create --->
	<cffunction name="create" access="public" returntype="String" hint="Creates a new document and copies data to This object. Returns created doc ID.">
		<cfargument name="id" type="String" required="true" default="#this.id#" hint="Document ID." />
		<cfargument name="data" type="String" required="true" default="#this.data#" hint="Document data in JSON format." />
		<cfargument name="content_type" type="String" required="false" default="#this.content_type#" hint="Data content type." />
		
		<cfset var cfhttp = ''>
		<cfset var method = ''>
		<cfset var response = ''>
		
		<!--- validate object --->
		<cfset variables.validateObject()>
		
		<!--- update object data --->
		<cfset this.id = arguments.id>
		<cfset this.content_type = arguments.content_type>
		<cfset this.data = arguments.data>
		
		<cfif arguments.id is ''>
			<cfset method = 'POST'>
		<cfelse>
			<cfset method = 'PUT'>
		</cfif>
		
		<!--- create new document --->
		<cfhttp url="#variables.couch_url#/#variables.db_name#/#arguments.id#" port="#variables.couch_port#" method="#method#" username="#variables.couch_username#" password="#variables.couch_password#" >
			<cfhttpparam type='header' name='Content-Type' value='#arguments.content_type#'>
			<cfhttpparam type='body' name='#arguments.id#' value='#arguments.data#'>
		</cfhttp>
	
		<!--- handle errors --->
		<cfif cfhttp.statuscode neq '201 Created'>
			<cfset errorHandler("create", cfhttp)>
		</cfif>
		
		<!--- update object revision --->
		<cfset response = decodeJSON(cfhttp.filecontent)>
		<cfset this.revision = response.rev>
		<cfset this.id = response.id>

		<cfreturn this.id />
	</cffunction>
	
	
	<!--- update --->
	<cffunction name="update" access="public" returntype="String" hint="Updates an existing document with new data. Updates This object too. Returns document data." >
		<cfargument name="id" type="String" required="true" default="#this.id#" hint="Document ID." />
		<cfargument name="revision" type="String" required="true" default="#this.revision#" hint="Document revision number." />
		<cfargument name="data" type="String" required="false" default="#this.data#" hint="Document data in JSON format." />
		<cfargument name="content_type" type="String" required="false" default="#this.content_type#" hint="Data content type." />
		
		<cfset var cfhttp = ''>
		<cfset var tmp = ''>
		
		<!--- validate object --->
		<cfset variables.validateObject()>
		
		<!--- update object data --->
		<cfset this.id = arguments.id>
		<cfset this.revision = arguments.revision>
		<cfset this.content_type = arguments.content_type>
		<cfset this.data = arguments.data>
		
		<!--- add revision to data struct (required for update) --->
		<cfset tmp = decodeJSON(arguments.data)>
		<cfset tmp['_rev'] = arguments.revision>
		<cfset arguments.data = encodeJSON(tmp)>
		
		<!--- update document --->
		<cfhttp url="#variables.couch_url#/#variables.db_name#/#arguments.id#" port="#variables.couch_port#" method="PUT" username="#variables.couch_username#" password="#variables.couch_password#">
			<cfhttpparam type="header" name="Content-Type" value="#arguments.content_type#">
			<cfhttpparam type='body' name='#arguments.id#' value='#arguments.data#'>
		</cfhttp>
		
		<!--- handle errors --->
		<cfif cfhttp.statuscode neq '201 Created'>
			<cfset errorHandler("update", cfhttp)>
		</cfif>
		
		<!--- update object revision (returned from cfhttp request as Etag, wrapped in quotations) --->
		<cfset this.revision = replace(cfhttp.responseHeader.Etag,'"','','all') >
		
		<cfreturn this.data />
	</cffunction>
	
	
	<!--- copy --->
	<cffunction name="copy" access="public" returntype="string" 
				hint="Creates a new document with the properties of This object. Does not modify This object. Returns new document ID." >
		<cfargument name="new_id" type="String" required="false" default="#createUUID()#" hint="Document ID to create." />
		<cfargument name="id" type="String" required="false" default="#this.id#" hint="Document ID." />
		<cfargument name="revision" type="String" required="false" default="" hint="Revision of document to overwrite. Only used for document overwrites." />

		<cfset var cfhttp = ''>
		<cfset var http_request = arrayNew(1)>
		<cfset var revision_string = ''>
		
		<!--- validate object --->
		<cfset variables.validateObject()>
		
		<cfif arguments.revision neq ''>
			<cfset revision_string = "?rev=#arguments.revision#">
		</cfif>
		
		<!--- custom HTTP Request --->
		<!--- note: this is sensitive to formatting. do not add tabs. --->
		<cfset http_request[1] = "COPY /#variables.db_name#/#arguments.id# HTTP/1.1">
		<cfset http_request[2] = "Destination: #arguments.new_id##revision_string#">
		
		<!--- do request --->
		<!--- note: improper HTTP requests will result in time-out errors --->
		<cfset cfhttp = Net_Socket(variables.couch_host, variables.couch_port, http_request)>

		<!--- handle errors --->
		<cfif cfhttp.statuscode neq '201 Created'>
			<cfset errorHandler("copy", cfhttp)>
		</cfif>

		<cfreturn arguments.new_id />
	</cffunction>
	
	
	<!--- delete --->
	<cffunction name="delete" access="public" returntype="boolean" hint="Deletes an existing document and resets This object. Returns true if successful." >
		<cfargument name="id" type="String" hint="Document ID." required="true" default="#this.id#" />
		<cfargument name="revision" type="String" required="true" default="#this.revision#" hint="Document revision number." />

		<cfset var cfhttp = ''>

		<!--- validate object --->
		<cfset variables.validateObject()>

		<!--- prevent accidental DB deletion! --->
		<cfif arguments.id is ''>
			<cfthrow message="Document ID cannot be blank.">
		</cfif>
		
		<cfif arguments.revision is ''>
			<cfthrow message="Document revision cannot be blank.">
		</cfif>

		<!--- update object data --->
		<cfset this.id = arguments.id>
		<cfset this.revision = arguments.revision>
		
		<!--- delete document --->
		<cfhttp url="#variables.couch_url#/#variables.db_name#/#arguments.id#?rev=#arguments.revision#" port="#variables.couch_port#" method="DELETE" username="#variables.couch_username#" password="#variables.couch_password#" />
		
		<!--- handle errors --->
		<cfif cfhttp.statuscode neq '200 OK'>
			<cfset errorHandler("delete", cfhttp)>
		</cfif>
		
		<!--- delete object data --->
		<cfset this.id = ''>
		<cfset this.revision = ''>
		<cfset this.data = ''>
		
		<cfreturn true />
	</cffunction>
	
	
	<!--- document exists? --->
	<cffunction name="document_exists" access="public" returntype="boolean" hint="Returns true if document exists.">
		<cfargument name="id" type="String" required="false" default="#this.id#">
		
		<cfset var result = false>
		<cfset var cfhttp = ''>
		
		<!--- validate object --->
		<cfset variables.validateObject()>
		
		<!--- test for blank document ID --->
		<cfif arguments.id is ''>
			<cfreturn false>
		</cfif>
		
		<!--- get specified document --->
		<cfhttp url="#variables.couch_url#/#variables.db_name#/#arguments.id#" port="#variables.couch_port#" method="GET" username="#variables.couch_username#" password="#variables.couch_password#" />

		<cfif cfhttp.statuscode eq '200 OK'>
			<cfset result = true><!--- document does exist! --->
		</cfif>
		
		<cfreturn result />
	</cffunction>
	
	
	<!--- TODO: attach 
	<cffunction name="attach" access="public" returntype="boolean" hint="Attach a file to document.">
		<cfargument name="id" type="string" required="false" default="#this.id#">
		<cfargument name="name" type="string" required="true" hint="Name of the attachment.">
		<cfargument name="attachment" type="Any" required="true" hint="Object to attach.">
		
		<cfset var result = true>
		
		<cfset var outstrem = CreateObject("java", "java.io.BufferedOutputStream")>
		<cfset var objOut = CreateObject("java", "java.io.ObjectOutputStream")>
		
		<cfset objOut.init(outstrem)><CFABORT>
		<cfset result = objOut.writeObject(arguments.attachment)>
		
		<cfreturn result />
	</cffunction>--->
		
	
	<!--- error handler --->
	<cffunction name="errorHandler" access="private" hint="Handles Couch DB errors.">
		<cfargument name="operation" type="String" required="true" hint="The type of operation attempted.">
		<cfargument name="cfhttp" type="Struct" required="true" hint="CFHttp variable.">
				
		<cfset var couchDB_error = ''>
		<cfset var short_statusCode = ''>
		<cfset var error_detail = ''>
		<cfset var suggestions = arrayNew(1)>
		
		<cfparam name="arguments.cfhttp.filecontent" default="{}">
		
		<cfset couchDB_error = decodeJSON(arguments.cfhttp.filecontent)>
		<cfset short_statusCode = left(arguments.cfhttp.statuscode, 3)>
		
		<!--- attempt suggestions for error resolution --->
		<!--- note: Couch DB is somewhat cryptic with its error messages,
			 so I've added some suggestions to help resolve common errors --->
		<!--- TODO: add all operation types and status codes 
			see: http://wiki.apache.org/couchdb/HTTP_status_list
		--->
		<cfscript>
			switch(operation) {
				case 'load': 
					switch(short_statusCode) {
						case '404':
							arrayAppend(suggestions, 'Document ID might not exist in the database');
							break;
					}
					break;
				case 'create': 
					switch(short_statusCode) {
						case '400': 
							arrayAppend(suggestions, "JSON data may not be properly formatted");
							break;
						case '409': 
							arrayAppend(suggestions, "Document ID might be blank");
							break;
						case '412': 
							arrayAppend(suggestions, "Document ID might already exist in database"); 
							break;
					}
					break;
				case 'update': 
					switch(short_statusCode) {
						case '400': 
							arrayAppend(suggestions, 'Document ID might be incorrect');
							arrayAppend(suggestions, 'Document revision ## might be incorrect');
							break;
						case '412':
							arrayAppend(suggestions, 'Document ID might be incorrect');
							arrayAppend(suggestions, 'Document revision ## might be incorrect');
							break;
					}
					break;
				case 'copy': 
					switch(short_statusCode) {
						case '400': 
							arrayAppend(suggestions, 'Destination revision number might be incorrect');
							break;
						case '404': 
							arrayAppend(suggestions, 'Document ID might not exist in the database');
							break;
					}
					break;
				case 'delete': 
					switch(short_statusCode) {
						case '400': 
							arrayAppend(suggestions, 'Document ID might be incorrect');
							arrayAppend(suggestions, 'Document revision ## might be incorrect');
							break;
						case '404': 
							arrayAppend(suggestions, 'Document ID might be incorrect');
							break;
						case '412': 
							arrayAppend(suggestions, 'Document ID might be incorrect');
							arrayAppend(suggestions, 'Document revision ## might be incorrect');
							break;
					}
					break;
				case 'database': 
					switch(short_statusCode) {
						case '404':
							arrayAppend(suggestions, 'Database not found');
							break;
					}
					break;
			}
		</cfscript>
		
		<!--- create descriptive error detail --->
		<cfsavecontent variable="error_detail">
			Suggestions:
			<cfdump var="#suggestions#"><br>
			
			CouchDB messages:
			<cfdump var="#couchDB_error#"><br>
			
			Object state:
			<cfdump var="#this#">
		</cfsavecontent>
		
		<!--- throw the error --->
		<cfthrow message="#arguments.operation#() error: #arguments.cfhttp.statuscode# " detail="#error_detail#">
		
	</cffunction>
	
	
	<!--- JSON HELPER METHODS --->
	
	<!--- encodeJSON --->
	<cffunction name="encodeJSON" access="private" returntype="String">
		<cfargument name="data" type="Any" required="yes">
		
		<cfset var result = ''>
		
		<cfinvoke component="json" method="encode" stringNumbers="true" data="#data#" returnvariable="result">
		
		<cfreturn result>
	</cffunction>
	
	
	<!--- decodeJSON --->
	<cffunction name="decodeJSON" access="private" returntype="Any">
		<cfargument name="data" type="String" required="yes">
		
		<cfset var result = ''>
		
		<cfinvoke component="json" method="decode" data="#data#" returnvariable="result">
		
		<cfreturn result>
	</cffunction>
	
	
	<!--- OTHER HELPER METHODS                                                                        --->
	
	<!--- Net_Socket --->
	<cffunction name="Net_Socket" access="private" output="false" returntype="struct" 
				hint="by Russ Spivey. NOTE: Improper requests will just time-out without giving more error information (sorry!)">
		<cfargument name="host" type="String" required="true" hint="Host name (not including http://)">
		<cfargument name="port" type="Numeric" required="false" default="80">
		<cfargument name="request" type="Array" required="true" hint="HTTP Request data. Each element is a new line.">
		<cfargument name="timeout" type="String" required="false" default="3000" hint="Timeout in milliseconds. Default: 3 seconds.">
	<cfscript>
		var Socket = '';
		var OutputStreamWriter = '';
		var InputStreamReader = '';
		var BufferedWriter = '';
		var BufferedReader = '';
		var start_ticker = 0;
		var now_ticker = 0;
		var line = '';
		var full_response = '';
		var statuscode = '';
		var result = StructNew();
		
		result.success = false;
		result.message = '';
		result.statuscode = '';
		result.full_response = '';
		result.responseHeader = structNew();
		
		// Setup socket
		Socket = CreateObject("java", "java.net.Socket");	
		
		// Try to connect
		try {
			Socket.init(arguments.host, arguments.port);
		}
		catch(any e) {
			result.message = "Could not connect to: #arguments.host#:#arguments.port#";
			return result;
		}
		
		// Is socket connected?
		if(not Socket.isConnected()) {
			result.message = "Error: Not Connected";
			return result;
		}
		
		// Setup BufferedWriter (for "writing" data to the socket)
		OutputStreamWriter = CreateObject("java","java.io.OutputStreamWriter");
		OutputStreamWriter.init(socket.getOutputStream());
		BufferedWriter = CreateObject("java","java.io.BufferedWriter");
		BufferedWriter.init(OutputStreamWriter);
		
		//Create request
		For(i=1; i LTE arraylen(arguments.request); i++) {
			BufferedWriter.write(arguments.request[i]);
			BufferedWriter.newLine();
		}
		BufferedWriter.newLine();
	
		// Send Request
		BufferedWriter.flush();
		
		// Setup BufferedReader (for reading the response)
		InputStreamReader = CreateObject("java","java.io.InputStreamReader").init(socket.getInputStream());
		BufferedReader = CreateObject("java","java.io.BufferedReader").init(InputStreamReader);
	
		// Wait for a response... 
		start_ticker = getTickCount();
		while(not BufferedReader.ready())
		{
			now_ticker = getTickCount();
			if(now_ticker - start_ticker gt arguments.timeout) {
				// Response timed-out
				
				// Close connections
				BufferedWriter.close();
				BufferedReader.close();
				Socket.close();
				
				result.message = "Error: Timeout";
				return result;
				}
		}
		
		// Construct full response, line-by-line
		do
		{
		   line = BufferedReader.readLine();
		   if(len(line) gt 0) {
	       		full_response &= chr(13) & chr(10) & line;
	       		}
	    }
		while(len(line) gt 0);
		
		// Close connections
		BufferedWriter.close();
		BufferedReader.close();
		Socket.close();
	
		// Get response status
		statuscode = REMatch('\s(\d\d\d\s\w+)\s', full_response);
		
		// Build result
		result.statuscode = trim(statuscode[1]);
		result.full_response = full_response;
		result.responseHeader = listToStruct(full_response);
		result.success = true;
		
		return result;
	</cfscript>
	</cffunction>

	
	<!--- ListToStruct --->
	<cffunction name="ListToStruct" access="private" returntype="Struct">
		<cfargument name="list" type="string" required="true" hint="List to convert.">
		<cfscript>
		/**
		* Converts a delimited list of key/value pairs to a structure.
		*
		* @param list      List of key/value pairs to initialize the structure with. Format follows key=value.
		* @param delimiter      Delimiter seperating the key/value pairs. Default is the comma.
		* @return Returns a structure.
		* @author Rob Brooks-Bilson (rbils@amkor.com)
		* @version 1.0, December 10, 2001
		*/
		var myStruct=StructNew();
		var i=0;
		var delimiter=chr(13) & chr(10);
		
		if (ArrayLen(arguments) gt 1){
			delimiter = arguments[2];
		}
		
		for (i=1; i LTE ListLen(list, delimiter); i=i+1){
			StructInsert(myStruct, ListFirst(ListGetAt(list, i, delimiter), ":"), trim(ListLast(ListGetAt(list, i, delimiter), ":")));
		}
		
		return myStruct;
		</cfscript>
	</cffunction>
</cfcomponent>
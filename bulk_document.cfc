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
		3. Set the database name, port, and url within this CFC file (db_name, couch_port, couch_url)
	--->	
	
<!--- quick links: 
	CouchDB Bulk Document API documentation: http://wiki.apache.org/couchdb/HTTP_Bulk_Document_API
	local couchdb admin: http://localhost:5984/_utils/
	Start couchdb in linux terminal: sudo /etc/init.d/couchdb start (for version .8)
								or   sudo couchdb (for version .9)
--->

<!--- TODOs:
	Figure out how to make _bulk_docs method easier to use. There's gotta be a way to help properly format the input data.
	I do like using JSON as the input format so that the method could be called remotely via javascript if access is changed to remote.
 --->

<cfcomponent hint="This CFC is a wrapper for CouchDB bulk document operations.">
	<!--- private variables --->
	<!--- couch+database connection parameters --->
	<cfmodule template="connection_defaults.cfm" result="conn">
	<cfset variables.db_name = variables.conn.db_name>
	<cfset variables.couch_port = variables.conn.couch_port>
	<cfset variables.couch_host = variables.conn.couch_host>
	<cfset variables.couch_url = variables.conn.couch_url>
	<cfset variables.couch_username = variables.conn.couch_username>
	<cfset variables.couch_password = variables.conn.couch_password>


	<!--- init --->
	<cffunction name="init" access="public" returntype="Any"
				hint="Initializes this CFC. Returns this object.">
		<cfargument name="db_name" type="String" required="true" hint="Database name.">
		<cfargument name="couch_port" type="String" required="false" default="#variables.couch_port#" hint="Database port.">
		<cfargument name="couch_host" type="String" required="false" default="#variables.couch_host#" hint="Database host.">
		<cfargument name="couch_username" type="string" required="false" default="#variables.couch_username#" hint="Your CouchDB username">
		<cfargument name="couch_password" type="string" required="false" default="#variables.couch_password#" hint="Your CouchDB password">		
		
		<!--- map arguments to private variables --->
		<cfset variables.db_name = arguments.db_name>
		<cfset variables.couch_host = arguments.couch_host>
		<cfset variables.couch_port = arguments.couch_port>
		<cfset variables.couch_url = 'http://#variables.couch_host#'>
		<cfset variables.couch_username = arguments.couch_username>
		<cfset variables.couch_password = arguments.couch_password>

		<cfreturn This />
	</cffunction>
	
	
	<!--- _all_docs --->
	<cffunction name="_all_docs" access="public" returntype="String" 
				hint="Gets documents matching the provided key(s) (document IDs) OR having a key between startkey and endkey. Returns JSON.">
		<cfargument name="include_docs" type="boolean" required="false" default="false" 
					hint="True causes this method to return full document data. False returns IDs and revisions only.">
		<cfargument name="startkey" type="String" required="false" default="" 
					hint="First key in set (inclusive). Key can be arbitrary (non-existant).">			
		<cfargument name="endkey" type="String" required="false" default="" 
					hint="Last key in set (inclusive). Key can be arbitrary (non-existant).">	
		<cfargument name="keys" type="String" required="false" default="" 
					hint="List of keys (document IDs). Comma-delimited.">	
		
		<cfset var cfhttp = ''>
		<cfset var http_method = ''>
		<cfset var key_range_params = ''>
		<cfset var keys_array_JSON = ''>
		
		<!--- validate arguments --->
		<cfif arguments.keys is '' AND (arguments.startkey is '' OR arguments.endkey is '')>
			<cfthrow message="You must provide either a list of keys OR a startkey and endkey.">
		</cfif>
		
		<cfif arguments.keys neq ''>
			<!--- if a list of keys were provided, set up JSON data --->
			<cfset keys_array_JSON = encodeJSON(listToArray(listSort(arguments.keys,"text")))>
			<cfset http_method = 'POST'>
		<cfelse>
			<!--- if start and end keys were provided, set up url parameters --->
			<cfset key_range_params = '&startkey="#arguments.startkey#"&endkey="#arguments.endkey#"'>
			<cfset http_method = 'GET'>
		</cfif>

		<!--- do http request --->
		<cfhttp url='#variables.couch_url#/#variables.db_name#/_all_docs?include_docs=#arguments.include_docs##key_range_params#' 
				port="#variables.couch_port#" method="#http_method#" username="#variables.couch_username#" password="#variables.couch_password#">
			<cfhttpparam type="header" name="Content-Type" value="application/json">	
			<cfif keys_array_JSON neq ''>
				<!--- list of keys (if provided) --->
				<cfhttpparam type="body" value='{"keys":#keys_array_JSON#}'>
			</cfif>
		</cfhttp>
		
		<cfreturn cfhttp.FileContent>
	</cffunction>
	
	
	<!--- bulk docs --->
	<cffunction name="_bulk_docs" access="public" returntype="String" 
				hint="Insert, update, or delete multiple documents.">
		<cfargument name="data" type="String" required="true" hint="Data in JSON format.">
		
		<cfset var cfhttp = ''>

		<!--- do http request --->
		<cfhttp url="#variables.couch_url#/#variables.db_name#/_bulk_docs" 
				port="#variables.couch_port#" method="POST" username="#variables.couch_username#" password="#variables.couch_password#">
			<cfhttpparam type="header" name="Content-Type" value="application/json">	
			<cfhttpparam type="body" value="#arguments.data#">
		</cfhttp>

		<cfreturn cfhttp.FileContent>
	</cffunction>
	
		
	<!--- JSON HELPER METHODS --->
	
	<!--- encodeJSON --->
	<cffunction name="encodeJSON" access="private" returntype="String">
		<cfargument name="data" type="Any" required="yes">
		
		<cfset var result = ''>
		
		<cfset result = REReplace(SerializeJSON(arguments.data),'("[A-Z]*"[ ]?:)','\L\1','All')>
        	<cfset result = REReplace(result,'("[A-Z]*[0-9]"[ ]?:)','\L\1','All')>
		
		<cfreturn reReplace(result,'([_a-zA-Z]*)(":)','\L\1\2','ALL')>
	</cffunction>
	
	
	<!--- decodeJSON --->
	<cffunction name="decodeJSON" access="private" returntype="Any">
		<cfargument name="data" type="String" required="yes">
		
		<cfset var result = ''>
		
		<cfset result = DeserializeJSON(arguments.data)>
		
		<cfreturn result>
	</cffunction>
</cfcomponent>
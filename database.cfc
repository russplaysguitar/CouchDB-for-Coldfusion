<!--- --------------------------------------------------------------------------------------- ----
	
Copyright (c) 2010, Russell Spivey (http://cfruss.blogspot.com)
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of the project nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	
---- --------------------------------------------------------------------------------------- --->


<cfcomponent hint="This CFC is a wrapper for the CouchDB Database API: http://wiki.apache.org/couchdb/HTTP_database_API">

	<!--- couch+database connection parameters --->
	<cfmodule template="connection_defaults.cfm" result="conn">
	<cfset variables.db_name = variables.conn.db_name>
	<cfset variables.couch_port = variables.conn.couch_port>
	<cfset variables.couch_host = variables.conn.couch_host>
	<cfset variables.couch_url = variables.conn.couch_url>
	<cfset variables.couch_username = variables.conn.couch_username>
	<cfset variables.couch_password = variables.conn.couch_password>
	
	
	<!--- init --->
	<cffunction name="init" access="public" returntype="any" hint="Sets database parameters, returns this object.">
		<cfargument name="db_name" type="string" required="false" default="#variables.db_name#" hint="Database name.">
		<cfargument name="couch_host" type="string" required="false" default="#variables.couch_host#" hint="The CouchDB host name. Default is 127.0.0.1">
		<cfargument name="couch_port" type="string" required="false" default="#variables.couch_port#" hint="The CouchDB port. Default is 5984">
		<cfargument name="couch_username" type="string" required="false" default="#variables.couch_username#" hint="Your CouchDB username">
		<cfargument name="couch_password" type="string" required="false" default="#variables.couch_password#" hint="Your CouchDB password">		

		<cfset variables.db_name = arguments.db_name>
		<cfset variables.couch_host = arguments.couch_host>
		<cfset variables.couch_port = arguments.couch_port>
		<cfset variables.couch_url = "http://#arguments.couch_host#:#arguments.couch_port#">
		<cfset variables.couch_username = arguments.couch_username>
		<cfset variables.couch_password = arguments.couch_password>
		
		<cfreturn this>
	</cffunction>
	
	
	<!--- all_dbs --->
	<cffunction name="all_dbs" access="public" returntype="string" hint="Returns a list of all databases, encoded as JSON.">
		
		<cfset var cfhttp = ''>
		
		<!--- do request --->
		<cfhttp url="#variables.couch_url#/_all_dbs" port="#variables.couch_port#" method="GET" username="#variables.couch_username#" password="#variables.couch_password#" />
		
		<cfreturn cfhttp.FileContent>
	</cffunction>
	
	
	<!--- create --->
	<cffunction name="create" access="public" returntype="boolean" hint="Creates a new empty database.">
		<cfargument name="db_name" type="string" required="false" default="#variables.db_name#" hint="Name of the database to create.">
	
		<!--- do request --->
		<cfhttp url="#variables.couch_url#/#arguments.db_name#" port="#variables.couch_port#" method="PUT" username="#variables.couch_username#" password="#variables.couch_password#" />
		
		<!--- error? --->
		<cfif cfhttp.statuscode neq '201 Created'>
			<cfthrow message="Error: Database '#arguments.db_name#' not created. CouchDB response: #cfhttp.FileContent#">
		</cfif>
		
		<cfreturn true>
	</cffunction>
	
	
	<!--- delete --->
	<cffunction name="delete" access="public" returntype="boolean" hint="Deletes an existing database.">
		<cfargument name="db_name" type="string" required="false" default="#variables.db_name#" hint="Name of the database to delete.">
	
		<!--- do request --->
		<cfhttp url="#variables.couch_url#/#arguments.db_name#" port="#variables.couch_port#" method="DELETE" username="#variables.couch_username#" password="#variables.couch_password#" />
		
		<!--- error? --->
		<cfif cfhttp.statuscode neq '200 OK'>
			<cfthrow message="Error: Database '#arguments.db_name#' not deleted. CouchDB response: #cfhttp.FileContent#">
		</cfif>
		
		<cfreturn true>
	</cffunction>
	
	
	<!--- info --->
	<cffunction name="info" access="public" returntype="string" hint="Returns information about database, encoded as JSON.">
		<cfargument name="db_name" type="string" required="false" default="#variables.db_name#" hint="Name of the database to return info about.">
		
		<cfset var cfhttp = ''>
		
		<!--- do request --->
		<cfhttp url="#variables.couch_url#/#arguments.db_name#" port="#variables.couch_port#" method="GET" username="#variables.couch_username#" password="#variables.couch_password#" />
		
		<cfreturn cfhttp.FileContent>
	</cffunction>
	
	
	<!--- exists? --->
	<cffunction name="exists" access="public" returntype="string" hint="Returns true if database exists, false otherwise.">
		<cfargument name="db_name" type="string" required="false" default="#variables.db_name#" hint="Name of the database to check.">
		
		<cfset var cfhttp = ''>
		
		<cfset var result = false>
		
		<!--- do request --->
		<cfhttp url="#variables.couch_url#/#arguments.db_name#" port="#variables.couch_port#" method="GET" username="#variables.couch_username#" password="#variables.couch_password#" />
		
		<cfset response_struct = deserializeJSON(cfhttp.FileContent)>
		
		<cfif structKeyExists(response_struct, "ERROR") and response_struct.error is 'not_found'>
			<!--- database not found! --->
			<cfset result = false>
		<cfelse>
			<cfset result = true>
		</cfif>
		
		<cfreturn result>
	</cffunction>
	
	
	<!--- changes --->
	<cffunction name="changes" access="public" returntype="string" hint="Returns a list of changes made to documents in the database, in the order they were made, encoded as JSON.">
		<cfargument name="db_name" type="string" required="false" default="#variables.db_name#" hint="Name of the database.">
		
		<cfset var cfhttp = ''>
		
		<!--- do request --->
		<cfhttp url="#variables.couch_url#/#arguments.db_name#/_changes" port="#variables.couch_port#" method="GET" username="#variables.couch_username#" password="#variables.couch_password#" />
		
		<cfreturn cfhttp.FileContent>
	</cffunction>
	
	
	<!--- compact --->
	<cffunction name="compact" access="public" returntype="boolean" hint="Compresses the database file by removing unused sections created during updates and old revisions.">
		<cfargument name="db_name" type="string" required="false" default="#variables.db_name#" hint="Name of the database.">
		
		<cfset var cfhttp = ''>
		
		<!--- do request --->
		<cfhttp url="#variables.couch_url#/#arguments.db_name#/_compact" port="#variables.couch_port#" method="POST" username="#variables.couch_username#" password="#variables.couch_password#">
			<cfhttpparam type="body" name="compact" value="true">
		</cfhttp>
		
		<cfreturn true>
	</cffunction>
</cfcomponent>
<!--- --------------------------------------------------------------------------------------- ----
	
Copyright (c) 2010, Russell Spivey (http://cfruss.blogspot.com)
All rights reserved.

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

    * Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.
    * Neither the name of the project nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
	
---- --------------------------------------------------------------------------------------- --->

<cfcomponent extends="document" hint="This CFC implements the CouchDB Views API: http://wiki.apache.org/couchdb/HTTP_view_API">
	<cfset this.view = ''>

	<!--- load --->
	<cffunction name="load" access="public" returntype="String" hint="Loads existing document data into This object. Returns document data." >
		<cfargument name="id" type="String" required="false" default="#this.id#" hint="Design view document ID (do not include _design/)." />
		<cfargument name="view" type="String" required="false" default="#this.view#" hint="View (do not include _view/)." />
		<cfargument name="key" type="string" required="false" default="" hint="Specific key to retrieve.">
		<cfargument name="keys" type="string" required="false" default="" hint="List of keys to retrieve.">
		<cfargument name="startkey" type="any" required="false" default="" hint="Key to start at.">
		<cfargument name="startkey_docid" type="string" required="false" default="" hint="Document ID to start with.">
		<cfargument name="endkey" type="any" required="false" default="" hint="Key to end at.">
		<cfargument name="endkey_docid" type="string" required="false" default="" hint="Last document ID. Included in result unless inclusive_end is explicitly set to false.">
		<cfargument name="limit" type="string" required="false" default="" hint="Limit the number of documents in the output. Numeric or blank.">
		<cfargument name="stale" type="string" required="false" default="" hint="If stale=ok CouchDB will not refresh the view even if it is stalled. 'ok' or blank.">
		<cfargument name="descending" type="boolean" required="false" default="false" hint="Return the results in reverse order.">
		<cfargument name="skip" type="numeric" required="false" default="0" hint="Number of documents to skip.">
		<cfargument name="group" type="string" required="false" default="" hint="Controls whether the reduce function reduces to a set of distinct keys or to a single result row. True/false/blank.">
		<cfargument name="group_level" type="string" required="false" default="-" hint="The array level at which to perform reduce on. See: http://caprazzi.net/posts/charting-data-with-couchdb/  Numeric or -.">
		<cfargument name="reduce" type="string" required="false" default="" hint="Whether to use the reduce function of the view. CouchDB defaults to true if a reduce function is defined, false otherwise. True/false/blank.">
		<cfargument name="include_docs" type="boolean" required="false" default="false" hint="Include the document which emitted each view entry.">
		<cfargument name="inclusive_end" type="boolean" required="false" default="true" hint="Whether the endkey is included in the result.">
		
		<cfset var cfhttp = ''>
		<cfset var http_method = 'GET'>
		<cfset var keys_json = ''>
		
		<!--- validate object --->
		<cfset variables.validateObject()>
		
		<!--- update object data --->
		<cfif this.id does not contain '_design'>
			<cfset this.id = "_design/#arguments.id#">
		</cfif>

		<cfif arguments.keys neq ''>
			<!--- this requires a POST because keys will be provided in the request body --->
			<cfset http_method = 'POST'>
			<cfset keys_json = '{"keys":#encodeJSON(listToArray(arguments.keys))#}'>
		</cfif>

		<!--- get that document --->
		<cfhttp url="#variables.couch_url#/#variables.db_name#/_design/#arguments.id#/_view/#arguments.view#" port="#variables.couch_port#" method="#http_method#" username="#variables.couch_username#" password="#variables.couch_password#">
			<cfif arguments.key neq ''>
				<cfhttpparam name="key" value="#encodeJSON(arguments.key)#" type="url">
			</cfif>
			<cfif keys_json neq ''>
				<cfhttpparam name="body" value="#keys_json#" type="body">
			</cfif>
			<cfif IsArray(arguments.startkey) OR arguments.startkey neq ''>
				<cfhttpparam name="startkey" value="#encodeJSON(arguments.startkey)#" type="url">
			</cfif>
			<cfif arguments.startkey_docid neq ''>
				<cfhttpparam name="startkey_docid" value="#arguments.startkey_docid#" type="url">
			</cfif>
			<cfif IsArray(arguments.endkey) OR arguments.endkey neq ''>
				<cfhttpparam name="endkey" value="#encodeJSON(arguments.endkey)#" type="url">
			</cfif>
			<cfif arguments.endkey_docid neq ''>
				<cfhttpparam name="endkey_docid" value="#arguments.endkey_docid#" type="url">
			</cfif>
			<cfif arguments.limit neq ''>
				<cfhttpparam name="limit" value="#arguments.limit#" type="url">
			</cfif>
			<cfif arguments.stale is 'ok' or val(arguments.stale)>
				<cfhttpparam name="stale" value="ok" type="url">
			</cfif>
			<cfhttpparam name="descending" value="#arguments.descending#" type="url">
			<cfhttpparam name="skip" value="#arguments.skip#" type="url">
			<cfif arguments.group neq ''>
				<cfhttpparam name="group" value="#arguments.group#" type="url">
			</cfif>
			<cfif arguments.group_level neq '-'>
				<cfhttpparam name="group_level" value="#arguments.group_level#" type="url">
			</cfif>
			<cfif arguments.reduce neq ''>
				<cfhttpparam name="reduce" value="#arguments.reduce#" type="url">
			</cfif>
			<cfhttpparam name="include_docs" value="#arguments.include_docs#" type="url">
			<cfhttpparam name="inclusive_end" value="#arguments.inclusive_end#" type="url">
		</cfhttp>

		<!--- handle errors --->
		<cfif cfhttp.statuscode neq '200 OK'>
			<cfset errorHandler("load", cfhttp)>
		</cfif>

		<!--- update object data --->
		<cfset this.data = cfhttp.filecontent>
		<cfif isdefined('cfhttp.responseHeader.Etag')>
			<cfset this.revision = replace(cfhttp.responseHeader.Etag,'"','','all')>
		</cfif>
		
		<cfreturn this.data />
	</cffunction>
	
	
	<!--- view cleanup --->
	<cffunction name="cleanup" access="public" returntype="boolean" hint="Removes unused view output, which remains in the database until you explicitly run cleanup.">
		
		<cfset var cfhttp = ''>
		
		<!--- do request --->
		<cfhttp url="#variables.couch_url#/#variables.db_name#/_view_cleanup" port="#variables.couch_port#" method="post" username="#variables.couch_username#" password="#variables.couch_password#">
			<cfhttpparam name="cleanup" value="true" type="formfield">
		</cfhttp>
		
		<!--- handle errors --->
		<cfif cfhttp.statuscode neq '202 Accepted'>
			<cfset errorHandler("cleanup", cfhttp)>
		</cfif>
		
		<cfreturn true />
	</cffunction>
	
	
	<!--- view compact --->
	<cffunction name="compact" access="public" returntype="boolean" hint="Compacts views. If you have very large views or are tight on space, you might consider compaction.">
		<cfargument name="id" default="#this.id#" hint="Design view document ID (do not include _design/)." />
	
		<cfset var cfhttp = ''>
	
		<!--- update object data --->
		<cfif this.id does not contain '_design'>
			<cfset this.id = "_design/#arguments.id#">
		</cfif>
	
		<!--- do request --->
		<cfhttp url="#variables.couch_url#/#variables.db_name#/_compact/#arguments.id#" port="#variables.couch_port#" method="post" username="#variables.couch_username#" password="#variables.couch_password#">
			<cfhttpparam name="cleanup" value="true" type="formfield">
		</cfhttp>
		
		<!--- handle errors --->
		<cfif cfhttp.statuscode neq '202 Accepted'>
			<cfset errorHandler("compact", cfhttp)>
		</cfif>
		
		<cfreturn true />
	</cffunction>
	
	
	<!--- temporary views --->
	<cffunction name="temporary" access="public" returntype="string" hint="Makes temporary view requests. Returns raw JSON result.">
		<cfargument name="mapFunction" type="string" required="true" hint="Temporary map function. JSON encoded string.">
	
		<cfset var cfhttp = ''>
	
		<!--- do request --->
		<cfhttp url="#variables.couch_url#/#variables.db_name#/_temp_view" port="#variables.couch_port#" method="post" username="#variables.couch_username#" password="#variables.couch_password#">
			<cfhttpparam type="header" name="Content-Type" value="#this.content_type#">
			<cfhttpparam type="body" value="#arguments.mapFunction#">
		</cfhttp>
		
		<!--- handle errors --->
		<cfif cfhttp.statuscode neq '200 OK'>
			<cfset errorHandler("temporary", cfhttp)>
		</cfif>
		
		<cfreturn cfhttp.FileContent>
	</cffunction>
</cfcomponent>
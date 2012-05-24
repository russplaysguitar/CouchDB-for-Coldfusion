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

<cfcomponent hint="This stateless CFC acts as a collection of OODB functions.">
	
	<!--- private variables --->
	<!--- couch+database connection defaults --->
	<cfmodule template="connection_defaults.cfm" result="db_params">
	

	<!--- init --->
	<cffunction name="init" access="public" returntype="Any"
				hint="Initializes this CFC. Returns this object.">
		<cfargument name="db_name" type="String" required="false" default="#variables.db_params.db_name#" hint="Database name.">
		<cfargument name="couch_port" type="String" required="false" default="#variables.db_params.couch_port#" hint="Database port.">
		<cfargument name="couch_host" type="String" required="false" default="#variables.db_params.couch_host#" hint="Database host.">
		<cfargument name="couch_username" type="string" required="false" default="#variables.db_params.couch_username#" hint="Your CouchDB username">
		<cfargument name="couch_password" type="string" required="false" default="#variables.db_params.couch_password#" hint="Your CouchDB password">		
		

		<!--- map arguments to private variables --->
		<cfset variables.db_params = {
			db_name = arguments.db_name,
			couch_port = arguments.couch_port,
			couch_host = arguments.couch_host,
			couch_url = 'http://#arguments.couch_host#',
			couch_username = arguments.couch_username,
			couch_password = arguments.couch_password
		}>

		<cfreturn This />
	</cffunction>


	<!--- save --->
	<cffunction name="save" access="public" returntype="String" 
				hint="Saves an object to CouchDB. Returns the CouchDB document ID.">
		<cfargument name="obj" type="Any" required="yes" hint="The object to save.">
		<cfargument name="id" type="String" required="no" default="#createUUID()#" hint="A CouchDB document ID. Pass an unused ID to create a new document or an existing ID to overwrite an existing document.">
		
		<cfset var couchDoc = createObject("component","document").init(argumentCollection = variables.db_params)>
		<cfset var objPrivates = ''>
		<cfset var objPublics = ''>
		<cfset var objJSON = ''>
		
		<cfset couchDoc.id = arguments.id>
		
		<!--- begin: get private object variables --->
		<cfset obj['getPrivates'] = variables['getPrivates']><!--- inject getPrivates() into object --->
		<cfset objPrivates = obj.getPrivates()><!--- get object variables --->
		<cfset structDelete(obj,"getPrivates")><!--- remove injected function --->
		<!--- end: get private object variables --->
		
		<!--- begin: get public object variables --->
		<cfset obj['getPublics'] = variables['getPublics']><!--- inject getPrivates() into object --->
		<cfset objPublics = obj.getPublics()><!--- get object variables --->
		<cfset structDelete(obj,"getPublics")><!--- remove injected function --->
		<!--- end: get public object variables --->
		
		<!--- put public variables into THIS struct within private variables --->
		<cfset objPrivates.this = objPublics>
		
		<!--- convert private variables into JSON --->
		<cfset objJSON = encodeJSON(objPrivates)>
		
		<!--- fix id and revision to lower case --->
		<cfset objJSON = replace(objJSON,'_ID','_id','all')>
		<cfset objJSON = replace(objJSON,'_REV','_rev','all')>
		
		<!--- set couchDB document data --->
		<cfset couchDoc.data = objJSON>
		
		<cfif not couchDoc.document_exists()>
			<cfset couchDoc.create()><!--- create new CouchDB document --->
		<cfelse>
			<cfset couchDoc.load()><!--- (must load document first to get latest revision number) --->
			<cfset couchDoc.data = objJSON><!--- update document data --->
			<cfset couchDoc.update()><!--- do CouchDB update --->
		</cfif>
		
		<!--- success! return Document ID --->
		<cfreturn couchDoc.id />
	</cffunction>
	
	
	<!--- load --->
	<cffunction name="load" access="public" returntype="void" 
				hint="Loads an object with data from CouchDB.">
		<cfargument name="obj" type="Any" required="yes" hint="The object to load data into.">
		<cfargument name="id" type="String" required="yes" hint="CouchDB document ID.">
		
		<cfset var couchDoc = createObject("component","document").init(argumentCollection = variables.db_params)>
		<cfset var data = ''>
		
		<cfset couchDoc.id = arguments.id>
		<cfset couchDoc.load()>
		<cfset data = decodeJSON(couchDoc.data)>
		
		<!--- begin: set object private variables --->
		<cfset obj.setPrivates = variables.setPrivates>
		<cfset obj.setPrivates(data)>
		<cfset structDelete(obj,"setPrivates")><!--- remove injected function --->
		<!--- end: set object private variables --->
		
		
		<!--- begin: set object public variables --->
		<cfif isdefined('data.this')>
			<cfset obj.setPublics = variables.setPublics>
			<cfset obj.setPublics(data.this)>
			<cfset structDelete(obj,"setPublics")><!--- remove injected function --->
		</cfif>
		<!--- end: set object public variables --->
	</cffunction>
	
	
	<!--- delete --->
	<cffunction name="delete" access="public" returntype="boolean"
				hint="Deletes an object from the database. Returns true if successful.">
		<cfargument name="id" type="String" required="yes" hint="CouchDB document ID.">
		
		<cfset var result = false>
		<cfset var couchDoc = createObject("component","document").init(argumentCollection = variables.db_params)>
		
		<cfif couchDoc.document_exists(arguments.id)>
			<!--- load doc to get latest revision (required for delete)--->
			<cfset couchDoc.load(arguments.id)>
			
			<cfset couchDoc.delete()>
			<cfset result = true>
		</cfif>
		
		<cfreturn result>
	</cffunction>
	
	
	<!--- METHODS INJECTED INTO OBJECT                                                               --->
	
	<!--- get Privates --->
	<cffunction name="getPrivates" access="private" returntype="struct"
				hint="Used for object introspection. Returns VARIABLES scope as struct.">
		
		<cfset var result = structNew()>
		<cfset var the_var = ''>
		<cfset var item = ''>
		
		<!--- loop over variables --->
		<cfloop collection="#variables#" item="item">
			<cfset item = lcase(item)>
			<cfset the_var = evaluate('variables["#item#"]')>
			<cfif not IsCustomFunction(the_var)>
				<!--- only return non-function variables --->
				<cfset result['#item#'] = the_var>
			</cfif>
		</cfloop>

		<cfreturn result>
	</cffunction>
	
	
	<!--- get Publics --->
	<cffunction name="getPublics" access="private" returntype="struct"
				hint="Used for object introspection. Returns THIS scope as struct.">
					
		<cfset var result = structNew()>
		<cfset var the_var = ''>
		<cfset var item = ''>
		
		<!--- loop over variables --->
		<cfloop collection="#this#" item="item">
			<cfset item = lcase(item)>
			<cfset the_var = evaluate('this["#item#"]')>
			<cfif not IsCustomFunction(the_var)>
				<!--- only return non-function variables --->
				<cfset result['#item#'] = the_var>
			</cfif>
		</cfloop>
				
		<cfreturn result>
	</cffunction>
	
	
	<!--- set Privates --->
	<cffunction name="setPrivates" access="private" returntype="void"
				hint="Sets private object variables.">
		<cfargument name="vars" type="Struct" required="true">
		
		<cfset var item = ''>
		
		<!--- set variables one at a time since overwriting VARIABLES scope is not allowed --->
		<cfloop collection="#vars#" item="item">
			<cfset variables['#item#'] = evaluate('vars["#item#"]')>
		</cfloop>
	</cffunction>
	
	
	<!--- set Publics --->
	<cffunction name="setPublics" access="private" returntype="void"
				hint="Sets public object variables.">
		<cfargument name="vars" type="Struct" required="true">
		
		<cfset var item = ''>
		
		<!--- remove _id and _rev (these vars are set by CouchDB) --->
		<cfset structDelete(vars,"_id")>
		<cfset structDelete(vars,"_rev")>
		
		<!--- set variables one at a time since overwriting THIS scope is not allowed --->
		<cfloop collection="#vars#" item="item">
			<cfset this['#item#'] = evaluate('vars["#item#"]')>
		</cfloop>
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
<cfcomponent>
	<cfset this.name = 'ExampleCouchBlog'>
	<cfset this.ApplicationTimeout = createTimeSpan(1,0,0,0)>
	
	<!--- mapping to the CouchDB for Coldfusion project folder --->
	<cfset this.mappings["/CouchDB"] = getParentDirectory(getParentDirectory(getCurrentTemplatePath()))>
	
		
	<!--- on application start --->
	<cffunction name="onApplicationStart">
		<cfset var vars = {}>
		
		<!--- database parameters --->
		<cfset application.database_params = {db_name = 'example_blog_database',
						      couch_port = '5984',
						      couch_host = '127.0.0.1', 
						      couch_username='', 
						      couch_password=''}>
											  
		<!--- create database if it doesn't already exist --->
		<cfset databaseObj = createObject('component','CouchDB.database').init(argumentcollection = application.database_params)>
		<cfif not databaseObj.exists()>
			<cfset databaseObj.create()>
		</cfif>
		
		<!--- save all designs to the database --->
		<cfset vars.OODB = createObject('component','CouchDB.OODB').init(argumentcollection = application.database_params)>
		<cfdirectory name="vars.getDesigns" listInfo="name" directory="#expandPath('designs')#" filter="*.cfc">
		<cfoutput query="vars.getDesigns">
			<cfset vars.cfc_name = listGetAt(name, 1, '.')>
			<cfset vars.designObj = createObject('component','designs.#vars.cfc_name#')>
			<cfinvoke component="#vars.OODB#" method="save" obj="#vars.designObj#" id="_design/#vars.cfc_name#">
		</cfoutput>

		<cfreturn true />
	</cffunction>


	<!--- on request start --->
	<cffunction name="onRequestStart">
		
		<cfset request.database_params = duplicate(application.database_params)>
		
		<!--- reload application? --->
		<cfif isdefined('url.reload')>
			<cfset onApplicationStart()>
			<cflocation url="#cgi.SCRIPT_NAME#" addtoken="no">
		</cfif>
		
		<cfreturn true />
	</cffunction>


	<!--- get parent directory --->
	<cffunction name="getParentDirectory" access="private">
		<cfargument name="path" required="yes">
		
		<!--- thanks to Ben Nadel for this tidbit --->
		<cfreturn GetDirectoryFromPath(
			GetDirectoryFromPath(
				arguments.path
			).ReplaceFirst( "[\\\/]{1}$", "")
		) />
	</cffunction>
</cfcomponent>
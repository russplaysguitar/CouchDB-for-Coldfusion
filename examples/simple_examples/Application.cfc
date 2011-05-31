<cfcomponent>
	<cfset this.name = 'SimpleExamples'>
	<cfset this.ApplicationTimeout = createTimeSpan(1,0,0,0)>
	
	<!--- mapping to the CouchDB for Coldfusion project folder --->
	<cfset this.mappings["/CouchDB"] = getParentDirectory(getParentDirectory(getCurrentTemplatePath()))>


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
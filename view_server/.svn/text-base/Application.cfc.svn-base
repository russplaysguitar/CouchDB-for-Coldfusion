<cfcomponent>
	<cfset THIS.name = "CouchDB4CF">
	
	<cffunction name="onError" returntype="void">
	   <cfargument name="Exception" required="true" />
	   <cfargument name="EventName" type="String" required="true" />
	   
	   <cfset var error_result = structNew()>
	   
		<!--- write log --->
		<cfsavecontent variable="err">
			<!--- (you can put anything that may be of use in here) --->
			<cfdump var="#exception#">
		</cfsavecontent>
		<cffile action="write" file="#expandpath('app_error.html')#" output="#err#" mode="777">

		<!--- construct error struct for CouchDB --->
		<cfif Exception.ErrorCode is ''>
			<!--- prevent blank error code --->
			<cfset Exception.ErrorCode = "unknown_error">
		</cfif>
		<cfset error_result.error = "Coldfusion Exception: #Exception.ErrorCode#">
		<cfset error_result.reason = Exception.message>
		
		<!--- output error for CouchDB --->
		<cfoutput>#serializeJSON(error_result)##chr(10)#</cfoutput>

	</cffunction>
</cfcomponent>
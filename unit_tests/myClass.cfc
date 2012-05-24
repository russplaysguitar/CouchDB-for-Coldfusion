<cfcomponent hint="This is a test class for OODB.">

	<cfset this.public_var = "You can see me">
	<cfset variables.private_var = "I'm hidden">
	
	<cffunction name="privateFunction" access="private">
	</cffunction>
	
	<cffunction name="publicFunction" access="public">
	</cffunction>
	

</cfcomponent>
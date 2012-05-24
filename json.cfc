<cfcomponent>
	<!--- encodeJSON --->
	<cffunction name="encode" access="public" returntype="String">
		<cfargument name="data" type="Any" required="yes">
		
		<cfset var result = ''>
		
		<cfset result = REReplace(SerializeJSON(arguments.data),'("[A-Z]*"[ ]?:)','\L\1','All')>
        	<cfset result = REReplace(result,'("[A-Z]*[0-9]"[ ]?:)','\L\1','All')>
		
		<cfreturn reReplace(result,'([_a-zA-Z]*)(":)','\L\1\2','ALL')>
	</cffunction>
	
	
	<!--- decodeJSON --->
	<cffunction name="decode" access="public" returntype="Any">
		<cfargument name="data" type="String" required="yes">
		
		<cfset var result = ''>
		
		<cfset result = DeserializeJSON(arguments.data)>
		
		<cfreturn result>
	</cffunction>
</cfcomponent>
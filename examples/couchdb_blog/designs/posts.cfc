<cfcomponent hint="This CFC will be saved as a _design document in CouchDB.">

	<!--- tips: --->
	<!--- Use array notation to create new variables instead of dot notation. 
		  This preserves lower case variable names, which is required for CouchDB (this may not be necessary in all CF engines) --->
	<!--- Use structNew() instead of {}
		  Implicit structs and arrays cause weird variables to be created at runtime, which then get saved by OODB --->
	<cfset variables.views = structNew()>
    
    <cfset variables.views['all'] = structNew()>
    <cfset variables.views.all['map'] = '
		function(doc){
			if(doc.this.type == "post"){
				emit(doc.this.datestamp, null);
			}
		}
	'>
    
    <cfset variables.views['author'] = structNew()>
    <cfset variables.views.author['map'] = '
		function(doc){
			if(doc.this.type == "post"){
				emit(doc.this.author, null);
			}
		}
	'>
    
    <cfset variables.views['post'] = structNew()>
    <cfset variables.views.post['map'] = '
		function(doc){
			if(doc.this.type == "post"){
				emit(doc._id, null);
			}
		}
	'>
	
</cfcomponent>
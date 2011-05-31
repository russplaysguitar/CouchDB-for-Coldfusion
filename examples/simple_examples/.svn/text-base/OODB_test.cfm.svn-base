<!--- simple examples using OODB.cfc --->

<cfset OODB = createObject("component","CouchDB.OODB").init('my_database')>
<cfset myObject = createObject("component","myClass")>

Default object state:<br>
<cfdump var="#myObject#"><br>

Save object...<br>
<cfset objectID = OODB.save(myObject)>
Object ID: <cfoutput>#objectID#</cfoutput><br>
<br>

Erase object from memory...<br>
<cfset structDelete(variables,"myObject")>
<br>

Instantiate new object...<br>
<cfset myNewObject = createObject("component","myClass")>
<br>

New object state:<br>
<cfdump var="#myNewObject#">
<br>

Load new object with saved data...<br>
<cfset OODB.load(myNewObject, objectID)><br>
Loaded object state:<br>
<cfdump var="#myNewObject#">
<br>

Update object...<br>
<cfset myNewObject.public_var = "How neat!">
<br>

Save updated object...<br>
<cfset OODB.save(myNewObject, ObjectID)><br>
Updated object state:<br>
<cfdump var="#myNewObject#">
<br>

Delete object from DB... 
<cfset objDeleted = OODB.delete(objectID)>
<cfoutput>#objDeleted#</cfoutput>

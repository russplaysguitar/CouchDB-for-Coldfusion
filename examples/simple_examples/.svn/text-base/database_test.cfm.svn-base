<!--- database test --->

<!--- set up connection params --->
<cfset connection_params = {
		db_name = 'my_new_database',
		couch_host = '127.0.0.1',
		couch_port = '5984',
		couch_username = '',
		couch_password = ''}>

<!--- init database object with new database name (so that "create()" works) --->
<cfset myDatabase = createObject('component','CouchDB.database').init(argumentCollection = connection_params)>

Create database:
<cfdump var="#myDatabase.create()#">

<br />

List all databases:
<cfdump var="#myDatabase.all_dbs()#">

<br />

Info:
<cfdump var="#myDatabase.info()#">

<br />

Delete:
<cfdump var="#myDatabase.delete()#">
<!--- This file contains the CouchDB connection defaults for the entire project --->

<cfparam name="attributes.result" default="result" type="variableName">

<cfscript>
	caller[attributes.result] = {
		db_name = '',
		couch_host = '127.0.0.1',
		couch_port = '5984',
		couch_url = 'http://127.0.0.1:5984',
		couch_username = '',
		couch_password = ''
	};
</cfscript>
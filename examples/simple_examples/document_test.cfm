<!--- some simple examples using document.cfc --->

<!--- Please see READ ME in /document.cfc before attempting to use this file. 
	  It will save you some frustration!
	--->

<cffunction name="custom_dump" hint="Helper function to allow cfdump within cfscript tags">
	<cfargument name="myVar" type="Any" required="true">
	<cfargument name="label" type="String" required="false" default="">

	<cfoutput>#arguments.label#</cfoutput>
 	<cfdump var="#arguments.myVar#">
	<br />
	<cfflush>
</cffunction>

	
<!--- tip: This file creates and deletes documents, so you won't see these documents in CouchDB admin unless you remove the delete method calls --->
<cfscript>
	//set DB params
	my_db_params = {db_name = 'my_database',
			couch_port = '5984',
			couch_host = '127.0.0.1'};

	//instantiate document object
	doc_obj = createObject("component","CouchDB.document").init(argumentCollection = my_db_params);
	custom_dump(doc_obj, "Document object after init():");
		
	//CREATE
	doc_obj.data = '{"greetings":"hello world!"}';
	created_doc_id = doc_obj.create();
	custom_dump(created_doc_id, "Created doc ID:");
	custom_dump(doc_obj, "Doc object after create():");
	
	//LOAD
	doc2_obj = createObject("component","CouchDB.document").init(argumentCollection = my_db_params);
	doc_data = doc2_obj.load(created_doc_id);
	custom_dump(doc_data, "Loaded doc data");
	custom_dump(doc2_obj, "Doc object after load():");
	
	//COPY
	copy_doc_id = doc_obj.copy();
	custom_dump(copy_doc_id, "New document from Copy:");

	//UPDATE
	doc_obj.data = '{"greetings":"goodbye cruel world!"}';
	update_result = doc_obj.update();
	custom_dump(update_result, "Updated doc data:");

	//DELETE
	delete_result = doc_obj.delete();
	custom_dump(delete_result, "Delete() successful?");
	
	//cleanup COPY document
	doc3_obj = createObject("component","CouchDB.document").init(argumentCollection = my_db_params);
	doc3_obj.load(copy_doc_id);// must "load" the copy document before deleting it
	doc3_obj.delete();
	custom_dump(delete_result, "Delete() successful?");

</cfscript>



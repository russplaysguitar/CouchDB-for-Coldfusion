<!--- run some simple tests on /bulk_document.cfc --->

<!--- note: keys are case-sensitive --->

<!--- get bulk doc cfc --->
<cfset bulk_document_cfc = createObject("component","CouchDB.bulk_document").init("my_database")>

<!--- insert --->
<cfinvoke component="#bulk_document_cfc#" method="_bulk_docs" data='{"docs":[{"name":"bazzel"},{"name":"barry"}]}' 
			returnvariable="bulk_doc_insert">
Bulk Doc Insert:
<cfdump var="#bulk_doc_insert#"><br>
<br>

<cfset docs_json = deserializeJSON(bulk_doc_insert)>
<cfset key1 = docs_json[1].id>
<cfset key2 = docs_json[2].id>

<cfinvoke component="#bulk_document_cfc#" method="_all_docs" keys="#key1#,#key2#" include_docs="true" returnvariable="get_by_keys">
Get by keys:
<cfdump var="#get_by_keys#"><br>
<br>

<cfinvoke component="#bulk_document_cfc#" method="_all_docs" startkey="a" endkey="z" include_docs="false" returnvariable="get_key_range">
Get key range:
<cfdump var="#get_key_range#"><br>
<br>


<!--- you can read the docs and try bulk document update and delete operations for yourself: http://wiki.apache.org/couchdb/HTTP_Bulk_Document_API --->
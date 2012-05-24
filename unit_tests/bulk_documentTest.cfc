<cfcomponent name="bulk_documentTest" extends="mxunit.framework.TestCase">
	

	<cffunction name="testInit" access="public" returnType="void">
		<cfscript>
			assertTrue(structKeyExists(this.bulkDocObj, "init"),"init() should exist");
		</cfscript>
	</cffunction>


	<cffunction name="test_all_docs" access="public" returnType="void">
		<cfscript>
			assertTrue(structKeyExists(this.bulkDocObj, "_all_docs"),"_all_docs() should exist");
		</cfscript>
	</cffunction>


	<cffunction name="test_bulk_docs" access="public" returnType="void">
		<cfscript>
			assertTrue(structKeyExists(this.bulkDocObj, "_bulk_docs"), "_bulk_docs() should exist");

			// act: insert single record
			var insertResult = this.bulkDocObj._bulk_docs(data = '{"docs":[{"name":"bazzel"}]}');
			var resultObj = deserializeJSON(insertResult);

			// assert: insert single record
			assertTrue(isArray(resultObj), "Insert result should be an array");
			assertTrue(structKeyExists(resultObj[1], "ok"), "Insert result element should contain an 'ok' key");
			assertTrue(resultObj[1].ok, "Insert result 'ok' should be true");

			// act: insert multiple records
			var insertResult2 = this.bulkDocObj._bulk_docs(data = '{"docs":[{"name":"bazzel"},{"name":"barry"}]}');
			var resultObj2 = deserializeJSON(insertResult2);

			// assert: insert multiple records
			assertTrue(isArray(resultObj2), "Insert result should be an array");
			assertTrue(structKeyExists(resultObj2[1], "ok"), "Insert result element should contain an 'ok' key");
			assertTrue(resultObj2[1].ok, "Insert result [1] 'ok' should be true");
			assertTrue(resultObj2[2].ok, "Insert result [2] 'ok' should be true");
		</cfscript>
	</cffunction>


	<!--- setup and teardown --->
	
	<cffunction name="setUp" returntype="void" access="public">
		<!--- init bulk doc cfc --->
		<cfscript>
			this.database_params = {
				db_name = 'couch4cf_unit_tests',
				couch_port = 5984,
				couch_host = '127.0.0.1'
			};
			
			// create database (if it doesn't exist already)
			this.databaseObj = createObject('component','couch4cf.database').init(argumentCollection = this.database_params);
			if(!this.databaseObj.exists())
				this.databaseObj.create();

			this.bulkDocObj = createObject("component","couch4cf.bulk_document").init(argumentCollection = this.database_params);
		</cfscript>
	</cffunction>


	<cffunction name="tearDown" returntype="void" access="public">
		<cfscript>
			// cleanup: remove database
			if(this.databaseObj.exists())
				this.databaseObj.delete();
		</cfscript>
	</cffunction>

</cfcomponent>
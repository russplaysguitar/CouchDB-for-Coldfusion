<cfcomponent name="databaseTest" extends="mxunit.framework.TestCase">
	

	<cffunction name="testInit" access="public" returnType="void">
		<cfscript>
			assertTrue(structKeyExists(this.databaseObj, "init"), "init() should exist");

			// act
			var result = this.databaseObj.init();

			// assert
			assertTrue(isObject(result), "init() should return an object");
		</cfscript>
	</cffunction>


	<cffunction name="testAll_dbs" access="public" returnType="void">
		<cfscript>
			assertTrue(structKeyExists(this.databaseObj, "all_dbs"), "all_dbs() should exist");

			// act
			var result = this.databaseObj.all_dbs();
			var resultObj = deserializeJSON(result);

			// assert
			assertTrue(isArray(resultObj), "all_dbs() should return an array");
			assertTrue(arrayContains(resultObj, this.database_params.db_name), "array should contain this db_name");
		</cfscript>
	</cffunction>


	<cffunction name="testCreate" access="public" returnType="void">
		<cfscript>
			assertTrue(structKeyExists(this.databaseObj, "create"), "create() should exist");

			// prepare
			this.databaseObj.delete();

			// act
			var result = this.databaseObj.create();

			// assert
			assertTrue(result, "create() should return true.");
			assertTrue(this.databaseObj.exists(), "database should exist now");
		</cfscript>
	</cffunction>


	<cffunction name="testDelete" access="public" returnType="void">
		<cfscript>
			assertTrue(structKeyExists(this.databaseObj, "delete"), "delete() should exist");

			// act
			var result = this.databaseObj.delete();

			// assert
			assertTrue(result, "delete() should result true.");
			assertFalse(this.databaseObj.exists(), "database should not exist anymore");
		</cfscript>
	</cffunction>


	<cffunction name="testInfo" access="public" returnType="void">
		<cfscript>
			assertTrue(structKeyExists(this.databaseObj, "info"), "info() should exist");

			// act
			var result = this.databaseObj.info();
			var resultObj = deserializeJSON(result);

			// assert
			assertTrue(isStruct(resultObj), "info() should return a struct");
			assertTrue(structKeyExists(resultObj, "db_name"), "info struct should contain a 'db_name' key.");
			assertEquals(resultObj.db_name, this.database_params.db_name, "db_name should match");
		</cfscript>
	</cffunction>


	<cffunction name="testExists" access="public" returnType="void">
		<cfscript>
			assertTrue(structKeyExists(this.databaseObj, "exists"), "exists() should exist");

			// assert: database exists
			assertTrue(this.databaseObj.exists(), "exists() should return true");

			// act: delete database
			this.databaseObj.delete();

			// assert: database doesn't exist
			assertFalse(this.databaseObj.exists(), "exists() should return false");
		</cfscript>
	</cffunction>


	<cffunction name="testChanges" access="public" returnType="void">
		<cfscript>
			assertTrue(structKeyExists(this.databaseObj, "changes"), "changes() should exist");

			// act
			var result = this.databaseObj.changes();
			var resultObj = deserializeJSON(result);

			// assert
			assertTrue(isStruct(resultObj), "result should be a struct");
			assertTrue(structKeyExists(resultObj, "results"), "result struct should contain a 'results' key");
			assertTrue(isArray(resultObj.results), "results element should be an array");
		</cfscript>
	</cffunction>


	<cffunction name="testCompact" access="public" returnType="void">
		<cfscript>
			assertTrue(structKeyExists(this.databaseObj, "compact"), "compact() should exist");

			// act
			var result = this.databaseObj.compact();

			// assert
			assertTrue(result, "compact() should return true");
		</cfscript>
	</cffunction>


	<!--- setup and teardown --->
	
	<cffunction name="setUp" returntype="void" access="public">
		<cfscript>
			this.database_params = {
				db_name = 'couch4cf_unit_tests',
				couch_port = 5984,
				couch_host = '127.0.0.1'
			};
			this.databaseObj = createObject('component','couch4cf.database').init(argumentCollection = this.database_params);
			// create database
			if(!this.databaseObj.exists())
				this.databaseObj.create();
		</cfscript>
	</cffunction>


	<cffunction name="tearDown" returntype="void" access="public">
		<cfscript>
			// get rid of this database
			if(this.databaseObj.exists())
				this.databaseObj.delete();
		</cfscript>
	</cffunction>
</cfcomponent>
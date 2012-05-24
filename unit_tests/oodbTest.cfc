<cfcomponent name="oodbTest" extends="mxunit.framework.TestCase">
	

	<cffunction name="testInit" access="public" returnType="void">
		<cfscript>
			assertTrue(structKeyExists(this.oodb, "init"), "init() should exist");

			// act
			var result = this.oodb.init();

			// assert
			assertTrue(isObject(result), "init() should return an object");
		</cfscript>
	</cffunction>


	<cffunction name="testSaveToCreate" access="public" returnType="void">
		<cfscript>
			assertTrue(structKeyExists(this.oodb, "save"), "save() should exist");

			// act
			var objectID = this.OODB.save(this.myObject);

			// assert
			var document = this.documentObj.load(objectID);
			var docObj = deserializeJSON(document);
			assertTrue(isStruct(docObj), "save() should create a document that can be loaded");
		</cfscript>
	</cffunction>


	<cffunction name="testSaveToUpdate" access="public" returnType="void">
		<cfscript>
			assertTrue(structKeyExists(this.oodb, "save"), "save() should exist");

			// prepare
			var objectID = this.OODB.save(this.myObject);

			var myObj2 = createObject('component','couch4cf.unit_tests.myClass');
			this.OODB.load(myObj2, objectID);
			myObj2.newVar = true;

			// act
			var result = this.OODB.save(myObj2, objectID);

			// assert
			var document2 = this.documentObj.load(objectID);
			var docObj2 = deserializeJSON(document2);
			assertTrue(structKeyExists(docObj2.this, "newVar"), "Updated document should now contain a new variable.");
		</cfscript>
	</cffunction>


	<cffunction name="testLoad" access="public" returnType="void">
		<cfscript>
			assertTrue(structKeyExists(this.oodb, "load"), "load() should exist");

			// prepare
			this.myObject.save_me = true;
			var objectID = this.OODB.save(this.myObject);
			var myNewObject = createObject("component","couch4cf.unit_tests.myClass");

			// act
			this.OODB.load(myNewObject, objectID);

			// assert
			assertTrue(structKeyExists(myNewObject, "save_me"), "load() should populate myNewObject with previously saved data");
		</cfscript>
	</cffunction>


	<cffunction name="testDelete" access="public" returnType="void">
		<cfscript>
			assertTrue(structKeyExists(this.oodb, "delete"), "delete() should exist");

			// act: delete() something that doesn't exist
			var result = this.OODB.delete("should_not_exist");

			// assert: delete() something that doesn't exist
			assertFalse(result, "delete() should return false");


			// prepare: delete() an existing record
			var objectID = this.OODB.save(this.myObject);

			// act: delete() an existing record
			var result = this.OODB.delete(objectID);

			// assert: delete() an existing record
			assertTrue(result, "delete() should return true");
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

			this.oodb = createObject('component','couch4cf.oodb').init(argumentCollection = this.database_params);

			this.documentObj = createObject('component','couch4cf.document').init(argumentCollection = this.database_params);

			this.myObject = createObject('component', 'couch4cf.unit_tests.myClass');
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

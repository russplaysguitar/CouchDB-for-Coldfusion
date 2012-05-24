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


	<cffunction name="testSave" access="public" returnType="void">
		<cfscript>
			assertTrue(structKeyExists(this.oodb, "save"), "save() should exist");

			// prepare
			var myObject = createObject('component', 'couch4cf.unit_tests.myClass');

			// act
			var objectID = this.OODB.save(myObject);
			var document = this.documentObj.load(objectID);
			var docObj = deserializeJSON(document);

			// assert
			assertTrue(isStruct(docObj), "save() created a document that was loaded");
		</cfscript>
	</cffunction>


	<cffunction name="testLoad" access="public" returnType="void">
		<cfscript>
			assertTrue(structKeyExists(this.oodb, "load"), "load() should exist");
		</cfscript>
	</cffunction>


	<cffunction name="testDelete" access="public" returnType="void">
		<cfscript>
			assertTrue(structKeyExists(this.oodb, "delete"), "delete() should exist");
		</cfscript>
	</cffunction>


	<cffunction name="testGetPrivates" access="public" returnType="void">
		<cfscript>
			makePublic(this.oodb,"getPrivates");
			assertTrue(structKeyExists(this.oodb, "getPrivates"), "getPrivates() should exist");
		</cfscript>
	</cffunction>


	<cffunction name="testGetPublics" access="public" returnType="void">
		<cfscript>
			makePublic(this.oodb,"getPublics");
			assertTrue(structKeyExists(this.oodb, "getPublics"), "getPublics() should exist");
		</cfscript>
	</cffunction>


	<cffunction name="testSetPrivates" access="public" returnType="void">
		<cfscript>
			makePublic(this.oodb,"setPrivates");
			assertTrue(structKeyExists(this.oodb, "setPrivates"), "setPrivates() should exist");
		</cfscript>
	</cffunction>


	<cffunction name="testSetPublics" access="public" returnType="void">
		<cfscript>
			makePublic(this.oodb,"setPublics");
			assertTrue(structKeyExists(this.oodb, "setPublics"), "setPublics() should exist");
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

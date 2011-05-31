
<cfcomponent name="documentTest" extends="mxunit.framework.TestCase">
	<!--- Begin specific tests --->

	<cffunction name="testCopy" access="public" returnType="void">
		<cfscript>
			this.docObj.create();
			new_id = this.docObj.copy();
			assertTrue(len(new_id),"Copy() returned a blank string");
			
			obj = createObject("component","couch4cf.document").init(argumentCollection = this.database_params);
			obj.load(new_id);
			assertTrue(obj.delete(),"Couldn't delete document copy");
			
		</cfscript>
	</cffunction>		
	
	<cffunction name="testCreate" access="public" returnType="void">
		<cfscript>
			create_result = this.docObj.create();
			assertTrue(len(create_result),"Create() returned blank string");
		</cfscript>
	</cffunction>	
	
	<cffunction name="testDecodeJSON" access="public" returnType="void">
		<cfscript>
			makePublic(this.docObj,'decodeJSON');
			result = this.docObj.decodeJSON('{"test":"decodeJSON"}');
			assertTrue(isStruct(result),"DecodeJSON() did not return a struct");
		</cfscript>
	</cffunction>		
	
	
	<cffunction name="testDelete" access="public" returnType="void">
		<cfscript>
			this.docObj.create();
			delete_result = this.docObj.delete();
			assertTrue(delete_result,"Delete() returned false");
		</cfscript>
	</cffunction>		
	
	
	<cffunction name="testDocument_exists" access="public" returnType="void">
		<cfscript>
			this.docObj.create();
			assertTrue(this.docObj.document_exists(),"Document_exists() returned false");
		</cfscript>
	</cffunction>		
	
	
	<cffunction name="testEncodeJSON" access="public" returnType="void">
		<cfscript>
			makePublic(this.docObj,'encodeJSON');
			result = this.docObj.encodeJSON({"test"="encodeJSON"});
			assertTrue(len(result),"encodeJSON() returned a blank string");
		</cfscript>
	</cffunction>		
	
	
	<cffunction name="testInit" access="public" returnType="void">
		<cfscript>
			obj = createObject("component","couch4cf.document").init(argumentCollection = this.database_params);
			assertIsTypeOf(obj,"couch4cf.document");
		</cfscript>
	</cffunction>		
	
	
	<cffunction name="testListToStruct" access="public" returnType="void">
		<cfscript>
			makePublic(this.docObj,'ListToStruct');
			result = this.docObj.ListToStruct("one,two");
			assertTrue(isStruct(result),"ListToStruct() didn't return a struct");
		</cfscript>
	</cffunction>		
	
	
	<cffunction name="testLoad" access="public" returnType="void">
		<cfscript>
			this.docObj.create();
			load_result = this.docObj.load();
			assertTrue(len(load_result),"Load() result is blank string");
		</cfscript>
	</cffunction>		
	
	
	<cffunction name="testNet_Socket" access="public" returnType="void">
		<cfscript>
			makePublic(this.docObj, 'Net_Socket');
			
			http_request[1] = "GET /#this.database_params.db_name#/#this.docObj.id# HTTP/1.1";
			http_request[2] = "TestLine2: SecondLine";
			cfhttp = this.docObj.Net_Socket(this.database_params.couch_host, this.database_params.couch_port, http_request);
			
			assertTrue(isStruct(cfhttp), "Result is not a struct");
			
			assertTrue(cfhttp.success, "Result was unsuccessful");
		</cfscript>
	</cffunction>		
	
	
	<cffunction name="testUpdate" access="public" returnType="void">
		<cfscript>
			this.docObj.create();
			this.docObj.data = '{"test":"update"}';
			update_result = this.docObj.update();
			assertTrue(len(update_result),"Update() returned a blank string");
		</cfscript>
	</cffunction>		
	
	
	<cffunction name="testValidateObject" access="public" returnType="void">
		<cfscript>
			makePublic(this.docObj, 'ValidateObject');
			this.docObj.validateObject();// this will throw an error if there is a problem
		</cfscript>
	</cffunction>		
	

	<!--- setup and teardown --->
	
	<cffunction name="setUp" returntype="void" access="public">
		<cfscript>
			this.database_params = {
				db_name = 'my_database',
				couch_port = 5984,
				couch_host = '127.0.0.1'
			};
			this.docObj = createObject("component","couch4cf.document").init(argumentCollection = this.database_params);	
			//this.docObj.id = createUUID();// (optional)
			this.docObj.data = '{"greetings":"hello world!!"}';	
		</cfscript>
	</cffunction>


	<cffunction name="tearDown" returntype="void" access="public">
		<!--- delete document from database (if it still exists) --->
		<cfscript>
			if(this.docObj.document_exists())
				this.docObj.delete();
		</cfscript>
	</cffunction>

</cfcomponent>


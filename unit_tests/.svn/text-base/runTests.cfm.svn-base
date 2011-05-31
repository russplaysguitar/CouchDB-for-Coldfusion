<!--- note: To run, you must update the "directory" and "componentPath" attributes --->

<cfinvoke component="mxunit.runner.DirectoryTestSuite"
          method="run"
          directory="#expandPath('/couch4cf/unit_tests/')#"
	  componentPath="couch4cf.unit_tests"
	  recurse="false"
      returnvariable="results" />

<cfoutput>#results.getResultsOutput('extjs')#</cfoutput>
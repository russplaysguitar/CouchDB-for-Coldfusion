<cfparam name="url.id" default="">
<cfparam name="url.do" default="">

<cfset OODB = createObject('component','CouchDB.OODB').init(argumentcollection = request.database_params)>
<cfset myPost = createObject('component','model.post')>

<!--- ACTIONS                                                       --->
<cfif url.id neq ''>
	<!--- load post --->
	<cfinvoke component="#OODB#" method="load" id="#url.id#" obj="#myPost#">
</cfif>

<cfif url.do eq 'write'>
    <cfset myPost.title = form.title>
    <cfset myPost.post = form.post>
    <cfset myPost.author = form.author>

    <cfif url.id neq ''>
		<!--- edit existing post --->
		<cfinvoke component="#OODB#" method="save" id="#url.id#" obj="#myPost#">
    <cfelse>
		<!--- create new post --->
		<cfinvoke component="#OODB#" method="save" obj="#myPost#" returnvariable="url.id">
    </cfif>
    
    <!--- relocate to front page --->
    <cflocation url="index.cfm" addtoken="no" />
</cfif>

<cfif url.do eq 'delete'>
    <!--- delete post --->
    <cfinvoke component="#OODB#" method="delete" id="#url.id#" obj="#myPost#">
    
    <!--- relocate to front page --->
    <cflocation url="index.cfm" addtoken="no" />
</cfif>



<!--- DISPLAY                                                            --->

<!DOCTYPE html>
<html>
	<head>
		<meta charset="utf-8" />
		<title>Example Blog Admin</title>
	</head>
<body>


<h1>Post Admin</h1>

<cfoutput>
<form method="post" action="?do=write&id=#url.id#">
	Title: <input name="title" type="text" value="#myPost.title#" /><br />
	Post: <textarea name="post" style="width:300px; height:100px;">#myPost.post#</textarea><br />
	Author: <input name="author" type="text" value="#myPost.author#" /><br />
	<input type="submit" /> 
	<cfif url.id neq ''>
    		<a href="?do=delete&id=#url.id#">delete</a>
	</cfif>
</form>
</cfoutput>

<br />
<a href="index.cfm">View Posts</a> | <a href="admin.cfm">New Post</a>

</body>
</html>
<cfparam name="url.view" default="all">
<cfparam name="url.key" default="">
<cfparam name="url.startkey" default="">
<cfparam name="url.endkey" default="">
<cfparam name="url.descending" default="true">
<cfparam name="url.limit" default="">


<!--- get view results --->
<cfset viewObj = createObject('component','CouchDB.view').init(argumentcollection = request.database_params)>
<cfinvoke component="#viewObj#" method="load" returnvariable="get_all_posts" 
	id="posts"
	view="#url.view#" 
	key="#url.key#" 
	startkey="#url.startkey#" 
	endkey="#url.endkey#" 
	descending="#url.descending#" 
	limit="#url.limit#"
	include_docs="false">

<cfset posts_array = deserializeJSON(get_all_posts).rows>


<!--- DISPLAY ---->

<!DOCTYPE html>
<HTML>
	<HEAD>
		<META CHARSET="utf-8" />
		<TITLE>Example Blog</TITLE>
	</HEAD>
<BODY>


<!--- loop over results array --->
<cfloop array="#posts_array#" index="item">

	<!--- instantiate new Post object --->
	<cfset myPost = createObject('component','model.post')>
	
	<!--- load Post object with data --->
	<!--- TODO: write a new OODB.cfc that models can extend, instead of using stateless OODB.cfc --->
	<cfset OODB = createObject('component','couchDB.OODB').init(argumentcollection = request.database_params)>
	<cfinvoke component="#OODB#" method="load" obj="#myPost#" id="#item.id#">
	
	<!--- display --->
	<cfoutput>
		<H3><A href="?view=post&key=#item.id#">#myPost.title#</A> - #dateformat(myPost.datestamp, 'medium')# #timeformat(myPost.datestamp, 'short')#</H3>
		<P>#myPost.post#</P>
		<I>Posted by: <A href="?view=author&key=#myPost.author#">#myPost.author#</A></I><BR />
		<A href="admin.cfm?id=#item.id#">edit</A>
	</cfoutput>
	<HR />

</cfloop>

<!--- no posts yet? --->
<cfif arraylen(posts_array) is 0>
	<H3>No posts yet!</H3>
	<B>Visit the <A href="admin.cfm">admin</A> to add some</B>
</cfif>

<BR />
<BR />
<A href="index.cfm">View Posts</A> | <A href="admin.cfm">New Post</A>

</BODY>
</HTML>
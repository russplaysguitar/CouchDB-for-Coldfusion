To set up the Coldfusion View Server for CouchDB (version 0.11):

1. Edit /etc/couchdb/local.ini
Edit and add the following:

[query_servers]
coldfusion = java -jar "D:/ColdFusion9/wwwroot/couch4cf/view_server/wget.jar" "http://localhost:8501/couch4cf/view_server/view_server.cfc?method=switch&returnformat=json&input="

(make sure that the paths match your particular set up)

2. Restart CouchDB


Notes:
- Currently the view server only supports CFscript. 
- Remember to name your design functions (CF requires function names, but JS does not)
- See /view_server/app_error.html if your CF view server isn't working
- See /var/log/couchdb/couch.log if app_error.html doesn't contain useful info
- Edit /etc/couchdb/local.ini and add the following for more verbose debug info in Couch.log:
[log]
level = debug
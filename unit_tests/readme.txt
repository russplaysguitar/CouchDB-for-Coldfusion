To run these unit tests: 

1) Install MXUnit: http://www.mxunit.org

2) Create a mapping to CouchDB-for-Coldfusion called "couch4cf"

3) Create a couchdb database called "couch4cf_unit_tests". Data in this database is subject to deletion, so please do not use a database with real (or any) data in it.

4) If your CouchDB instance is running on a non-default host or port, edit each unit test setup method accordingly. 

Notes:
These tests are a work-in-progress, so their success or failure does not necessarily indicate the health of this project. Please add some tests if you can!

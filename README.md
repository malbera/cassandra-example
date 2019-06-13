# cassandra-example

#Preconditions:
-	docker pull tobert/cassandra
-----

To deploy a single Cassandra node:
-	docker run --name=n1 -d tobert/cassandra
You need the IP of this first container:
-	docker inspect -f '{{ .NetworkSettings.IPAddress }}' n1

To add a nodes to the Cassandra cluster:
-	docker run --name=n2 -d tobert/cassandra -seeds IP
-	docker run --name=n3 -d tobert/cassandra -seeds IP

Check the status of the cluster:
-	docker exec -it n1 nodetool status

Virtual node token allocations:
-	docker exec -it n1 nodetool ring

View the configuration file with:
-	docker exec -it n1 /bin/bash
-	vi /data/conf/cassandra.yaml

Stop and remove containers:
-	docker stop n1 n2 n3; docker rm n1 n2 n3

-----

To deploy a single Cassandra node, specifying a datacenter and rack:
-	docker run --name n1 -d tobert/cassandra -dc DC1 -rack RAC1

To add nodes in a different rack:
-	docker run --name n1 -d tobert/cassandra -dc DC1 -rack RAC2 -seeds IP
-	docker run --name n3 -d tobert/cassandra -dc DC2 -rack RAC1 -seeds IP

Configuration file where the datacenter and rack info is stored:
-	docker exec -it n1 /bin/bash
	vi /data/conf/cassandra-rackdc.properties

You can run 'nodetool status' and 'nodetool ring' as before

Stop and remove containers:
-	docker stop n1 n2 n3; docker rm n1 n2 n3

-----

Three node cluster:
-	docker run --name=n1 -d tobert/cassandra
-	docker inspect -f '{{ .NetworkSettings.IPAddress }}' n1
-	docker run --name=n2 -d tobert/cassandra -seeds IP
-	docker run --name=n3 -d tobert/cassandra -seeds IP

Run cqlsh with:
-	docker exec -it n1 cqlsh

Create a keyspace:
-	    create keyspace cassandra_example_2 with replication = {'class':'SimpleStrategy', 'replication_factor':3};

Examine the token allocations for this keyspace:
-	docker exec -it n1 nodetool describering cassandra_example_2

Run nodetool status with name of the keyspace - each node "owns" 100% of the data:
-	docker exec -it n1 nodetool status cassandra_example_2

Now drop and recreate the keyspace with a different replication factor:
-	drop keyspace cassandra_example_2;
-	create keyspace cassandra_example_2 with replication = {'class':'SimpleStrategy', 'replication_factor’:1};

Run nodetool status - each node only "owns" about a third of the data:
-	docker exec -it n1 nodetool status cassandra_example_2

Run nodetool describering - each token range allocated only one endpoint:
-	docker exec -it nodetool describering cassandra_example_2
-	docker exec -it n1 nodetool ring | grep [end_token]

Stop and remove containers:
-	docker stop n1 n2 n3; docker rm n1 n2 n3

-----

Create a multi-DC cluster as follows:
-	docker run --name n1 -d tobert/cassandra -dc DC1 -rack RAC1
-	docker inspect -f '{{ .NetworkSettings.IPAddress }}' n1
-	docker run --name n2 -d tobert/cassandra -dc DC1 -rack RAC1 -seeds IP
-	docker run --name n3 -d tobert/cassandra -dc DC1 -rack RAC2 -seeds IP
-	docker run --name n4 -d tobert/cassandra -dc DC2 -rack RAC1 -seeds IP

Run cqlsh with:
-	docker exec -it n1 cqlsh

Create the cassandra_example_2 keyspace again, but this time with a different replication strategy:
-	create keyspace cassandra_example_2 with replication = {'class':'NetworkTopologyStrategy','DC1':2,'DC2':1}
-	docker exec -it n1 nodetool describering cassandra_example_2

Run nodetool status - node in DC2 owns all the data, as does the one node in RAC2 of DC1:
-	docker exec -it n1 nodetool status cassandra_example_2

Stop and remove containers:
-	docker stop n1 n2 n3 n4; docker rm n1 n2 n3 n4

-----

Create a three node cluster:
-       docker run --name=n1 -d tobert/cassandra
-       docker inspect -f '{{ .NetworkSettings.IPAddress }}' n1
-       docker run --name=n2 -d tobert/cassandra -seeds IP
-       docker run --name=n3 -d tobert/cassandra -seeds IP
-	docker exec -it n1 cqlsh

Create a keyspace:
-	create keyspace cassandra_example_3 with replication = {'class':'SimpleStrategy', 'replication_factor':3};
-	use cassandra_example_3;

Create one column table:
-	create table cassandra_lessons (id varchar primary key);

Check the current consistency:
-	consistency;

Insert a row:
-	insert into cassandra_lessons (id) values ('cassandra-developers');

Set the consistency level to "quorum":
-	consistency quorum;
-	insert into cassandra_lessons (id) values ('building-asynchronous-restful-services-jersey');

Set the consistency level to "all":
-	consistency all;
-	tracing on;
-	insert into cassandra_lessons (id) values ('node-intro');

Stop docker container:
-	docker stop n3

Set the consistency level to "all" and insert another row:
-	use cassandra_example_3;
-	consistency all;
-	insert into cassandra_lessons (id) values ('google-charts-by-example');

Set the consistency to "quorum":
-	consistency quorum;
-	insert into cassandra_lessons (id) values ('google-charts-by-example');

Select one of the inserted rows:
-	select * from cassandra_lessons where id = 'cassandra-developers';

Set the consistency level to "all":
-	consistency all
-	select * from cassandra_lessons where id = 'cassandra-developers';

Start docker container:
-	docker start n3

Set the consistency level to "all":
-	consistency all;
-	use cassandra_example_3;
-	select * from cassandra_lessons where id = 'cassandra-developers';

Stop and remove containers:
-	docker stop n1 n2 n3; docker rm n1 n2 n3

-----

Create a multi-DC cluster as follows:
-       docker run --name n1 -d tobert/cassandra -dc DC1 -rack RAC1
-       docker inspect -f '{{ .NetworkSettings.IPAddress }}' n1
-       docker run --name n2 -d tobert/cassandra -dc DC1 -rack RAC1 -seeds IP
-       docker run --name n3 -d tobert/cassandra -dc DC1 -rack RAC1 -seeds IP
-       docker run --name n4 -d tobert/cassandra -dc DC2 -rack RAC1 -seeds IP


Create the keyspace with NetworkTopologyStrategy:
-	create keyspace cassandra_example_2 with replication = {'class':'NetworkTopologyStrategy', 'DC1':3,'DC2':1};
-	use cassandra_example_2;
-	create table cassandra_lessons (id varchar primary key);

Set the consistency level to "local_one" and insert a row into the table:
-	consistency local_one;
-	insert into cassandra_lessons (id) values ('cassandra-developers');

Take down the one node in DC2:
-	docker stop n4

Run nodetool status and verify that Cassandra treats this node as "down"
-	docker exec - it n1 nodetool status

Set the consistency to "each_quorum" and try to insert:
-	use cassandra_example_2;
-	consistency each_quorum;
-	insert into cassandra_lessons (id) values ('node-intro');

Set the consistency to "local_quorum" and try to insert:
-	consistency local_quorum;
-	insert into cassandra_lessons (id) values ('node-intro');

Stop and remove containers:
-	docker stop n1 n2 n3 n4; docker rm n1 n2 n3 n4

-----

Run single node:
-	docker run --name n1 -d tobert/cassandra

Go to console:
-	docker exec -it n1 cqlsh

Create a keyspace and table:
-	create keyspace cassandra_example_3 with replication = {'class':'SimpleStrategy', 'replication_factor':1};
-	use cassandra_example_3;
-	create table courses (id varchar primary key);
-	create table if not exists courses (id varchar primary key);

Add columns:
-	alter table courses add duration int;
-	alter table courses add released timestamp;
-	alter table courses add author varchar;
-	alter table courses with comment = 'A table of courses';

Check table description:
-	desc table courses;

Drop table and recreate complete:
-	drop table courses;
-	create table courses (
        id varchar primary key,
        name varchar,
        author varchar,
        audience int,
        duration int,
        cc boolean,
        released timestamp
        ) with comment = 'A table of courses';

View complete description:
-	desc table courses;

-----

Run cassandra mounting volume:
-	docker run --name n1 -v $PWD/scripts:/scripts -d tobert/cassandra

Verify that the container has access to scripts folder:
-	docker exec -it n1 /bin/bash
-	ls /scripts
-	exit

Init courses.cql
-	docker exec -it n1 cqlsh
-	source '/scripts/example_3/courses.cql'
-	use cassandra_example_3;
-	desc tables;
-	select * from courses;

-----

Writetime function:
-	select id, cc, writetime(cc) from courses where id = 'advanced-javascript';

Update statement:
-	update courses set cc = true where id = 'advanced-javascript';

-----

Function for returning the token associated with a partition key:
-	select id, token(id) from courses;

-----

Error if select not primary key:
-	select * from courses where author = 'Adron Hall';

-----

Create users table:
-	create table users (
        id varchar primary key,
        first_name varchar,
        last_name varchar,
        email varchar,
        password varchar
        ) with comment = 'A table of users';

Insert and upsert two rows:
-	insert into users (id, first_name, last_name) values ('john-doe', 'John', 'Doe');
-	update users set first_name = 'Jane', last_name = 'Doe' where id = 'jane-doe';
-	select * from users;

Add new column with ttl:
-	alter table users add reset_token varchar;
-	update users using ttl 120 set reset_token = 'abc123' where id = 'john-doe';

To retrieve remaining ttl:
-	select ttl(reset_token) from users where id = 'john-doe';

Enable tracking - there are no tombstones:
-	tracing on;
-	select * from users where id = 'john-doe';

Repeat operation after ttl - discover tombstone

-----

Create a ratings table with two counter columns:
-	create table ratings (
        course_id varchar primary key,
        ratings_count counter,
        ratings_total counter
        ) with comment = 'A table of course ratings';

Increment both counter columns:
-	update ratings set ratings_count = ratings_count + 1, ratings_total = ratings_total + 4 where course_id = 'node-intro';
-	select * from ratings;

Add second course raiting of 3:
-	update ratings set ratings_count = ratings_count + 1, ratings_total = ratings_total + 3 where course_id = 'node-intro';
-	select * from ratings;

-----

From cqlsh, run the "source" to load the "courses.cql"
-	source '/scripts/example_4/courses.cql';
- use cassandra_example_4;
-	desc table courses;

Select data from table:
-	select * from courses;

Drop this table and create a new one:
-	drop table courses;
-	create table courses (
    id varchar,
    name varchar,
    author varchar,
    audience int,
    duration int,
    cc boolean,
    released timestamp,
    module_id int,
    module_name varchar,
    module_duration int,
    primary key (id, module_id)
) with comment = 'A table of courses and modules';

Insert data for the course:
- insert into courses (id, name, author, audience, duration, cc, released, module_id, module_name, module_duration)
values ('node-intro','Introduction to Node.js','Paul O''Fallon', 2, 10080, true, '2012-12-19',1,'Getting Started with Node.js',2174);
- insert into courses (id, name, author, audience, duration, cc, released, module_id, module_name, module_duration)
values ('node-intro','Introduction to Node.js','Paul O''Fallon', 2, 10080, true, '2012-12-19',2,'Modules, require() and NPM',1063);

Select data:
- select * from courses;
-	select * from courses where id = 'node-intro';

Include id and module_id in where clause:
- select * from courses where id = 'node-intro' and module_id = 2;

We can't select by module, unless we enable 'ALLOW FILTERING'
-	select * from courses where module_id = 2;                  // fails
-	select * from courses where module_id = 2 allow filtering   // succeeds

Now insert the remaining data:
-	insert into courses (id, name, author, audience, duration, cc, released, module_id, module_name, module_duration)
values ('node-intro','Introduction to Node.js','Paul O''Fallon', 2, 10080, true, '2012-12-19', 3, 'Events and Streams', 1595);
-	insert into courses (id, name, author, audience, duration, cc, released, module_id, module_name, module_duration)
values ('node-intro','Introduction to Node.js','Paul O''Fallon', 2, 10080, true, '2012-12-19', 4, 'Accessing the Local System', 1040);
- insert into courses (id, name, author, audience, duration, cc, released, module_id, module_name, module_duration)
values ('node-intro','Introduction to Node.js','Paul O''Fallon', 2, 10080, true, '2012-12-19', 5, 'Interacting with the Web', 1300);
- insert into courses (id, name, author, audience, duration, cc, released, module_id, module_name, module_duration)
values ('node-intro','Introduction to Node.js','Paul O''Fallon', 2, 10080, true, '2012-12-19', 6, 'Testing and Debugging', 1658);
- insert into courses (id, name, author, audience, duration, cc, released, module_id, module_name, module_duration)
values ('node-intro','Introduction to Node.js','Paul O''Fallon', 2, 10080, true, '2012-12-19', 7, 'Scaling Your Node Application', 1257);

Use module_id as part of an "in" clause
-	select * from courses where id = 'node-intro' and module_id in (2,3,4);

Order by module_id
-	select * from courses where id = 'node-intro' order by module_id desc;

We can "select disinct" just the id, but not the id and course name:
- select distinct id from courses;         // succeeds
- select distinct id, name from courses;   // fails

-----

From cqlsh, drop and recreate the courses table:
-	use cassandra_example_4;
-	drop table courses;
-	create table courses (
    id varchar,
    name varchar static,
    author varchar static,
    audience int static,
    duration int static,
    cc boolean static,
    released timestamp static,
    module_id int,
    module_name varchar,
    module_duration int,
    primary key (id, module_id)
) with comment = 'A table of courses and modules';

Insert course data, and select it back:
-	insert into courses (id, name, author, audience, duration, cc, released)
    values ('node-intro','Introduction to Node.js','Paul O''Fallon', 2, 10080, true, '2012-12-19');
- select * from courses where id = 'node-intro';
-	insert into courses (id, module_id, module_name, module_duration)
values ('node-intro',1,'Getting Started with Node.js',2174);
-	insert into courses (id, module_id, module_name, module_duration)
values ('node-intro',2,'Modules, require() and NPM',1063);

Selecting from courses now returns both course and module data in each row:
- select * from courses where id = 'node-intro';
- select * from courses where id = 'node-intro' and module_id = 2;

Insert the third module:
-	insert into courses (id, name, module_id, module_name, module_duration)
values ('node-intro', 'Intro to Node', 3, 'Events and Streams', 1595);
- select * from courses where id = 'node-intro';

Insert the fourth module, and fix the course name:
- insert into courses (id, name, module_id, module_name, module_duration)
values ('node-intro', 'Introduction to Node.js', 4, 'Accessing the Local System', 1040);

Insert the remaining course modules:
- insert into courses (id, module_id, module_name, module_duration)
values ('node-intro', 5, 'Interacting with the Web', 1300);
- insert into courses (id, module_id, module_name, module_duration)
values ('node-intro', 6, 'Testing and Debugging', 1658);
- insert into courses (id, module_id, module_name, module_duration)
values ('node-intro', 7, 'Scaling Your Node Application', 1257);

The 'in' and 'order by' clauses work the same as before:
-	select * from courses where id = 'node-intro' and module_id in (2,3,4);
-	select * from courses where id = 'node-intro' order by module_id desc;

Select course info:
-	select id, name, author, audience, duration, cc, released from courses;

Now "select distinct" course:
-	select distinct id, name, author, audience, duration, cc, released from courses;

Select just the module information:
-	select module_id, module_name, module_duration from courses where id = 'node-intro';

-----

cqlsh run the "source" command:
- source '/scripts/m4/courses.cql';

Select module information:
-	select module_id, module_name, module_description from courses where id = 'advanced-javascript';
- select module_id, module_name, module_description from courses where id = 'docker-fundamentals';

Select just the course-level information for all 5 courses:
-	select distinct id, name, author from courses;

-----

cqlsh create new table:
-	use cassandra_example_4;
-	create table course_page_views (
    course_id varchar,
    view_id timeuuid,
    primary key (course_id, view_id)
) with clustering order by (view_id desc);

Insert row using "now()" include a one year TTL:
-	insert into course_page_views (course_id, view_id) values ('node-intro', now()) using TTL 31536000;

Insert row, manually generated v1 UUID (also with a TTL):
-	insert into course_page_views (course_id, view_id)
    values ('node-intro', 40664856-1ad2-11e5-b60b-1697f925ec7b) using TTL 31536000;

Insert two more rows using "now()":
-	insert into course_page_views (course_id, view_id)
    values ('node-intro', now()) using TTL 31536000;
-	insert into course_page_views (course_id, view_id)
    values ('node-intro', now()) using TTL 31536000;

Select rows, use dateOf() to extract the date/time portion:
-	select * from course_page_views;
- select dateOf(view_id) from course_page_views where course_id = 'node-intro';

Reverse the date order:
-	select dateOf(view_id) from course_page_views where course_id = 'node-intro' order by view_id asc;

Select only those dates based on timeuuids that span a 2 day range:
-	select dateOf(view_id) from course_page_views where course_id = 'node-intro'
    and view_id >= maxTimeuuid('2015-06-26 00:00+0000')
    and view_id < minTimeuuid('2015-06-28 00:00+0000');

Truncate the table, and add a static column:
-	truncate course_page_views;
-	alter table course_page_views add last_view_id timeuuid static;

Insert rows using "now()" for both Timeuuids (with TTLs):
-	insert into course_page_views (course_id, last_view_id, view_id)
    values ('node-intro', now(), now()) using TTL 31536000;
-	insert into course_page_views (course_id, last_view_id, view_id)
    values ('node-intro', now(), now()) using TTL 31536000;
-	insert into course_page_views (course_id, last_view_id, view_id)
    values ('node-intro', now(), now()) using TTL 31536000;

Selecting all rows shows different view_ids but the same last_view_id for all rows
-	select * from course_page_views;

Use 'select distinct' to get just the latest page view for this course:
-	select distinct course_id, last_view_id from course_page_views;

For just one course, this can also be accomplished with the view_id and a LIMIT clause:
-	select course_id, view_id from course_page_views where course_id = 'node-intro' limit 1;

However, a 'limit' won't work across multiple courses.  Insert multiple views for another course:
-	insert into course_page_views (course_id, last_view_id, view_id)
    values ('advanced-javascript', now(), now()) using TTL 31536000;
-	insert into course_page_views (course_id, last_view_id, view_id)
    values ('advanced-javascript', now(), now()) using TTL 31536000;
-	insert into course_page_views (course_id, last_view_id, view_id)
    values ('advanced-javascript', now(), now()) using TTL 31536000;

Select latest view_id from each course, using the limit clause:
-	select course_id, view_id from course_page_views where course_id = 'node-intro' limit 1;
-	select course_id, view_id from course_page_views where course_id = 'advanced-javascript' limit 1;

Retrieve the latest course page view for all courses with 'select distinct' and the static column:
-	select distinct course_id, last_view_id from course_page_views;

Select all the individual views for each course, one at a time:
-	select course_id, view_id from course_page_views where course_id = 'node-intro';
-	select course_id, view_id from course_page_views where course_id = 'advanced-javascript';

-----

From cqlsh, create a new table to hold clickstream data:
-	use cassandra_example_4;
-	create table clickstream (
    year int,
    month int,
    click_id timeuuid,
    ip inet,
    url text,
    primary key ((year, month), click_id)
) with clustering order by (click_id desc);

Insert some data into this table, as if the clicks happened:
-	insert into clickstream (year, month, click_id, ip, url)
    values (2015, 5, now(), '98.203.153.64', 'http://www.pornhub.com');
-	insert into clickstream (year, month, click_id, ip, url)
    values (2015, 5, now(), '98.203.153.64', 'http://www.pornhub.com');
-	insert into clickstream (year, month, click_id, ip, url)
    values (2015, 5, now(), '98.203.153.64', 'http://www.pornhub.com');
-	insert into clickstream (year, month, click_id, ip, url)
    values (2015, 6, now(), '98.203.153.64', 'http://www.pornhub.com');
- insert into clickstream (year, month, click_id, ip, url)
    values (2015, 6, now(), '98.203.153.64', 'http://www.pornhub.com');
-	insert into clickstream (year, month, click_id, ip, url)
    values (2015, 6, now(), '98.203.153.64', 'http://www.pornhub.com');
-	insert into clickstream (year, month, click_id, ip, url)
    values (2015, 7, now(), '98.203.153.64', 'http://www.pornhub.com');
-	insert into clickstream (year, month, click_id, ip, url)
    values (2015, 7, now(), '98.203.153.64', 'http://www.pornhub.com');
-	insert into clickstream (year, month, click_id, ip, url)
    values (2015, 7, now(), '98.203.153.64', 'http://www.pornhub.com');

Select all rows, then limit the results to 10
-	select * from clickstream;
-	select * from clickstream limit 10;

Select 10 rows for months (7,6):
-	select * from clickstream where year = 2015 and month in (7,6) limit 10;

Include month = 5 to get back (10, 6) rows:
-	select * from clickstream where year = 2015 and month in (7,6,5) limit 10;
-	select * from clickstream where year = 2015 and month in (6,7) limit 6;

-----

cqlsh drop and recreate the clickstream table:
-	use cassandra_example_4;
-	drop table clickstream;
-	create table clickstream (
    bucket_id varchar,
    click_id timeuuid,
    ip inet,
    url text,
    primary key (bucket_id, click_id)
) with clustering order by (click_id desc);

Now insert a rows:
-	insert into clickstream (bucket_id, click_id, ip, url)
    values ('2015-12', now(), '98.203.153.64', 'http://www.pornhub.com');
-	insert into clickstream (bucket_id, click_id, ip, url)
    values ('2016-01', now(), '98.203.153.64', 'http://www.pornhub.com');    

With this bucket_id, we can now select across year boundaries
-	select * from clickstream where bucket_id in ('2016-01', '2015-12');

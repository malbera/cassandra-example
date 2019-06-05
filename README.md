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

Create the pluralsight keyspace again, but this time with a different replication strategy:
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

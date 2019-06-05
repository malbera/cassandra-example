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

Stop and remove the Cassandra containers:
-	docker stop n1 n2 n3
-	docker rm n1 n2 n3


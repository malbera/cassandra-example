-- Create and use keyspace
DROP KEYSPACE IF EXISTS cassandra_example_3;
CREATE KEYSPACE cassandra_example_3
WITH replication = {'class':'SimpleStrategy','replication_factor':1};

USE cassandra_example_3;

-- Create courses table
CREATE TABLE courses (
  id varchar primary key,
  name varchar,
  author varchar,
  audience int,
  duration int,
  cc boolean,
  released timestamp
) WITH comment = 'A table of courses';

-- Sample data for courses table
INSERT INTO courses (id, name, author, audience, duration, cc, released)
VALUES ('angularjs-get-started','AngularJS: Get Started', 'Scott Allen', 1, 10560, true, '2014-06-05');

INSERT INTO courses (id, name, author, audience, duration, cc, released)
VALUES ('node-intro','Introduction to Node.js', 'Paul O''Fallon', 2, 10080, true, '2012-12-19');

INSERT INTO courses (id, name, author, audience, duration, cc, released)
VALUES ('advanced-javascript','Advanced Javascript', 'Kyle Simpson', 2, 24900, false, '2015-04-09');

INSERT INTO courses (id, name, author, audience, duration, cc, released)
VALUES ('docker-fundamentals','Docker Fundamentals', 'Adron Hall', 2, 3780, true, '2014-01-10');

INSERT INTO courses (id, name, author, audience, duration, cc, released)
VALUES ('raspberry-pi-for-developers','Raspberry Pi for Developers', 'Jon Flanders', 2, 8640, true, '2013-05-30');

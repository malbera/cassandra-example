-- Create and use keyspace
DROP KEYSPACE IF EXISTS cassandra_example_4;
CREATE KEYSPACE cassandra_example_4
WITH replication = {'class':'SimpleStrategy','replication_factor':1};

USE cassandra_example_4;

-- Create courses table
CREATE TABLE courses(
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
  PRIMARY KEY (id, module_id)
) WITH comment = 'A table of courses';

-- Sample data for courses table
INSERT INTO courses (id, name, author, audience, duration, cc, released)
VALUES ('angularjs-get-started','AngularJS: Get Started', 'Scott Allen', 1, 10560, true, '2014-06-05');

  INSERT INTO courses (id, module_id, module_name, module_duration)
  VALUES ('angularjs-get-started', 1, 'An Introduction', 2083);

  INSERT INTO courses (id, module_id, module_name, module_duration)
  VALUES ('angularjs-get-started', 2, 'Controllers', 2143);

  INSERT INTO courses (id, module_id, module_name, module_duration)
  VALUES ('angularjs-get-started', 3, 'Directives and Views', 2024);

  INSERT INTO courses (id, module_id, module_name, module_duration)
  VALUES ('angularjs-get-started', 4, 'Services', 2144);

  INSERT INTO courses (id, module_id, module_name, module_duration)
  VALUES ('angularjs-get-started', 5, 'Routing', 2211);

INSERT INTO courses (id, name, author, audience, duration, cc, released)
VALUES ('node-intro','Introduction to Node.js', 'Paul O''Fallon', 2, 10080, true, '2012-12-19');

  INSERT INTO courses (id, module_id, module_name, module_duration)
  VALUES ('node-intro', 1, 'Getting Started with Node.js', 2174);

  INSERT INTO courses (id, module_id, module_name, module_duration)
  VALUES ('node-intro', 2, 'Modules, require() and NPM', 1063);

  INSERT INTO courses (id, module_id, module_name, module_duration)
  VALUES ('node-intro', 3, 'Events and Streams', 1595);

  INSERT INTO courses (id, module_id, module_name, module_duration)
  VALUES ('node-intro', 4, 'Accessing the Local System', 1040);

  INSERT INTO courses (id, module_id, module_name, module_duration)
  VALUES ('node-intro', 5, 'Interacting with the Web', 1300);

  INSERT INTO courses (id, module_id, module_name, module_duration)
  VALUES ('node-intro', 6, 'Testing and Debugging', 1658);

  INSERT INTO courses (id, module_id, module_name, module_duration)
  VALUES ('node-intro', 7, 'Scaling Your Node Application', 1257);

INSERT INTO courses (id, name, author, audience, duration, cc, released)
VALUES ('advanced-javascript','Advanced Javascript', 'Kyle Simpson', 2, 24900, false, '2015-04-09');

  INSERT INTO courses (id, module_id, module_name, module_duration)
  VALUES ('advanced-javascript', 1, 'Introduction', 2408);

  INSERT INTO courses (id, module_id, module_name, module_duration)
  VALUES ('advanced-javascript', 2, 'Scope', 9914);

  INSERT INTO courses (id, module_id, module_name, module_duration)
  VALUES ('advanced-javascript', 3, 'Closure', 2801);

  INSERT INTO courses (id, module_id, module_name, module_duration)
  VALUES ('advanced-javascript', 4, 'Object Orienting', 6376);

  INSERT INTO courses (id, module_id, module_name, module_duration)
  VALUES ('advanced-javascript', 5, 'Async Patterns', 3437);

INSERT INTO courses (id, name, author, audience, duration, cc, released)
VALUES ('docker-fundamentals','Docker Fundamentals', 'Adron Hall', 2, 3780, true, '2014-01-10');

  INSERT INTO courses (id, module_id, module_name, module_duration)
  VALUES ('docker-fundamentals', 1, 'Introduction and History', 1155);

  INSERT INTO courses (id, module_id, module_name, module_duration)
  VALUES ('docker-fundamentals', 2, 'Getting Started', 735);

  INSERT INTO courses (id, module_id, module_name, module_duration)
  VALUES ('docker-fundamentals', 3, 'Using Docker', 903);

  INSERT INTO courses (id, module_id, module_name, module_duration)
  VALUES ('docker-fundamentals', 4, 'Working Samples', 1003);

INSERT INTO courses (id, name, author, audience, duration, cc, released)
VALUES ('raspberry-pi-for-developers','Raspberry Pi for Developers', 'Jon Flanders', 2, 8640, true, '2013-05-30');

  INSERT INTO courses (id, module_id, module_name, module_duration)
  VALUES ('raspberry-pi-for-developers', 1, 'Introduction to Raspberry Pi', 1765);

  INSERT INTO courses (id, module_id, module_name, module_duration)
  VALUES ('raspberry-pi-for-developers', 2, 'Programming the Raspberry Pi', 2250);

  INSERT INTO courses (id, module_id, module_name, module_duration)
  VALUES ('raspberry-pi-for-developers', 3, 'Raspberry Pi and Hardware', 1877);

  INSERT INTO courses (id, module_id, module_name, module_duration)
  VALUES ('raspberry-pi-for-developers', 4, 'Raspberry Pi as a Web Server', 1592);

  INSERT INTO courses (id, module_id, module_name, module_duration)
  VALUES ('raspberry-pi-for-developers', 5, 'Raspberry Pi as a DVR', 1197);

CREATE KEYSPACE IF NOT EXISTS cassandra_example_3
WITH replication = {'class':'SimpleStrategy','replication_factor':1};

USE cassandra_example_3;

create table users (
    id varchar primary key,
    first_name varchar,
    last_name varchar,
    email varchar,
    password varchar,
    reset_token varchar
) with comment = 'A table of users';

insert into users (id, first_name, last_name, email)
values ('john-doe', 'John', 'Doe', 'john@doe.com');

insert into users (id, first_name, last_name, email)
values ('jane-doe', 'Jane', 'Doe', 'jane@doe.com');

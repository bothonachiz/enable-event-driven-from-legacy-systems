# Kafka Streams Foreign Key Joins

Copied from the repository [debezium-examples](https://github.com/debezium/debezium-examples/tree/main/kstreams-fk-join)

## Building

Prepare the Java components by first performing a Maven build.

```sh
$ mvn clean package -f aggregator/pom.xml
```

## Start the demo  

Start all components:

```sh
$ docker-compose up --build
```

This executes all configurations set forth by the `docker-compose.yaml` file.

## Configure the Debezium connector

Register the connector that to stream outbox changes from the order service: 

```sh
$ curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d @register-postgres.json
```

## Review the outcome

Launch the Kafdrop:


Click here!: [Kafdrop](http://localhost:9000/)


E.g. to update a customer record:

```sql
select * from inventory.customers;
```

```sql
update inventory.customers set first_name = 'Sarah' where id = 1001;
```

```sql
delete from inventory.addresses where id = IN (100004, 100005);
```
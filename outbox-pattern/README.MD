# Following these steps

## Start Mysql, Zookeeper, Kafka, Debezium-Kafka-Connect
```sh
docker compose up --build
```

## Verify connector
```sh
curl -H "Accept:application/json" localhost:8083/connectors
```

## Register connector
```sh
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" localhost:8083/connectors/ -d @connectors/tms-connector.json
```

## Verify tms-connector
```sh
curl -H "Accept:application/json" localhost:8083/connectors/tms-connector
```

## Watching the messages by consuming the kafka-topic
[Open the Kafdrop](http://localhost:9000)

## Try to create new record
```sql
INSERT INTO vehicles (licensePlate, licensePlateState, wheelCount) VALUES ('ABC123', 'Florida', 6), ('CD1990', 'Colorado', 10);
```

## Try to update record
```sql
UPDATE vehicles SET wheelCount = 22 WHERE id = 3; 
```

## Try to delete record
```sql
DELETE FROM vehicles WHERE id = 4;
```

## Try to stop kafka-connect container
```sh
docker compose stop connect
```

## And then making transaction again
```sql
DELETE FROM vehicles WHERE id = 3;
```

## Start kafka-connect again then watch the consumer, It will be receive only new transactions
[Open the Kafdrop](http://localhost:9000)
```sh 
docker compose up connect
```
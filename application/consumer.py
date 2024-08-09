from kafka import KafkaConsumer
import json

consumer = KafkaConsumer(
    'my_topic',
    bootstrap_servers=['<KAFKA_BROKER>:<KAFKA_PORT>'],
    auto_offset_reset='earliest',
    enable_auto_commit=True,
    group_id='my-group',
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

for message in consumer:
    print(f"Received message: {message.value}")

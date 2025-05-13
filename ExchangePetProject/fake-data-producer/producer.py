from kafka import KafkaProducer
import json
import time
import random

producer = KafkaProducer(
    bootstrap_servers='kafka:9092',
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

topic = 'currency-delta-topic'

while True:
    data = {
            'currency_code': random.choice(["USD", "EUR", "PLN", "AUD"]),
            'changed_delta': round(random.uniform(0.1, 1.0), 2),
        }
    producer.send(topic, data)
    print(f"Produced: {data}")
    time.sleep(30)
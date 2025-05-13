from kafka import KafkaProducer
from faker import Faker
import json
import time
import random
    
fake = Faker()

producer = KafkaProducer(
    bootstrap_servers='kafka:9092',
    value_serializer=lambda v: json.dumps(v).encode('utf-8')
)

topic = 'currency-delta-topic'

while True:
    data = {
            'currency_name': fake.currency_name(),
            'currency_code': fake.currency_code(),
            'changed_delta': round(random.uniform(0.1, 1.0), 2),
        }
    producer.send(topic, data)
    print(f"Produced: {data}")
    time.sleep(30)
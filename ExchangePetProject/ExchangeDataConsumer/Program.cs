using Confluent.Kafka;

var config = new ConsumerConfig
{
    BootstrapServers = "kafka:9092",
    GroupId = "my-consumer-group",
    AutoOffsetReset = AutoOffsetReset.Earliest
};

using var consumer = new ConsumerBuilder<Ignore, string>(config).Build();
consumer.Subscribe("currency-delta-topic");

Console.WriteLine("Kafka consumer started...");

while (true)
{
    var cr = consumer.Consume();
    Console.WriteLine($"Received: {cr.Message.Value}");
}
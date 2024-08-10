import logging

from kafka import KafkaConsumer


logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers = [logging.StreamHandler()],
)

logger = logging.getLogger("KafkaConsumer")


if __name__ == '__main__':
    consumer = KafkaConsumer(
        "lectures",
        bootstrap_servers="kafka.default.svc.cluster.local:9092",
        auto_offset_reset="earliest",
        enable_auto_commit=False,
    )

    logger.info("[FASTCAMPUS] Kafka consumer started and listening to 'lecture'")

    for message in consumer:
        logger.info(f"[FASTCAMPUS] Received message. size: {len(message.value.decode('utf-8'))}")

import json
import logging
import time

from flask import Flask, request, jsonify
from kafka import KafkaProducer

app = Flask(__name__)

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers = [logging.StreamHandler()],
)

logger = logging.getLogger("KafkaProducer")


producer = KafkaProducer(
    bootstrap_servers=["kafka-controller-0.kafka-controller-headless.default.svc.cluster.local:9092"],
    value_serializer=lambda v: json.dumps(v).encode("utf-8"),
)

# Generate a large message just under 1 MB
large_message = ('X' * 1000000) + str(time.time())


def on_send_success(record_metadata):
    logger.info(f"[FASTCAMPUS] topic: {record_metadata.topic}")
    logger.info(f"[FASTCAMPUS] offset: {record_metadata.offset}")


def on_send_error(excp):
    logger.error(f"[FASTCAMPUS] An error occurred: {excp}")


@app.route('/register', methods=['POST'])
def produce():
    message = {"message": large_message}
    producer.send("lectures", message).add_callback(on_send_success).add_errback(on_send_error)
    producer.flush()
    return jsonify({"status": "수강신청이 접수되었습니다."}), 200


@app.route('/', methods=['GET'])
def health():
    return jsonify({"status": "OK"}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
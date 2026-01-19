from flask import Flask, request, jsonify
import datetime
import os

# Create logs directory if it doesn't exist
os.makedirs("/logs", exist_ok=True)
log_path = "/logs/requests.log"

app = Flask(__name__)


@app.route("/hello", methods=["GET"])
def hello():
    """
    Simple endpoint that logs incoming requests and returns a greeting
    """
    log_message = f"{datetime.datetime.now()} - Received request from {request.remote_addr}\n"

    with open(log_path, "a") as f:
        f.write(log_message)

    return jsonify({"message": "Hello from main app"})


if __name__ == "__main__":
    print("Starting Flask server on 0.0.0.0:5000")
    app.run(host="0.0.0.0", port=5000, debug=True)
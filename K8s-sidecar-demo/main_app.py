from flask import flask, request, jsonify
import datetime

app = flask(__name__)

@app.route("/hello",methods=["GET"])
def hello():
    log_message=f"{datetime.datetime.now()} - Received request from {request.remote_addr}\n"
    with open("/logs/requests.log","a") as f:
        f.write(log_message)
    return jsonify({"message":"Hello from main app"})

if __name__=="__main__":
    app.run(host="0.0.0.0",port=5000)

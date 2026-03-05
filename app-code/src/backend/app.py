"""
Backend API service.

Provides system metrics and health endpoints using Flask.
"""



import os
import socket
import requests
import psutil
from flask import Flask, jsonify, send_from_directory

app = Flask(__name__, static_folder="../frontend", static_url_path="")

IMDS_BASE_URL = "http://169.254.169.254/latest"
TIMEOUT = 2


def get_imds_token():
    """
    get imds token
    """
    try:
        response = requests.put(
            f"{IMDS_BASE_URL}/api/token",
            headers={"X-aws-ec2-metadata-token-ttl-seconds": "21600"},
            timeout=TIMEOUT,
        )
        response.raise_for_status()
        return response.text
    except requests.RequestException:
        return None


def get_metadata(path):
    """get metadata"""

    token = get_imds_token()
    headers = {"X-aws-ec2-metadata-token": token} if token else {}
    try:
        response = requests.get(
            f"{IMDS_BASE_URL}/meta-data/{path}",
            headers=headers,
            timeout=TIMEOUT,
        )
        response.raise_for_status()
        return response.text
    except requests.RequestException:
        return "unavailable"


@app.route("/")
def serve_frontend():
    """serve frontend files"""
    return send_from_directory(app.static_folder, "index.html")


@app.route("/health")
def health():
    """health check route"""
    return jsonify({"status": "ok"})


@app.route("/info")
def info():
    """pull aws services' info"""
    hostname = socket.gethostname()
    instance_id = get_metadata("instance-id")
    availability_zone = get_metadata("placement/availability-zone")
    cpu_count = os.cpu_count()
    memory_mb = round(psutil.virtual_memory().total / (1024 * 1024))
    environment = os.getenv("ENV", "dev")

    return jsonify(
        {
            "hostname": hostname,
            "instance_id": instance_id,
            "availability_zone": availability_zone,
            "cpu_count": cpu_count,
            "memory_mb": memory_mb,
            "environment": environment,
        }
    )


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

@app.route("/", methods=["GET", "POST"])
def index():
    if request.method == "POST":
        data = request.get_json(force=True)
        return jsonify({"received": data})

    try:
        es_response = requests.get("http://toxiproxy:8666")
        return jsonify(es_response.json())
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)

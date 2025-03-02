# app.py
import random

from flask import Flask, jsonify, render_template
from datetime import datetime


def create_app():
    app = Flask(__name__)

    @app.route('/')
    def index():
        current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
        return render_template('index.html', current_time=current_time)

    @app.route('/health')
    def health():
        return jsonify(status="ok"), 200

    @app.route('/test')
    def test():
        return jsonify(status="test ok", random_number=random.randint(0, 1000)), 200

    return app


if __name__ == '__main__':
    create_app().run(host='0.0.0.0', port=5000)

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
        words = [
            "cat", "dog", "worm", "fish", "bird", "mouse", "lion", "tiger", "snake", "frog",
            "rabbit", "deer", "wolf", "bear", "fox", "goat", "sheep", "cow", "horse", "duck",
            "eagle", "owl", "rat", "ant", "bee", "butterfly", "spider", "shark", "whale", "dolphin",
            "penguin", "camel", "elephant", "giraffe", "monkey", "zebra", "crocodile", "hippo", "kangaroo", "bat"
        ]

        return jsonify(status="test ok", random_word=words[random.randint(0, len(words))]), 200


    return app


if __name__ == '__main__':
    create_app().run(host='0.0.0.0', port=5000)

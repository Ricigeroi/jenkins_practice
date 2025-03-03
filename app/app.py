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

    # @app.route('/test')
    # def test():
    #     words = [
    #         "cat", "dog", "worm", "fish", "bird", "mouse", "lion", "tiger", "snake", "frog",
    #         "rabbit", "deer", "wolf", "bear", "fox", "goat", "sheep", "cow", "horse", "duck",
    #         "eagle", "owl", "rat", "ant", "bee", "butterfly", "spider", "shark", "whale", "dolphin",
    #         "penguin", "camel", "elephant", "giraffe", "monkey", "zebra", "crocodile", "hippo", "kangaroo", "bat"
    #     ]

        return jsonify(status="test ok", random_word=words[random.randint(0, len(words) - 1)]), 200

    @app.route('/test2')
    def test2():
        car_brands = [
            "Toyota", "Honda", "Ford", "Chevrolet", "Nissan", "BMW", "Mercedes-Benz", "Audi", "Volkswagen", "Porsche",
            "Ferrari", "Lamborghini", "Maserati", "Jaguar", "Land Rover", "Volvo", "Subaru", "Mazda", "Lexus",
            "Hyundai",
            "Kia", "Tesla", "Chrysler", "Dodge", "Jeep", "Cadillac", "Buick", "GMC", "Acura", "Infiniti",
            "Mitsubishi", "Suzuki", "Alfa Romeo", "Fiat", "Peugeot", "Renault", "Citroen", "Opel", "Skoda", "Seat"
        ]

        return jsonify(status="test ok", random_car_brand=car_brands[random.randint(0, len(car_brands) - 1)]), 200

    @app.route('/test3')
    def test3():
        countries = [
            "USA", "Canada", "Brazil", "Germany", "France", "Italy", "Spain", "Russia", "China", "Japan",
            "South Korea", "Australia", "India", "Mexico", "Argentina", "South Africa", "Egypt", "Turkey", "Sweden",
            "Norway",
            "Netherlands", "Switzerland", "Portugal", "Greece", "Poland", "Ukraine", "Belgium", "Austria", "Denmark",
            "Finland"
        ]

        return jsonify(status="test ok", random_country=countries[random.randint(0, len(countries) - 1)]), 200

    @app.route('/test4')
    def test4():
        colors = [
            "Red", "Blue", "Green", "Yellow", "Purple", "Orange", "Pink", "Black", "White", "Gray",
            "Cyan", "Magenta", "Lime", "Brown", "Beige", "Turquoise", "Maroon", "Olive", "Gold", "Silver"
        ]

        return jsonify(status="test ok", random_color=colors[random.randint(0, len(colors) - 1)]), 200

    return app


if __name__ == '__main__':
    create_app().run(host='0.0.0.0', port=5000)

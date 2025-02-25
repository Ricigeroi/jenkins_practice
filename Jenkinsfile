pipeline {
    agent any

    environment {
        VENV = "venv"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/Ricigeroi/jenkins_practice.git'
            }
        }

        stage('Test') {
            steps {
                // Создаём virtualenv и устанавливаем зависимости
                sh """
                    python3 -m venv venv
                    . venv/bin/activate
                    pip install --upgrade pip
                    pip install -r app/requirements.txt
                    pytest
                """
            }
        }

        stage('Docker Build & Run') {
            steps {
                sh """
                    docker build -t my-flask-app ./app
                    docker run -d -p 5000:5000 --name flask_app my-flask-app
                """
            }
        }
    }
}

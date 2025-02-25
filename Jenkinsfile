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
    }
}

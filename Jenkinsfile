pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "flask-app"
        DOCKER_CONTAINER = "flask-app-container"
        DOCKER_BIN = "/usr/bin/docker"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/Ricigeroi/jenkins_practice.git'
                sh "ls -la"  // Debugging step to check files in workspace
            }
        }

        stage('Build Docker Image') {
            steps {
                sh "ls -la app"  // Debugging step to ensure Dockerfile is present
                sh "${DOCKER_BIN} build -t ${DOCKER_IMAGE} -f app/Dockerfile app/"
            }
        }

        stage('Run Flask App') {
            steps {
                sh """
                ${DOCKER_BIN} stop ${DOCKER_CONTAINER} || true
                ${DOCKER_BIN} rm ${DOCKER_CONTAINER} || true
                ${DOCKER_BIN} run -d --name ${DOCKER_CONTAINER} -p 5000:5000 ${DOCKER_IMAGE}
                """
            }
        }

        stage('Cleanup') {
            steps {
                sh "${DOCKER_BIN} system prune -f"
            }
        }
    }
}

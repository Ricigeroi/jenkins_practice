pipeline {
    agent {
        docker {
            image 'python:3.9'  // Using Python image for Jenkins agent
        }
    }

    environment {
        DOCKER_IMAGE = "flask-app"
        DOCKER_CONTAINER = "flask-app-container"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/Ricigeroi/jenkins_practice.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${DOCKER_IMAGE}", ".")
                }
            }
        }

        stage('Run Flask App') {
            steps {
                script {
                    // Stop and remove the existing container if it exists
                    sh "docker stop ${DOCKER_CONTAINER} || true && docker rm ${DOCKER_CONTAINER} || true"

                    // Run the new container
                    sh """
                    docker run -d --name ${DOCKER_CONTAINER} -p 5000:5000 ${DOCKER_IMAGE}
                    """
                }
            }
        }

        stage('Cleanup') {
            steps {
                script {
                    sh "docker system prune -f"
                }
            }
        }
    }
}

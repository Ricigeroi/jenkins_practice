pipeline {
    agent any

    environment {
        PROJECT_ID = 'diesel-aegis-403113'
        REPO_NAME = 'jenkins-practice'
        IMAGE_NAME = 'flask-app'
        IMAGE_TAG = 'latest'
        GAR_LOCATION = 'europe-north1'  // Или другой регион
        GAR_URL = "${GAR_LOCATION}-docker.pkg.dev/${PROJECT_ID}/${REPO_NAME}/${IMAGE_NAME}:${IMAGE_TAG}"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/Ricigeroi/jenkins_practice.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                    docker build -t \${GAR_URL} -f app/Dockerfile app/
                """
            }
        }

        stage('Push to Google Artifact Registry') {
            steps {
                sh """
                    gcloud auth configure-docker \${GAR_LOCATION}-docker.pkg.dev --quiet
                    docker push \${GAR_URL}
                """
            }
        }
    }
}

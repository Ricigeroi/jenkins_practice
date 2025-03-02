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
                sh "ls -la app"  // Проверяем, что Dockerfile на месте
                sh "${DOCKER_BIN} build -t ${DOCKER_IMAGE} -f app/Dockerfile ."
            }
        }

        stage('Run Tests') {
            steps {
                sh """
                ${DOCKER_BIN} run --rm \
                    -v "\$(pwd)/tests:/app/tests" \
                    -w /app ${DOCKER_IMAGE} \
                    pytest tests/test_app.py --disable-warnings
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

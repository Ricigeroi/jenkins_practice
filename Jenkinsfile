pipeline {
    agent any

    environment {
        VENV = "venv"
        // Ваш ID проекта в GCP
        GCP_PROJECT_ID = "diesel-aegis-403113"
        // ID файла с ключом, сохранённого в Jenkins Credentials
        GCP_SERVICE_ACCOUNT_CREDENTIALS = "gcp-key"
        // Настройки для Artifact Registry
        ARTIFACT_REGISTRY_LOCATION = "us-central1"
        ARTIFACT_REGISTRY_REPO     = "flask-repo"
        IMAGE_NAME                 = "flask-app"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/Ricigeroi/jenkins_practice.git'
            }
        }

        stage('Test') {
            steps {
                sh """
                    python3 -m venv ${env.VENV}
                    . ${env.VENV}/bin/activate
                    pip install --upgrade pip
                    pip install -r app/requirements.txt
                    pytest
                """
            }
        }

        stage('Docker Build & Push') {
            steps {
                sh '''
                    echo "Building and pushing Docker image using a Docker container..."
                    docker run --rm --privileged \
                      -v /var/run/docker.sock:/var/run/docker.sock \
                      -v "$PWD":/workspace \
                      -w /workspace \
                      docker:latest \
                      sh -c "docker build -t us-central1-docker.pkg.dev/${GCP_PROJECT_ID}/${ARTIFACT_REGISTRY_REPO}/${IMAGE_NAME}:latest app/ && \
                             docker push us-central1-docker.pkg.dev/${GCP_PROJECT_ID}/${ARTIFACT_REGISTRY_REPO}/${IMAGE_NAME}:latest"
                '''
            }
        }

        stage('Deploy to GCP') {
            when {
                expression {
                    return currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                script {
                    // Используем Jenkins Credentials для передачи JSON-файла с ключом
                    withCredentials([file(credentialsId: "${GCP_SERVICE_ACCOUNT_CREDENTIALS}", variable: 'GOOGLE_CREDENTIALS_FILE')]) {
                        sh """
                            cd terraform

                            terraform init

                            terraform plan \
                              -var="project_id=${GCP_PROJECT_ID}" \
                              -var="gcp_credentials_file=${GOOGLE_CREDENTIALS_FILE}" \
                              -var="artifact_image=us-central1-docker.pkg.dev/${GCP_PROJECT_ID}/${ARTIFACT_REGISTRY_REPO}/${IMAGE_NAME}:latest"

                            terraform apply -auto-approve \
                              -var="project_id=${GCP_PROJECT_ID}" \
                              -var="gcp_credentials_file=${GOOGLE_CREDENTIALS_FILE}" \
                              -var="artifact_image=us-central1-docker.pkg.dev/${GCP_PROJECT_ID}/${ARTIFACT_REGISTRY_REPO}/${IMAGE_NAME}:latest"
                        """
                    }
                }
            }
        }
    }
}

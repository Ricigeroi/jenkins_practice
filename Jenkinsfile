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
            // Запускаем эту стадию в контейнере с Docker-клиентом
            agent {
                docker {
                    image 'docker:latest'
                    // Монтируем Docker-сокет хоста в контейнер
                    args '-v /var/run/docker.sock:/var/run/docker.sock'
                }
            }
            steps {
                sh """
                    echo "Building Docker image..."
                    docker build -t us-central1-docker.pkg.dev/${GCP_PROJECT_ID}/${ARTIFACT_REGISTRY_REPO}/${IMAGE_NAME}:latest app/

                    echo "Pushing Docker image to Artifact Registry..."
                    docker push us-central1-docker.pkg.dev/${GCP_PROJECT_ID}/${ARTIFACT_REGISTRY_REPO}/${IMAGE_NAME}:latest
                """
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
                    // Подключаемся к Jenkins Credentials и получаем путь к JSON-файлу с ключом
                    withCredentials([file(credentialsId: "${GCP_SERVICE_ACCOUNT_CREDENTIALS}", variable: 'GOOGLE_CREDENTIALS_FILE')]) {
                        sh """
                            cd terraform

                            # Инициализируем Terraform
                            terraform init

                            # Просмотр плана деплоя с передачей переменных:
                            terraform plan \
                              -var="project_id=${GCP_PROJECT_ID}" \
                              -var="gcp_credentials_file=${GOOGLE_CREDENTIALS_FILE}" \
                              -var="artifact_image=${ARTIFACT_REGISTRY_LOCATION}-docker.pkg.dev/${GCP_PROJECT_ID}/${ARTIFACT_REGISTRY_REPO}/${IMAGE_NAME}:latest"

                            # Применяем план деплоя
                            terraform apply -auto-approve \
                              -var="project_id=${GCP_PROJECT_ID}" \
                              -var="gcp_credentials_file=${GOOGLE_CREDENTIALS_FILE}" \
                              -var="artifact_image=${ARTIFACT_REGISTRY_LOCATION}-docker.pkg.dev/${GCP_PROJECT_ID}/${ARTIFACT_REGISTRY_REPO}/${IMAGE_NAME}:latest"
                        """
                    }
                }
            }
        }
    }
}

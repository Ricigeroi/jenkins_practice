pipeline {
    agent any

    environment {
        VENV = "venv"
        // Ваш ID проекта в GCP
        GCP_PROJECT_ID = "diesel-aegis-403113"
        // Имя файла с ключом в Jenkins Credentials
        GCP_SERVICE_ACCOUNT_CREDENTIALS = "gcp-key"
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

        stage('Docker Build & Run') {
            steps {
                sh """
                    python3 -m venv ${env.VENV}
                    . ${env.VENV}/bin/activate
                    pip install --upgrade pip
                    pip install -r app/requirements.txt
                    python3 app/app.py
                """
            }
        }

        stage('Deploy to GCP') {
            // Запускаем только если предыдущие стадии не упали
            when {
                expression {
                    return currentBuild.result == null || currentBuild.result == 'SUCCESS'
                }
            }
            steps {
                script {
                    // Подключаемся к Credentials Jenkins, где лежит JSON-файл
                    withCredentials([file(credentialsId: "${env.GCP_SERVICE_ACCOUNT_CREDENTIALS}", variable: 'GOOGLE_CREDENTIALS_FILE')]) {
                        sh """
                            # Переходим в директорию с Terraform-конфигурацией
                            cd terraform

                            # Инициализация Terraform
                            terraform init

                            # Показываем план
                            terraform plan \
                              -var="project_id=${env.GCP_PROJECT_ID}" \
                              -var="gcp_credentials_file=\${GOOGLE_CREDENTIALS_FILE}"

                            # Применяем план (автоматически подтверждаем)
                            terraform apply -auto-approve \
                              -var="project_id=${env.GCP_PROJECT_ID}" \
                              -var="gcp_credentials_file=\${GOOGLE_CREDENTIALS_FILE}"
                        """
                    }
                }
            }
        }
    }
}

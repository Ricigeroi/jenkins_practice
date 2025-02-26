pipeline {
    agent any

    environment {
        VENV = "venv"
        GCP_PROJECT_ID = "diesel-aegis-403113"
        // ID файла с ключом, сохранённого в Jenkins Credentials (типа Secret File)
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

        stage('Deploy to GCP') {
            steps {
                withCredentials([file(credentialsId: "${GCP_SERVICE_ACCOUNT_CREDENTIALS}", variable: 'GOOGLE_CREDENTIALS_FILE')]) {
                    sh """
                        cd terraform
                        terraform init
                        terraform plan -var="project_id=${GCP_PROJECT_ID}" -var="gcp_credentials_file=${GOOGLE_CREDENTIALS_FILE}"
                        terraform apply -auto-approve -var="project_id=${GCP_PROJECT_ID}" -var="gcp_credentials_file=${GOOGLE_CREDENTIALS_FILE}"
                    """
                }
            }
        }
    }
}

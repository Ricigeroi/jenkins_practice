pipeline {
    agent any

    environment {
        VENV = "venv"
        GCP_PROJECT_ID = "diesel-aegis-403113"
        // ID файла с ключом, сохранённого в Jenkins Credentials (типа Secret File)
        GCP_SERVICE_ACCOUNT_CREDENTIALS = "gcp-key2"
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
                    sh '''
                        cd terraform
                        echo "Initializing Terraform..."
                        docker run --rm -v "$PWD/terraform":/workspace -w /workspace hashicorp/terraform:latest init -var="project_id=${GCP_PROJECT_ID}" -var="gcp_credentials_file=${GOOGLE_CREDENTIALS_FILE}"

                        echo "Planning Terraform changes..."
                        docker run --rm -v "$PWD/terraform":/workspace -w /workspace hashicorp/terraform:latest plan -var="project_id=${GCP_PROJECT_ID}" -var="gcp_credentials_file=${GOOGLE_CREDENTIALS_FILE}"

                        echo "Applying Terraform configuration..."
                        docker run --rm -v "$PWD/terraform":/workspace -w /workspace hashicorp/terraform:latest apply -auto-approve -var="project_id=${GCP_PROJECT_ID}" -var="gcp_credentials_file=${GOOGLE_CREDENTIALS_FILE}"
                    '''
                }
            }
        }
    }
}

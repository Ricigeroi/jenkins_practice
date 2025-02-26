pipeline {
    agent any

    environment {
        VENV = "venv"
        GCP_PROJECT_ID = "diesel-aegis-403113"
        GCP_SERVICE_ACCOUNT_CREDENTIALS = "gcp-key"
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
        stage('Docker Build & Push with Kaniko') {
            steps {
                withCredentials([file(credentialsId: "${GCP_SERVICE_ACCOUNT_CREDENTIALS}", variable: 'KANIKO_CONFIG')]) {
                    sh '''
                        echo "Building Docker image with Kaniko..."
                        docker run --rm \
                          -v "$PWD":/workspace \
                          -v ${KANIKO_CONFIG}:/kaniko/.docker/config.json:ro \
                          gcr.io/kaniko-project/executor:latest \
                          --dockerfile=/workspace/app/Dockerfile \
                          --context=dir:///workspace/app \
                          --destination=us-central1-docker.pkg.dev/${GCP_PROJECT_ID}/${ARTIFACT_REGISTRY_REPO}/${IMAGE_NAME}:latest \
                          --verbosity=info
                    '''
                }
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

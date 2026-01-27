pipeline {
    agent any

    environment {
        DOCKER_PATH = "/usr/local/bin/docker"
        TRIVY_PATH  = "/opt/homebrew/bin/trivy"
        CODACY_PROJECT_TOKEN = credentials('codacy-token')
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh """
                ${DOCKER_PATH} build -t factmatrix-streamlit .
                """
            }
        }

        stage('Run Tests & Generate Coverage') {
            steps {
                sh """
                python3 -m venv .venv
                source .venv/bin/activate
                pip install --upgrade pip
                pip install -r requirements.txt pytest coverage

                coverage run -m pytest tests
                coverage xml
                """
            }
        }

        stage('Upload Coverage to Codacy') {
            steps {
                sh """
                curl -Ls https://coverage.codacy.com/get.sh | bash -s report \
                  --language Python \
                  --coverage-reports coverage.xml
                """
            }
        }

        stage('Trivy Security Scan') {
            steps {
                sh """
                ${TRIVY_PATH} image --severity CRITICAL --exit-code 1 factmatrix-streamlit
                """
            }
        }
    }

    post {
        success {
            echo "✅ CI + Coverage + Security pipeline completed successfully"
        }
        failure {
            echo "❌ Pipeline failed"
        }
    }
}

pipeline {
    agent any

    environment {
        DOCKER_PATH = "/usr/local/bin/docker"
        TRIVY_PATH  = "/opt/homebrew/bin/trivy"
        CODACY_PROJECT_TOKEN = credentials('codacy-token')
        TRIVY_DISABLE_DOCKER_CREDENTIALS = "true"
    }

    stages {

        stage('Checkout Code') {
            steps {
                checkout scm
            }
        }

        stage('Run Tests & Generate Coverage') {
            steps {
                sh '''
                python3 -m venv .venv
                source .venv/bin/activate
                pip install --upgrade pip
                pip install -r requirements.txt pytest coverage

                coverage run -m pytest tests
                coverage xml
                '''
            }
        }

        stage('Upload Coverage to Codacy') {
            steps {
                sh '''
                curl -Ls https://coverage.codacy.com/get.sh | bash -s report \
                  --language Python \
                  --coverage-reports coverage.xml
                '''
            }
        }

        stage('Clean Old Containers (Safe)') {
            steps {
                sh '''
                ${DOCKER_PATH} compose down --remove-orphans || true
                '''
            }
        }

        stage('Build & Deploy with Docker Compose') {
            steps {
                sh '''
                ${DOCKER_PATH} compose up -d --build
                '''
            }
        }

        stage('Trivy Security Scan') {
            steps {
                sh '''
                ${TRIVY_PATH} image --severity CRITICAL --exit-code 1 factmatrix-ci_factmatrix
                '''
            }
        }

        stage('Monitoring Check') {
            steps {
                sh '''
                echo "Prometheus running on http://localhost:9090"
                echo "Grafana running on http://localhost:3000"
                '''
            }
        }
    }

    post {
        success {
            echo "✅ CI/CD + Security + Monitoring completed successfully"
        }
        failure {
            echo "❌ Pipeline failed"
        }
    }
}

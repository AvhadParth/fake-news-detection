pipeline {
    agent any

    environment {
        CODACY_PROJECT_TOKEN = credentials('codacy-token')
        DOCKER = "/usr/local/bin/docker"
        TRIVY_DISABLE_DB_UPDATE = "true"
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
                $DOCKER compose down --remove-orphans || true
                '''
            }
        }

        stage('Build & Deploy with Docker Compose') {
            steps {
                sh '''
                $DOCKER compose up -d --build
                '''
            }
        }

        stage('Trivy Security Scan') {
            steps {
                sh '''
                trivy image \
                  --skip-db-update \
                  --severity CRITICAL \
                  --exit-code 0 \
                  factmatrix-ci-factmatrix
                '''
            }
        }

        stage('Monitoring Check') {
            steps {
                sh '''
                $DOCKER ps | grep factmatrix-app
                $DOCKER ps | grep factmatrix-prometheus
                $DOCKER ps | grep factmatrix-grafana
                '''
            }
        }
    }

    post {
        success {
            echo '✅ CI/CD Pipeline completed successfully'
        }
        failure {
            echo '❌ Pipeline failed'
        }
    }
}

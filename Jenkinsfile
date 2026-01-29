pipeline {
    agent any

    environment {
        CODACY_PROJECT_TOKEN = credentials('codacy-token')
        TRIVY_DISABLE_DB_UPDATE = "true"
        TRIVY_SKIP_DB_UPDATE = "true"
        TRIVY_NON_SSL = "true"
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
                docker compose down --remove-orphans || true
                '''
            }
        }

        stage('Build & Deploy with Docker Compose') {
            steps {
                sh '''
                docker compose up -d --build
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
                docker ps | grep factmatrix-app
                docker ps | grep factmatrix-prometheus
                docker ps | grep factmatrix-grafana
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

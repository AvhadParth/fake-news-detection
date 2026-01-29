pipeline {
    agent any

    environment {
        CODACY_PROJECT_TOKEN = credentials('codacy-token')
        DOCKER = "/usr/local/bin/docker"
        TRIVY  = "/opt/homebrew/bin/trivy"
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
                $TRIVY image \
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
        echo "Waiting for containers to stabilize..."
        sleep 10

        echo "Checking FactMatrix app container..."
        docker ps --format "{{.Names}}" | grep -q factmatrix-app || {
            echo "❌ FactMatrix app container not running"
            docker ps
            exit 1
        }

        echo "Checking Prometheus container..."
        docker ps --format "{{.Names}}" | grep -q prometheus || {
            echo "❌ Prometheus container not running"
            docker ps
            exit 1
        }

        echo "✅ Monitoring services are up and running"
        '''
    }
}

    }

    post {
        success {
            echo '✅ CI/CD + Security + Monitoring completed successfully'
        }
        failure {
            echo '❌ Pipeline failed'
        }
    }
}

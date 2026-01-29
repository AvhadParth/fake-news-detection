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

        stage('Build & Deploy with Docker Compose') {
    steps {
        sh """
        ${DOCKER_PATH} compose down --remove-orphans || true
        ${DOCKER_PATH} rm -f factmatrix-app || true
        ${DOCKER_PATH} compose up -d --build
        """
    }
}


        stage('Trivy Security Scan') {
    steps {
        sh '''
        export TRIVY_DISABLE_DOCKER_CREDENTIALS=true
        export TRIVY_SKIP_DB_UPDATE=true

        /opt/homebrew/bin/trivy image \
          --severity CRITICAL \
          --exit-code 0 \
          factmatrix-ci-factmatrix
        '''
    }
}

stage('Monitoring Check') {
    steps {
        sh '''
        docker ps | grep prometheus
        docker ps | grep grafana
        '''
    }
}


    }

    post {
        success {
            echo "✅ CI/CD + Coverage + Security + Auto Deployment SUCCESSFUL"
        }
        failure {
            echo "❌ Pipeline failed"
        }
    }
}

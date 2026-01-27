pipeline {
    agent any

    environment {
        DOCKER_CONFIG = "${env.HOME}/.jenkins-docker"
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'devops-integration',
                    url: 'https://github.com/AvhadParth/fake-news-detection.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh '/usr/local/bin/docker build -t factmatrix-streamlit .'
                }
            }
        }

       stage('Trivy Security Scan') {
    steps {
        script {
            sh '''
            /opt/homebrew/bin/trivy image \
              --severity HIGH,CRITICAL \
              --exit-code 1 \
              factmatrix-streamlit
            '''
        }
    }
}

    }

    post {
        success {
            echo '✅ CI + Security pipeline completed successfully'
        }
        failure {
            echo '❌ Pipeline failed due to security or build issues'
        }
    }
}

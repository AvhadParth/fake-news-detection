pipeline {
    agent any

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
                    sh 'docker build -t factmatrix-streamlit .'
                }
            }
        }
    }

    post {
        success {
            echo '✅ CI pipeline completed successfully'
        }
        failure {
            echo '❌ CI pipeline failed'
        }
    }
}

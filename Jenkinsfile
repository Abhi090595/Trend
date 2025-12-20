pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "a516/trend-app"
        DOCKER_CREDS = "dockerhub-creds"
    }

    stages {

        stage('Clone Repo') {
            steps {
                git url: 'https://github.com/Abhi090595/Trend.git',
                    branch: 'main',
                    credentialsId: 'github-creds'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                docker build -t trend-app:latest .
                docker tag trend-app:latest trend-app:${BUILD_NUMBER}
                '''
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: DOCKER_CREDS,
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                    docker login -u "$DOCKER_USER" -p "$DOCKER_PASS"

                     docker push a516/trend-app:latest
                    docker push trend-app:${BUILD_NUMBER}
                    docker logout
                    '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                kubectl apply -f k8s/deployment.yaml
                kubectl apply -f k8s/service.yaml
                '''
            }
        }
    }

    post {
        success {
            echo "Pipeline executed successfully! ✅"
        }
        failure {
            echo "Pipeline failed! ❌"
        }
    }
}

pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "a516/trend-app"  // DockerHub username/repo format
        DOCKER_CREDS = "dockerhub-creds" // Jenkins credentials ID for DockerHub
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
                sh 'docker build -t $DOCKER_IMAGE:latest .'
                sh 'docker tag $DOCKER_IMAGE:latest $DOCKER_IMAGE:${BUILD_NUMBER}'
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
                    echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                    docker push $DOCKER_IMAGE:latest
                    docker push $DOCKER_IMAGE:${BUILD_NUMBER}
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
        success { echo "Pipeline executed successfully! ✅" }
        failure { echo "Pipeline failed! ❌" }
    }
}

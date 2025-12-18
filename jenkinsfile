pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "a516/trend-app"
        DOCKER_CREDS = "dockerhub-creds"
    }

    stages {
        stage('Clone Repo') {
            steps {
                git url: 'https://github.com/Abhi0905/Trend.git',
                    branch: 'main',
                    credentialsId: 'github-creds'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $DOCKER_IMAGE:latest .'
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: DOCKER_CREDS,
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    sh '''
                    echo $PASS | docker login -u $USER --password-stdin
                    docker push $DOCKER_IMAGE:latest
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

pipeline {
    agent any

    environment {
        // Docker image name
        DOCKER_IMAGE = "a516/trend-app"
        // Jenkins credential ID for DockerHub
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
                # Build latest image
                docker build -t a516/trend-app:latest .

                # Tag with build number
                docker tag a516/trend-app:latest a516/trend-app:${BUILD_NUMBER}
                '''
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: "dockerhub-creden",
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                     # Log in and push without storing credentials
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin


                    # Push both tags
                    docker push a516/trend-app:latest
                    docker push a516/trend-app:${BUILD_NUMBER}

                   # Logout immediately to remove credentials from memory
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

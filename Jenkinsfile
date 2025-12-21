pipeline {
    agent any

    environment {
        KUBECONFIG = '/var/lib/jenkins/.kube/config'
    }

    stages {

        stage('Checkout Code') {
            steps {
                git branch: 'main', url: 'https://github.com/Abhi090595/Trend.git', credentialsId: 'github-creds'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh '''
                    docker build -t a516/trend-app:latest .
                    docker tag a516/trend-app:latest a516/trend-app:39
                '''
            }
        }

        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creden',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh '''
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push a516/trend-app:latest
                        docker push a516/trend-app:39
                    '''
                }
            }
        }

        stage('Deploy to EKS') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'aws-creds', 
                    usernameVariable: 'AWS_ACCESS_KEY_ID', 
                    passwordVariable: 'AWS_SECRET_ACCESS_KEY'
                )]) {
                    sh '''
                        aws eks update-kubeconfig --name Trend-Eks-Cluster --region us-east-1
                        kubectl get nodes
                        kubectl apply -f deployment.yml
                        kubectl apply -f service.yml
                    '''
                }
            }
        }

    }

    post {
        success {
            echo "Pipeline completed successfully ✅"
        }
        failure {
            echo "Pipeline failed ❌"
        }
    }
}

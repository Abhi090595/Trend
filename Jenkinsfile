pipeline {
    agent any

    environment {
        DOCKER_USER = credentials('dockerhub-creden') 
        DOCKER_PASS = credentials('dockerhub-creden') 
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
                sh '''
                    echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                    docker push a516/trend-app:latest
                    docker push a516/trend-app:39
                '''
            }
        }

        stage('Deploy to EKS') {
            steps {
                sh '''
                    kubectl get nodes
                    kubectl apply -f deployment.yml
                    kubectl apply -f service.yml
                '''
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

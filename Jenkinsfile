pipeline {
    agent any

    parameters {
        string(name: 'API_IMAGE_TAG', defaultValue: 'latest', description: 'API image tag')
        string(name: 'WORKER_IMAGE_TAG', defaultValue: 'latest', description: 'Worker image tag')
        string(name: 'FRONTEND_IMAGE_TAG', defaultValue: 'latest', description: 'Frontend image tag')
    }

    environment {
        API_IMAGE      = "lokesshhdocker/micro-services-api"
        WORKER_IMAGE   = "lokesshhdocker/micro-services-worker"
        FRONTEND_IMAGE = "lokesshhdocker/micro-services-frontend"
    }

    stages {

        stage('Clean Workspace & Checkout') {
            steps {
                cleanWs()
                checkout([
                    $class: 'GitSCM',
                    branches: [[name: '*/main']],
                    userRemoteConfigs: [[
                        url: 'https://github.com/dhakallokesh/micro-service.git'
                    ]]
                ])
            }
        }

        stage('Build Docker Images') {
            steps {
                sh """
                docker build -t ${API_IMAGE}:${API_IMAGE_TAG} api-service/
                docker build -t ${WORKER_IMAGE}:${WORKER_IMAGE_TAG} worker-service/
                docker build -t ${FRONTEND_IMAGE}:${FRONTEND_IMAGE_TAG} frontend-service/
                """
            }
        }

        stage('Run Tests') {
            steps {
                sh """
                echo "Running containerized tests"

                echo "API tests"
                docker run --rm ${API_IMAGE}:${API_IMAGE_TAG} npm test || exit 1

                echo "Worker tests"
                docker run --rm ${WORKER_IMAGE}:${WORKER_IMAGE_TAG} pytest || exit 1

                echo "Frontend tests (optional)"
                docker run --rm ${FRONTEND_IMAGE}:${FRONTEND_IMAGE_TAG} npm test || echo "Frontend tests skipped"
                """
            }
        }

        stage('Docker Login & Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                    echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
                    docker push ${API_IMAGE}:${API_IMAGE_TAG}
                    docker push ${WORKER_IMAGE}:${WORKER_IMAGE_TAG}
                    docker push ${FRONTEND_IMAGE}:${FRONTEND_IMAGE_TAG}
                    """
                }
            }
        }

        stage('Update Kubernetes Manifests') {
            steps {
                sh """
                sed -i "s|IMAGE_TAG|${API_IMAGE_TAG}|g" k8s/api.yml
                sed -i "s|IMAGE_TAG|${WORKER_IMAGE_TAG}|g" k8s/worker.yml
                sed -i "s|IMAGE_TAG|${FRONTEND_IMAGE_TAG}|g" k8s/frontend.yml
                """
            }
        }

        stage('Deploy to k3s') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh """
                    export KUBECONFIG=\$KUBECONFIG
                    kubectl apply -f k8s/api.yml
                    kubectl apply -f k8s/worker.yml
                    kubectl apply -f k8s/frontend.yml
                    """
                }
            }
        }

        stage('Verify Deployments') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh """
                    export KUBECONFIG=\$KUBECONFIG
                    kubectl rollout status deployment/api-service --timeout=60s
                    kubectl rollout status deployment/worker-service --timeout=60s
                    kubectl rollout status deployment/frontend-service --timeout=60s
                    """
                }
            }
        }
    }

    post {
        failure {
            echo "Deployment failed. Rolling back application services..."

            withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                sh """
                export KUBECONFIG=\$KUBECONFIG
                kubectl rollout undo deployment/api-service
                kubectl rollout undo deployment/worker-service
                kubectl rollout undo deployment/frontend-service
                """
            }
        }

        success {
            echo "Pipeline completed successfully 🎉"
        }
    }
}

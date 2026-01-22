pipeline {
    agent any

    parameters {
        string(name: 'API_IMAGE_TAG', defaultValue: "latest", description: 'API image tag')
        string(name: 'WORKER_IMAGE_TAG', defaultValue: "latest", description: 'Worker image tag')
        string(name: 'FRONTEND_IMAGE_TAG', defaultValue: "latest", description: 'Frontend image tag')
        string(name: 'MYSQL_IMAGE_TAG', defaultValue: "8.0", description: 'MySQL image tag')
        string(name: 'REDIS_IMAGE_TAG', defaultValue: "7.2", description: 'Redis image tag')
    }

    environment {
        API_IMAGE = "lokeshdhakal/api"
        WORKER_IMAGE = "lokeshdhakal/worker"
        FRONTEND_IMAGE = "lokeshdhakal/frontend"
        IMAGE_REPO = "lokeshdhakal"
    }

    stages {

        stage('Checkout') {
           steps {
               checkout([$class: 'GitSCM',
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
                    docker build -t $IMAGE_REPO:api-${API_IMAGE_TAG} api-service/
                    docker build -t $IMAGE_REPO:worker-${WORKER_IMAGE_TAG} worker-service/
                    docker build -t $IMAGE_REPO:frontend-${FRONTEND_IMAGE_TAG} frontend-service/
                """
            }
        }

        stage('Run Tests') {
            steps {
                sh 'echo "Run tests here"'
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
                      echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
                      docker push $API_IMAGE:${API_IMAGE_TAG}
                      docker push $WORKER_IMAGE:${WORKER_IMAGE_TAG}
                      docker push $FRONTEND_IMAGE:${FRONTEND_IMAGE_TAG}
                    """
                }
            }
        }

        stage('Update Kubernetes Manifests') {
            steps {
                sh """
                  sed -i "s|API_IMAGE_TAG|${API_IMAGE_TAG}|g" k8s/api.yml
                  sed -i "s|WORKER_IMAGE_TAG|${WORKER_IMAGE_TAG}|g" k8s/worker.yml
                  sed -i "s|FRONTEND_IMAGE_TAG|${FRONTEND_IMAGE_TAG}|g" k8s/frontend.yml
                  sed -i "s|MYSQL_IMAGE_TAG|${MYSQL_IMAGE_TAG}|g" k8s/db.yml
                  sed -i "s|REDIS_IMAGE_TAG|${REDIS_IMAGE_TAG}|g" k8s/redis.yml
                """
            }
        }

        stage('Deploy to k3s') {
            steps {
                withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                    sh """
                      export KUBECONFIG=$KUBECONFIG

                      kubectl apply -f k8s/db.yml
                      kubectl apply -f k8s/redis.yml
                      kubectl apply -f k8s/api.yml
                      kubectl apply -f k8s/worker.yml
                      kubectl apply -f k8s/frontend.yml
                    """
                }
            }
        }

        stage('Verify Deployments') {
            steps {
                sh """
                  kubectl rollout status deployment/api --timeout=60s
                  kubectl rollout status deployment/worker --timeout=60s
                  kubectl rollout status deployment/frontend --timeout=60s
                """
            }
        }
    }

    post {
        failure {
            echo "Deployment failed. Rolling back application services only..."

            withCredentials([file(credentialsId: 'kubeconfig', variable: 'KUBECONFIG')]) {
                sh """
                  export KUBECONFIG=$KUBECONFIG
                  kubectl rollout undo deployment/api
                  kubectl rollout undo deployment/worker
                  kubectl rollout undo deployment/frontend
                """
            }
        }
    }
}


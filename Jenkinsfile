pipeline {
    agent any

    environment {
        // Aapki details ke hisaab se configurations
        DOCKER_IMAGE = "amarjeet001/car-website"
        DOCKER_TAG   = "${env.BUILD_NUMBER}"
        DOCKER_HUB_ID = "dockerhub-creds" // Jo aapne bataya
        K8S_CONFIG_ID = "k8s-config"      // Jenkins mein kubeconfig ki ID
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/amarjeetchaurasiya27-cyber/car-website.git', branch: 'main'
            }
        }

        stage('Code Analysis (SonarQube)') {
            steps {
                echo "Analyzing code quality..."
                // Agar SonarQube setup hai toh yahan command aayegi, 
                // nahi toh ise skip kar sakte hain.
            }
        }

        stage('Docker Build') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${DOCKER_TAG} ."
                sh "docker tag ${DOCKER_IMAGE}:${DOCKER_TAG} ${DOCKER_IMAGE}:latest"
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_ID}", passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        sh "echo \$PASS | docker login -u \$USER --password-stdin"
                        sh "docker push ${DOCKER_IMAGE}:${DOCKER_TAG}"
                        sh "docker push ${DOCKER_IMAGE}:latest"
                    }
                }
            }
        }

        stage('Deploy to Kubernetes') {
            steps {
                script {
                    // Jenkins se Minikube/K8s par deploy karne ke liye
                    withKubeConfig([credentialsId: "${K8S_CONFIG_ID}"]) {
                        echo "Updating deployment with image tag: ${DOCKER_TAG}"
                        // Deployment YAML mein image version update karna
                        sh "sed -i 's|amarjeet001/car-website:latest|${DOCKER_IMAGE}:${DOCKER_TAG}|g' k8s/deployment.yaml"
                        sh "kubectl apply -f k8s/deployment.yaml"
                        sh "kubectl apply -f k8s/service.yaml"
                        sh "kubectl apply -f k8s/ingress.yaml"
                    }
                }
            }
        }
    }

    post {
        always {
            sh "docker logout"
            cleanWs()
        }
        success {
            echo "Bhai, Deployment Successful! Check at http://micro-app.local"
        }
    }
}

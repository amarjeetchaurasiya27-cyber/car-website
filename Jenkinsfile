pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "amarjeet001/car-website"
        DOCKER_TAG   = "${env.BUILD_NUMBER}"
        DOCKER_HUB_ID = "dockerhub-creds"
        K8S_CONFIG_ID = "k8s-config"
    }
    stages {
        stage('Cleanup Workspace') {
            steps {
                cleanWs() // Purana kachra saaf
            }
        }
        stage('Checkout') {
            steps {
                git 'https://github.com/amarjeetchaurasiya27-cyber/car-website.git'
                // Confirming if the new index.html is present
                bat "type index.html" 
            }
        }
        stage('Docker Build & Push') {
            steps {
                bat "docker build --no-cache -t %DOCKER_IMAGE%:%DOCKER_TAG% ."
                withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_ID}", passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    bat "echo %PASS% | docker login -u %USER% --password-stdin"
                    bat "docker push %DOCKER_IMAGE%:%DOCKER_TAG%"
                }
            }
        }
        stage('K8s Deployment') {
            steps {
                script {
                    withKubeConfig([credentialsId: "${K8S_CONFIG_ID}"]) {
                        // Force updating the tag in deployment.yaml
                        powershell "((Get-Content k8s/deployment.yaml) -replace 'amarjeet001/car-website:latest', '${DOCKER_IMAGE}:${DOCKER_TAG}') | Set-Content k8s/deployment.yaml"
                        bat "kubectl apply -f k8s/"
                        bat "kubectl rollout restart deployment car-website-deployment"
                    }
                }
            }
        }
    }
}

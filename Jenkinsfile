pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "amarjeet001/car-website"
        DOCKER_TAG   = "${env.BUILD_NUMBER}"
        DOCKER_HUB_ID = "dockerhub-creds"
        K8S_CONFIG_ID = "k8s-config"
    }

    stages {
        stage('Checkout') {
            steps {
                git url: 'https://github.com/amarjeetchaurasiya27-cyber/car-website.git', branch: 'main'
            }
        }

        stage('Docker Build') {
            steps {
                // 'sh' ko 'bat' mein badla gaya hai
                bat "docker build -t %DOCKER_IMAGE%:%DOCKER_TAG% ."
                bat "docker tag %DOCKER_IMAGE%:%DOCKER_TAG% %DOCKER_IMAGE%:latest"
            }
        }

        stage('Push to DockerHub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_ID}", passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                        // Windows mein variables ko %VAR% se access karte hain
                        bat "echo %PASS% | docker login -u %USER% --password-stdin"
                        bat "docker push %DOCKER_IMAGE%:%DOCKER_TAG%"
                        bat "docker push %DOCKER_IMAGE%:latest"
                    }
                }
            }
        }

       stage('Deploy to Kubernetes') {
            steps {
                script {
                    withKubeConfig([credentialsId: "${K8S_CONFIG_ID}"]) {
                        echo "Automating Deployment for Build: ${DOCKER_TAG}"
                        
                        // 1. Deployment file mein image tag update karna (Automated)
                        powershell "((Get-Content k8s/deployment.yaml) -replace 'amarjeet001/car-website:latest', '${DOCKER_IMAGE}:${DOCKER_TAG}') | Set-Content k8s/deployment.yaml"
                        
                        // 2. Fresh Apply
                        bat "kubectl apply -f k8s/"
                        
                        // 3. Force Rollout (Ye sabse zaroori hai automation ke liye)
                        // Isse Kubernetes pods ko kill karke fresh image pull karega hi karega
                        bat "kubectl rollout restart deployment/car-website-deployment"
                        
                        echo "Automation Complete! Site updated to Build #${DOCKER_TAG}"
                    }
                }
            }
        }
    }

    post {
        always {
            bat "docker logout"
            cleanWs()
        }
    }
}

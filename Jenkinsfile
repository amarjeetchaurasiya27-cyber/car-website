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
                    // Yahan aapko 'Kubernetes CLI' plugin chahiye hoga
                    withKubeConfig([credentialsId: "${K8S_CONFIG_ID}"]) {
                        echo "Updating deployment with image tag: ${DOCKER_TAG}"
                        // Windows mein 'sed' nahi hota, isliye hum PowerShell use karenge replace ke liye
                        powershell "((Get-Content k8s/deployment.yaml) -replace 'amarjeet001/car-website:latest', '${DOCKER_IMAGE}:${DOCKER_TAG}') | Set-Content k8s/deployment.yaml"
                        bat "kubectl apply -f k8s/deployment.yaml"
                        bat "kubectl apply -f k8s/service.yaml"
                        bat "kubectl apply -f k8s/ingress.yaml"
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

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
                cleanWs()
            }
        }
        stage('Checkout') {
            steps {
                // FIXED: Explicitly 'main' branch specify ki gayi hai
                git branch: 'main', url: 'https://github.com/amarjeetchaurasiya27-cyber/car-website.git'
                
                // Confirming files
                bat "dir"
                bat "type index.html" 
            }
        }
        stage('Docker Build & Push') {
            steps {
                // Building image
                bat "docker build --no-cache -t %DOCKER_IMAGE%:%DOCKER_TAG% ."
                
                withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_ID}", passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    // Windows login logic
                    bat "echo %PASS% | docker login -u %USER% --password-stdin"
                    bat "docker push %DOCKER_IMAGE%:%DOCKER_TAG%"
                    // Tagging latest for backup
                    bat "docker tag %DOCKER_IMAGE%:%DOCKER_TAG% %DOCKER_IMAGE%:latest"
                    bat "docker push %DOCKER_IMAGE%:latest"
                }
            }
        }
        stage('K8s Deployment') {
            steps {
                script {
                    withKubeConfig([credentialsId: "${K8S_CONFIG_ID}"]) {
                        echo "Deploying Build Version: ${env.BUILD_NUMBER}"
                        
                        // Step 1: Purane conflicts saaf karna (Automation)
                        bat "kubectl delete ingress --all --ignore-not-found"
                        
                        // Step 2: Deployment file mein image tag update karna
                        powershell "(Get-Content k8s/deployment.yaml) -replace 'amarjeet001/car-website:latest', '${DOCKER_IMAGE}:${DOCKER_TAG}' | Set-Content k8s/deployment.yaml"
                        
                        // Step 3: Apply all manifests
                        bat "kubectl apply -f k8s/"
                        
                        // Step 4: Force rollout restart to ensure new image pull
                        bat "kubectl rollout restart deployment car-website-deployment"
                    }
                }
            }
        }
    }
    post {
        always {
            echo "Pipeline finished. Cleaning up..."
            bat "docker logout"
        }
    }
}

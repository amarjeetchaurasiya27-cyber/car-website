pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "amarjeet001/car-website"
        DOCKER_TAG   = "${env.BUILD_NUMBER}"
        DOCKER_HUB_ID = "dockerhub-creds"
        K8S_CONFIG_ID = "k8s-config" 
    }
    stages {
        stage('Docker Build & Push') {
            steps {
                bat "docker build -t %DOCKER_IMAGE%:%DOCKER_TAG% ."
                withCredentials([usernamePassword(credentialsId: "${DOCKER_HUB_ID}", passwordVariable: 'PASS', usernameVariable: 'USER')]) {
                    bat "echo %PASS% | docker login -u %USER% --password-stdin"
                    bat "docker push %DOCKER_IMAGE%:%DOCKER_TAG%"
                }
            }
        }
        stage('Automated K8s Cleanup') {
            steps {
                script {
                    withKubeConfig([credentialsId: "${K8S_CONFIG_ID}"]) {
                        // Purane kisi bhi conflict ko khatam karne ke liye
                        // Ingress aur purane microservices ko automation se delete karna
                        bat "kubectl delete ingress micro-app-ingress --ignore-not-found"
                        bat "kubectl delete deployment backend frontend postgres-db --ignore-not-found"
                    }
                }
            }
        }
        stage('Force Deploy Car Website') {
            steps {
                script {
                    withKubeConfig([credentialsId: "${K8S_CONFIG_ID}"]) {
                        // Nayi image tag ko inject karna
                        powershell "((Get-Content k8s/deployment.yaml) -replace 'amarjeet001/car-website:latest', '${DOCKER_IMAGE}:${DOCKER_TAG}') | Set-Content k8s/deployment.yaml"
                        
                        // Fresh Deployment
                        bat "kubectl apply -f k8s/"
                        
                        // Rollout restart taaki pods 100% naye code ke sath chalein
                        bat "kubectl rollout restart deployment car-website-deployment"
                    }
                }
            }
        }
    }
}

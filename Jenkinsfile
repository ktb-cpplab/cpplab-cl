pipeline {
    agent any

    environment {
        REPO = 'github_id/repo_name'
        ECR_REPO = '891612581533.dkr.ecr.ap-northeast-2.amazonaws.com/namespace/docker'
        ECR_CREDENTIALS_ID = 'ecr:ap-northeast-2:AWS_CREDENTIALS'
        GITHUB_CREDENTIALS_ID = 'github_token'
        REMOTE_USER = 'ubuntu'
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    currentBuild.description = 'Checkout'
                    git branch: 'develop', url: "https://github.com/ktb-cpplab/cpplab-cl.git", credentialsId: "$GITHUB_CREDENTIALS_ID"
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    currentBuild.description = 'Build Docker Image'
                    dockerImage = docker.build("${ECR_REPO}:latest")
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    currentBuild.description = 'Push to ECR'
                    docker.withRegistry("https://${ECR_REPO}", "$ECR_CREDENTIALS_ID") {
                        dockerImage.push("latest")
                    }
                }
            }
        }
    }
}

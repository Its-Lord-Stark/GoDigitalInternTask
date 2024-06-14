pipeline {
    agent any

    environment {
        AWS_DEFAULT_REGION = 'ap-south-1'
        ECR_REPOSITORY = 'aws-data-pipeline-repo'
        IMAGE_TAG = 'latest'
        AWS_ACCOUNT_ID = '939533572395'
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Its-Lord-Stark/aws-data-pipeline.git'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    def appImage = docker.build("${env.ECR_REPOSITORY}:${env.IMAGE_TAG}")
                }
            }
        }
        stage('Push Docker Image to ECR') {
            steps {
                withAWS(credentials: 'aws-credentials-id', region: 'ap-south-1') {
                    script {
                        docker.withRegistry("https://${env.AWS_ACCOUNT_ID}.dkr.ecr.${env.AWS_DEFAULT_REGION}.amazonaws.com", 'ecr:ap-south-1:aws') {
                            def appImage = docker.image("${env.ECR_REPOSITORY}:${env.IMAGE_TAG}")
                            appImage.push()
                        }
                    }
                }
            }
        }
        stage('Deploy with Terraform') {
            steps {
                withAWS(credentials: 'aws-credentials-id', region: 'ap-south-1') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
    }
}
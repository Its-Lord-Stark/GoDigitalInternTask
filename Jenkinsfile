pipeline {
    agent any

   environment {
        AWS_ACCOUNT_ID = '939533572395'
        AWS_DEFAULT_REGION = 'ap-south-1'
        ECR_REPOSITORY = 'aws-data-pipeline-repo'
        IMAGE_TAG = 'latest'
        AWS_CREDENTIALS_ID = 'aws-credentials-id'  // Make sure this matches your configured credentials in Jenkins
    }

    stages {
        stage('Checkout') {
            steps {
                git 'https://github.com/Its-Lord-Stark/aws-data-pipeline'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${ECR_REPOSITORY}:${IMAGE_TAG}")
                }
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                withAWS(credentials: "${AWS_CREDENTIALS_ID}", region: "${AWS_DEFAULT_REGION}") {
                    script {
                        docker.withRegistry("https://${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com", "${AWS_CREDENTIALS_ID}") {
                            def appImage = docker.image("${ECR_REPOSITORY}:${IMAGE_TAG}")
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

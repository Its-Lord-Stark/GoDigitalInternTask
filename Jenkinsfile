pipeline {
    agent any

    environment {
        AWS_ACCOUNT_ID = '939533572395'
        AWS_DEFAULT_REGION = 'ap-south-1'
        ECR_REPOSITORY = 'aws-data-pipeline-repo'
        IMAGE_TAG = 'latest'
        AWS_CREDENTIALS_ID = 'aws-cred2'  // Ensure this matches your configured credentials in Jenkins
        GIT_REPOSITORY = 'https://github.com/Its-Lord-Stark/aws-data-pipeline'
        GIT_BRANCH = 'main'  // Update to your branch name
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    checkout([$class: 'GitSCM', branches: [[name: "${GIT_BRANCH}"]],
                        userRemoteConfigs: [[url: "${GIT_REPOSITORY}"]]])
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    def dockerImage = docker.build("${ECR_REPOSITORY}:${IMAGE_TAG}")
                }
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'aws-cred', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
                    script {
                        def dockerLoginCmd = "echo \"${AWS_SECRET_ACCESS_KEY}\" | docker login -u AWS --password-stdin https://939533572395.dkr.ecr.ap-south-1.amazonaws.com"
                        sh dockerLoginCmd

                        // Push Docker image to ECR
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
                withAWS(credentials: 'aws-cred', region: 'ap-south-1') {
                    sh 'terraform init'
                    sh 'terraform apply -auto-approve'
                }
            }
        }
    }
}

// pipeline {
//     agent any

//     environment {
//         AWS_ACCOUNT_ID = '939533572395'
//         AWS_DEFAULT_REGION = 'ap-south-1'
//         ECR_REPOSITORY = 'aws-data-pipeline-repo'
//         IMAGE_TAG = 'latest'
//         AWS_CREDENTIALS_ID = 'aws-cred2'  // Ensure this matches your configured credentials in Jenkins
//         GIT_REPOSITORY = 'https://github.com/Its-Lord-Stark/aws-data-pipeline'
//         GIT_BRANCH = 'main'  // Update to your branch name
//     }

//     stages {
//         stage('Checkout') {
//             steps {
//                 script {
//                     checkout([$class: 'GitSCM', branches: [[name: "${GIT_BRANCH}"]],
//                         userRemoteConfigs: [[url: "${GIT_REPOSITORY}"]]])
//                 }
//             }
//         }

//         stage('Build Docker Image') {
//             steps {
//                 script {
//                     def dockerImage = docker.build("${ECR_REPOSITORY}:${IMAGE_TAG}")
//                 }
//             }
//         }

//         stage('Push Docker Image to ECR') {
//             steps {
//                 withCredentials([usernamePassword(credentialsId: 'aws-cred2', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
//                     script {
//                         def dockerLoginCmd = "echo \"${AWS_SECRET_ACCESS_KEY}\" | docker login -u AWS --password-stdin https://939533572395.dkr.ecr.ap-south-1.amazonaws.com"
//                         sh dockerLoginCmd

//                         // Push Docker image to ECR
//                         docker.withRegistry("https://${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_DEFAULT_REGION}.amazonaws.com", "${AWS_CREDENTIALS_ID}") {
//                             def appImage = docker.image("${ECR_REPOSITORY}:${IMAGE_TAG}")
//                             appImage.push()
//                         }
//                     }
//                 }
//             }
//         }

//         stage('Deploy with Terraform') {
//             steps {
//                 withAWS(credentials: 'aws-cred2', region: 'ap-south-1') {
//                     sh 'terraform init'
//                     sh 'terraform apply -auto-approve'
//                 }
//             }
//         }
//     }
// }



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
                withCredentials([string(credentialsId: 'aws-cred', variable: 'AWS_ACCESS_KEY_ID'), string(credentialsId: 'aws-secret-access-key', variable: 'AWS_SECRET_ACCESS_KEY')]) {
                    script {
                        if (isUnix()) {
                            sh '''
                            $(aws ecr get-login --no-include-email --region ${AWS_REGION})
                            docker tag ${DOCKER_IMAGE} ${ECR_REGISTRY}/${ECR_REPOSITORY}:${BUILD_NUMBER}
                            docker push ${ECR_REGISTRY}/${ECR_REPOSITORY}:${BUILD_NUMBER}
                            '''
                        } else {
                            bat '''
                            FOR /F "tokens=*" %%i IN ('aws ecr get-login-password --region %AWS_REGION%') DO docker login --username AWS --password %%i %ECR_REGISTRY%
                            docker tag %DOCKER_IMAGE% %ECR_REGISTRY%/%ECR_REPOSITORY%:%BUILD_NUMBER%
                            docker push %ECR_REGISTRY%/%ECR_REPOSITORY%:%BUILD_NUMBER%
                            '''
                        }
                    }
                }
            }
        }

        stage('Deploy with Terraform') {
            steps {
                withAWS(credentials: 'aws-cred', region: 'ap-south-1') {
                    bat 'terraform init'
                    bat 'terraform apply -auto-approve'
                }
            }
        }
    }
}

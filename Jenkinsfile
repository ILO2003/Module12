#!/usr/bin/env groovy
library identifier: 'jenkins-shared-library@master', retriever: modernSCM([
    $class: 'GitSCMSource',
    remote: 'https://github.com/ILO2003/Module9-SL.git',
    credentialsId: 'github-credentials'
])

pipeline {   
    agent any
    tools {
        maven 'maven-3.9'
    }
    environment {
        IMAGE_NAME = 'ilo2003/demo-app:java-maven-2.0'
    }
    stages {
        stage('Build App') {
            steps {
                script {
                    echo 'Building application jar...'
                    echo 'Testing CI/CD'
                    buildJar()
                }
            }
        }
        stage('Build Image') {
            steps {
                script {
                    echo 'Building the Docker image...'
                    buildImage(env.IMAGE_NAME)
                    dockerLogin()
                    dockerPush(env.IMAGE_NAME)
                }
            }
        }
        stage('Provision Server') {
            environment {
                AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key_id')
                AWS_SECRET_ACCESS_KEY = credentials('jenkins-aws_secret_access_key')
                TF_VAR_env_prefix = 'test'
            }
            steps {
                script {
                    dir('terraform') {
                        sh 'terraform init'
                        sh 'terraform apply --auto-approve'
                        EC2_PUBLIC_IP = sh(
                            script: 'terraform output ec2-public_ip',
                            returnStdout: true
                        ).trim()
                    }
                }
            }
        }
        stage('Deploy') {
            environment {
                DOCKER_CREDS = credentials('docker-hub-repo')
            }
            steps {
                script {
                    echo 'Waiting for EC2 server to initialize...'
                    sleep(time: 90, unit: 'SECONDS')
                    
                    echo 'Deploying Docker image to EC2...'
                    echo "EC2_PUBLIC_IP: ${EC2_PUBLIC_IP}"
                    
                    def shellCmd = "bash ./server-cmds.sh ${IMAGE_NAME} ${DOCKER_CREDS_USR} ${DOCKER_CREDS_PSW}"
                    def ec2Instance = "ec2-user@${EC2_PUBLIC_IP}"
                    
                    sshagent(['server-ssh-key']) {
                        sh "scp -o StrictHostKeyChecking=no server-cmds.sh ${ec2Instance}:/home/ec2-user"
                        sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ${ec2Instance}:/home/ec2-user"
                        sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmd}"
                    }
                }
            }
        }
    }
}

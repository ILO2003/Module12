#!/usr/bin.env groovy
library identifier: 'jenkins-shared-library@master', retriever: modernSCM(
    [$class: 'GitSCMSource',
    remote: 'https://github.com/ILO2003/Module9-SL.git',
    credentialsID: 'github-credentials'
    ]
)

pipeline {   
    agent any
    tools{
        maven 'maven-3.9'
    }
        stages {
            stage('increment version'){
              when {
                expression {
                  return env.GIT_BRANCH == "master"
                }
            }
            steps{
                script {
                echo 'incrementing app version ...'
                sh 'mvn build-helper:parse-version versions:set \
                    -DnewVersion=\\\${parsedVersion.majorVersion}.\\\${parsedVersion.minorVersion}.\\\${parsedVersion.nextIncrementalVersion} \
                    versions:commit '
                def matcher = readFile('pom.xml')  =~ '<version>(.+)</version>'
                def version = matcher[0][1]
                env.IMAGE_NAME = "ilo2003/demo-app:$version-$BUILD_NUMBER"

                }
            }
        }
            stage('build app') {
            steps {
                echo 'building application jar...'
                echo "testing Ci/cd"
                buildJar()
            }
        }
            stage('build image') {
            steps {
                script {
                    echo 'building the docker image...'
                    buildImage(env.IMAGE_NAME)
                    dockerLogin()
                    dockerPush(env.IMAGE_NAME)
                }
            }
        } 
             stage("deploy") {
                 when {
                expression {
                  return env.GIT_BRANCH == "master"
                }
            }
            steps {
                script {
                    echo "Deploying the application..."
                    
                    def shellCmd = "bash ./server-cmds.sh ${IMAGE_NAME}"
                    def ec2Instance = "ec2-user@16.171.57.173"

                    sshagent(['ec2-server-key-aws']) {
                        sh "scp -o StrictHostKeyChecking=no server-cmds.sh ${ec2Instance}:/home/ec2-user"
                        sh "scp -o StrictHostKeyChecking=no docker-compose.yaml ${ec2Instance}:/home/ec2-user"
                        sh "ssh -o StrictHostKeyChecking=no ${ec2Instance} ${shellCmd}"
                    }
                }
            }
        }  
        stage("commit version update") {
            when {
                expression {
                  return env.GIT_BRANCH == "master"
                }
            }
                    steps {
                        script {
                            withCredentials([string(credentialsId: 'github-token', variable: 'TOKEN')]){
                                sh 'git config --global user.email "jenkins@example.com"'
                                sh 'git config --global user.name "jenkins"'

                                sh 'git status'
                                sh 'git branch'
                                sh 'git config --list'
                                sh "git remote set-url origin https://${TOKEN}@github.com/ILO2003/Module9.git"
                                sh 'git add .'
                                sh 'git commit -m "CI: version bump"'
                                sh 'git push -f origin HEAD:master'
                            }
                        }
                    }
                }             
    }
} 

pipeline {
    agent any

    tools {
        nodejs 'NodeJS'
    }

    environment {
        PORT = "${env.BRANCH_NAME == 'main' ? '3000' : '3001'}"
        IMAGE = "${env.BRANCH_NAME == 'main' ? 'nodemain:v1.0' : 'nodedev:v1.0'}"
        CONTAINER = "${env.BRANCH_NAME == 'main' ? 'main-container' : 'dev-container'}"
        DOCKER_REPO = "tanaybansal"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
            }
        }

        stage('Lint Dockerfile') {
            steps {
                sh 'docker run --rm -i hadolint/hadolint < Dockerfile || true'
            }
        }

        stage('Build') {
            steps {
                sh 'chmod +x scripts/build.sh'
                sh './scripts/build.sh'
            }
        }

        stage('Test') {
            steps {
                sh 'chmod +x scripts/test.sh'
                sh './scripts/test.sh'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t $IMAGE .'
            }
        }

        stage('Trivy Scan') {
            steps {
                sh 'docker run --rm aquasec/trivy image $IMAGE || true'
            }
        }

        stage('Stop Old Container') {
            steps {
                sh 'docker rm -f $CONTAINER || true'
            }
        }

        stage('Deploy Locally') {
            steps {
                sh '''
                docker run -d \
                --name $CONTAINER \
                -p $PORT:3000 \
                $IMAGE
                '''
            }
        }

        stage('Push Image to DockerHub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-creds', usernameVariable: 'USER', passwordVariable: 'PASS')]) {

                        sh 'echo $PASS | docker login -u $USER --password-stdin'

                        if (env.BRANCH_NAME == 'main') {
                            sh '''
                            docker tag nodemain:v1.0 $DOCKER_REPO/nodemain:v1.0
                            docker push $DOCKER_REPO/nodemain:v1.0
                            '''
                        } else {
                            sh '''
                            docker tag nodedev:v1.0 $DOCKER_REPO/nodedev:v1.0
                            docker push $DOCKER_REPO/nodedev:v1.0
                            '''
                        }
                    }
                }
            }
        }

        stage('Trigger Deployment') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'main') {
                        build job: 'Deploy_to_main'
                    } else {
                        build job: 'Deploy_to_dev'
                    }
                }
            }
        }
    }
}

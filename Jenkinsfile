pipeline {
    agent any

    tools {
        nodejs 'NodeJS'
    }

    environment {
        PORT = "${env.BRANCH_NAME == 'main' ? '3000' : '3001'}"
        IMAGE = "${env.BRANCH_NAME == 'main' ? 'nodemain:v1.0' : 'nodedev:v1.0'}"
        CONTAINER = "${env.BRANCH_NAME == 'main' ? 'main-container' : 'dev-container'}"
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
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

        stage('Stop Old Container') {
            steps {
                sh 'docker rm -f $CONTAINER || true'
            }
        }

        stage('Deploy') {
            steps {
                sh '''
                docker run -d \
                --name $CONTAINER \
                -p $PORT:3000 \
                $IMAGE
                '''
            }
        }
        stage('Push') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'main' ) {
                        sh '''
                        docker tag nodemain:v1.0 tanaybansal/nodemain:v1.0
                        docker login -u $DOCKER_USER -p $DOCKER_PASS
                        docker push tanaybansal/nodemain:v1.0
                        '''
		   }
                   else {
		       sh '''
		       docker tag nodedev:v1.0 tanaybansal/nodedev:v1.0
                       docker login -u $DOCKER_USER -p $DOCKER_PASS
                       docker push tanaybansal/nodedev:v1.0
                       '''
                   }
               }
           }
       }
    }
}

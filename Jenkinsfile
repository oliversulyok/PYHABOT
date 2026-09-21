pipeline {
    agent any

    parameters {
        booleanParam(name: 'DEPLOY_ENABLED', defaultValue: true)
    }

    environment {
        IMAGE_NAME = 'pyphbot'
        IMAGE_TAG = '0.1'
        CONTAINER_NAME = 'pyphbot'
    }

    stages {
        stage('Checkout Source') {
            steps {
                checkout scm
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build --progress=plain -t \({IMAGE_NAME}:\){IMAGE_TAG} .'
            }
        }

        stage('Verify Container') {
            steps {
                sh 'docker run --rm \({IMAGE_NAME}:\){IMAGE_TAG} python -c "import importlib.metadata; print(\'Verification passed. Packages installed:\', len(list(importlib.metadata.distributions())))"'
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    sh 'docker rm -f ${CONTAINER_NAME} || true'
                    sh 'docker run -d --name \({CONTAINER_NAME} --restart unless-stopped\){IMAGE_NAME}:${IMAGE_TAG}'
                }
            }
        }
    }

    post {
        success {
            echo "Successfully built, verified, and deployed \({IMAGE_NAME}:\){IMAGE_TAG}"
        }
        failure {
            echo "Pipeline failed during build, verification, or deployment."
        }
    }
}
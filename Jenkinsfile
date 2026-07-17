pipeline {
  agent any

  tools {
    nodejs 'NodeJS-7.8.0'
  }

  environment {
    IMAGE_VERSION = 'v1.0'
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
        echo "Building branch: ${env.BRANCH_NAME}"
      }
    }

    stage('Set Environment') {
      steps {
        script {
          if (env.BRANCH_NAME == 'main') {
            env.APP_ENV = 'main'
            env.APP_PORT = '3000'
            env.IMAGE_NAME = 'nodemain'
            env.CONTAINER_NAME = 'nodemain'
          } else if (env.BRANCH_NAME == 'dev') {
            env.APP_ENV = 'dev'
            env.APP_PORT = '3001'
            env.IMAGE_NAME = 'nodedev'
            env.CONTAINER_NAME = 'nodedev'
          } else {
            error("Unsupported branch: ${env.BRANCH_NAME}")
          }

          echo "Environment: ${env.APP_ENV}"
          echo "Port: ${env.APP_PORT}"
          echo "Image: ${env.IMAGE_NAME}:${env.IMAGE_VERSION}"
          echo "Container: ${env.CONTAINER_NAME}"
        }
      }
    }

    stage('Build') {
      steps {
        sh './scripts/build.sh'
      }
    }

    stage('Test') {
      steps {
        sh './scripts/test.sh'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh '''
          docker build \
            -t "${IMAGE_NAME}:${IMAGE_VERSION}" \
            .
        '''
      }
    }

    stage('Deploy') {
      steps {
        sh '''
          docker rm -f "${CONTAINER_NAME}" 2>/dev/null || true

          docker run -d \
            --name "${CONTAINER_NAME}" \
            --restart unless-stopped \
            -p "${APP_PORT}:3000" \
            "${IMAGE_NAME}:${IMAGE_VERSION}"
        '''
      }
    }

    stage('Verify Deployment') {
      steps {
        sh '''
          sleep 10
          docker ps --filter "name=${CONTAINER_NAME}"
          curl --fail --retry 10 --retry-delay 3 \
            "http://localhost:${APP_PORT}"
        '''
      }
    }
  }

  post {
    success {
      echo "Deployment completed: http://localhost:${env.APP_PORT}"
    }

    failure {
      echo "Pipeline failed for branch ${env.BRANCH_NAME}"
    }

    always {
      sh 'docker images | grep -E "nodemain|nodedev" || true'
      sh 'docker ps -a --filter "name=nodemain" --filter "name=nodedev" || true'
    }
  }
}

pipeline {
  agent any
  stages {
    stage('Lint') {
      agent {
        docker {
          image 'python:3.11.3-buster'
          args '-u 0'
        }
      }
      when {
        anyOf {
          branch 'feature-*'
          branch 'fix-*'
        }
      }
      steps {
        sh "pip install poetry"
        sh "poetry install --with dev"
        sh "poetry run -- black --check *.py"
      }
    }
    stage('Build') {
      when {
        branch 'master'
      }
      steps {
        script {
          def image = docker.build("dmitry231187/dos14-bpzb_authz:${env.GIT_COMMIT}")
          docker.withRegistry('', 'dockerhub-st.dmitry') {
            image.push()
          }
        }
      }
    }
  }
}


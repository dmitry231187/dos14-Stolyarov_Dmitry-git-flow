pipeline {
  agent {
    docker {
      image 'python:3.11.3-buster'
      args '-u 0'
    }
  }
  stages {
    stage('Lint') {
      when { anyOf { branch 'feature-*'; branch 'fix-*' } }
      steps {
        sh "pip install poetry"
        sh "poetry install --with dev"
        sh "poetry run -- black --check *.py"
      }
    }
    stage('Deploy') {
      // when { branch 'master' }
      steps {
        script {
          echo sh(returnStdout: true, script: 'env')
        }
      }
    }
  }
}


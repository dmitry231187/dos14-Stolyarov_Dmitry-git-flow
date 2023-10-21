pipeline {
  agent {
    docker {
      image 'python:3.11.3-buster'
      args '-u 0'
    }
  }
  stages {
    stage('Lint') {
      steps {
        sh "pip install poetry"
        sh "poetry install --with dev"
        sh "poetry run -- black --check *.py"
      }
    }
    stage('Build') {
      steps {
        echo 's1'
      }
    }
    stage('Test') {
      steps {
        echo 's2'
      }
    }
    stage('Deploy') {
      when { branch 'master' }
      steps {
        echo 'build and push'
      }
    }
  }
}


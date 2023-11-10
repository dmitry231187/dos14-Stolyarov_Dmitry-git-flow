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
        script { build = false }
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
    stage('Update Helm Chart') {
      when {
        branch 'argocd'
      }
      steps {
        script {
          sh "git checkout argocd"
          sh "git fetch --all"
          sh "git reset --hard origin/develop"

          def path_to_file = 'charts/authz/values.yaml'
          def data = readYaml file: path_to_file

          // Change image.tag in file
          data.image.tag = "48eb5988cd74040ab8b4563724c1786626555930"

          sh "rm $path_to_file"
          writeYaml file: path_to_file, data: data

          withCredentials([string(credentialsId: 'st.dmitry_github', variable: 'SECRET')]) {
            sh "git config --global user.name 'Jenkins'"
            sh "git config --global user.email 'leshiy74@yandex.ru'"
            sh "git add $path_to_file"
            sh "git commit -m 'JENKINS: add new image tag 48eb5988cd74040ab8b4563724c1786626555930 for test CD'"
            sh "git remote set-url origin https://${SECRET}@github.com/dmitry231187/dos14-Stolyarov_Dmitry-git-flow.git"
            sh "git push --force"
          }
        }
      }
    }
  }
}


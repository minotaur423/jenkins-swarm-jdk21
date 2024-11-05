pipeline {
  agent { label 'jdk17' }
  options {
    disableConcurrentBuilds()
    buildDiscarder logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '30', numToKeepStr: '10')
  }
  environment {
    project = 'jenkins-swarm-jdk21'
    tag = 'default'
    commitNum = 'default'
  }
  stages{
    stage('Preparation') {
      steps {
        sh "docker system prune -af"
        echo "STARTED:\nJob '${env.JOB_NAME} [${env.BUILD_NUMBER}]'\n(${env.BUILD_URL})"
        checkout scmGit(branches: [[name: '*/main']], extensions: [], userRemoteConfigs: [[credentialsId: 'github-creds', url: 'https://github.com/minotaur423/jenkins-swarm-jdk21.git']])
        script {
          commitNum = sh(script: "git rev-parse --short HEAD", returnStdout: true).trim()
          if(env.BRANCH_NAME.contains('/')) {
            tag = sh(script: "echo ${BRANCH_NAME} |awk -F '/' '{print \$2}'", returnStdout: true).trim()
          } else {
            tag = env.BRANCH_NAME
          }
        }
      }
    }
    stage('Build Docker') {
      steps {
          timeout(10) {
            withCredentials([usernamePassword(credentialsId: 'docker_cred', passwordVariable: 'ARTIFACTORY_DOCKER_PWD', usernameVariable: 'ARTIFACTORY_DOCKER_USER')]) {
              sh 'echo ${ARTIFACTORY_DOCKER_PWD} | docker login -u ${ARTIFACTORY_DOCKER_USER} --password-stdin ${ARTIFACTORY_DOCKER_SERVER}'
            }
            sh "docker build --pull --no-cache -t ${ARTIFACTORY_DOCKER_SERVER}/docker/${project}:${tag}.${commitNum} ."
            sh "docker build -t ${ARTIFACTORY_DOCKER_SERVER}/docker/${project}:${tag}-latest ."
          }
      }
    }
    stage('Push Docker') {
      steps {
          sh "docker push ${ARTIFACTORY_DOCKER_SERVER}/docker/${project}:${tag}.${commitNum}"
          sh "docker push ${ARTIFACTORY_DOCKER_SERVER}/docker/${project}:${tag}-latest"
      }
    }
  }
  post {
    always {
      script {
        tag = "${tag}"
        sh "docker logout"
      }
    }
    success {
      script {
        latestMessage = "\n---also tagged with 'latest'"
      }
      echo "SUCCESSFUL\nJob '${env.JOB_NAME} [${env.BUILD_NUMBER}]'\nDocker Image: '${tag}'${latestMessage}\n(${env.BUILD_URL})"
    }
    failure {
      echo "FAILED\nJob '${env.JOB_NAME} [${env.BUILD_NUMBER}]'\n(${env.BUILD_URL})"
    }
  }
}

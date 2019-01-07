class Globals {
  static boolean userInput = true
  static boolean didTimeout = false
}

pipeline {
  agent none
  stages {
    stage('Linting') {
      agent any
      steps {
        sh 'make lint'
      }
      post {
        always {
          sh 'make stop'
        }
      }

    }

    stage('Test') {
      agent any
      steps {
        sh 'make test'
      }
      post {
        always {
          sh 'make stop'
        }
      }
    }

    stage('Publish stable tag') {
      agent any
      when{
        branch 'master'
        beforeAgent true
      }

      steps {
        publishStableTag()
      }
    }

    stage('Deploy to staging') {
      agent any
      when{
        branch 'master'
        beforeAgent true
      }

      steps {
        deploy_staging()
      }
    }

    stage('Confirm deploy to production') {
      agent none
      when {
        branch 'master'
        beforeAgent true
      }
      steps {
        wait_for_input('production')
      }
    }

    stage('Deploy to production') {
      agent any
      when{
        branch 'master'
        beforeAgent true
      }

      steps {
        deploy_production()
      }
    }
  }

  post {
    failure {
      script {
        if(deployCancelled()) {
          setBuildStatus("Build successful", "SUCCESS");
          return
        }
      }
      setBuildStatus("Build failed", "FAILURE");
    }

    success {
      setBuildStatus("Build successful", "SUCCESS");
    }
  }
}

void setBuildStatus(String message, String state) {
  step([
      $class: "GitHubCommitStatusSetter",
      reposSource: [$class: "ManuallyEnteredRepositorySource", url: "https://github.com/alphagov/govwifi-post-auth-api"],
      contextSource: [$class: "ManuallyEnteredCommitContextSource", context: "ci/jenkins/build-status"],
      errorHandlers: [[$class: "ChangingBuildStatusErrorHandler", result: "UNSTABLE"]],
      statusResultSource: [ $class: "ConditionalStatusResultSource", results: [[$class: "AnyBuildResult", message: message, state: state]] ]
  ]);
}

def wait_for_input(deploy_environment) {
  if (deployCancelled()) {
    setBuildStatus("Build successful", "SUCCESS");
    return
  }
  try {
    timeout(time: 5, unit: 'MINUTES') {
      input "Do you want to deploy to ${deploy_environment}?"
    }
  } catch (err) {
    def user = err.getCauses()[0].getUser()

    if('SYSTEM' == user.toString()) { // SYSTEM means timeout.
      Globals.didTimeout = true
      echo "Release window timed out, to deploy please re-run"
    } else {
      Globals.userInput = false
      echo "Aborted by: [${user}]"
    }
  }
}

def deploy_staging() {
  deploy('staging')
}

def deploy_production() {
  if(deployCancelled()) {
    setBuildStatus("Build successful", "SUCCESS");
    return
  }
  deploy('production')
}

def deploy(deploy_environment) {
  echo "${deploy_environment}"

  sh('git fetch')
  sh('git checkout stable')

  docker.withRegistry(env.AWS_ECS_API_REGISTRY) {
    sh("eval \$(aws ecr get-login --no-include-email)")
    def appImage = docker.build(
      "govwifi/logging-api:${deploy_environment}",
      "--build-arg BUNDLE_INSTALL_CMD='bundle install --without test' ."
    )
    appImage.push()
  }

  if(deploy_environment == 'production') { deploy_environment = 'wifi' }

  cluster_name = "${deploy_environment}-api-cluster"
  service_name = "logging-api-service-${deploy_environment}"

  sh("aws ecs update-service --force-new-deployment --cluster ${cluster_name} --service ${service_name} --region eu-west-2")
}


def publishStableTag() {
  sshagent(credentials: ['govwifi-jenkins']) {
    sh('export GIT_SSH_COMMAND="ssh -oStrictHostKeyChecking=no"')
    sh("git tag -f stable HEAD")
    sh("git push git@github.com:alphagov/govwifi-post-auth-api.git --force --tags")
  }
}

def deployCancelled() {
  if(Globals.didTimeout || Globals.userInput == false) {
    return true
  }
}

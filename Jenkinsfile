import hudson.model.Result
import jenkins.model.CauseOfInterruption.UserInterruption
properties([
   // Jenkins executions properties, keeping 20 executions, getting rollbackBuild Param and 2h timeout
  buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '5', numToKeepStr: '20')), 
  parameters([string(defaultValue: '', description: '', name: 'rollBackBuild')]), 
  pipelineTriggers([[$class: 'PeriodicFolderTrigger', interval: '2h']])
])
  
  node_name = 'mac-mini-1'
  branch_type = get_branch_type "${env.BRANCH_NAME}"
  try {
    stopPreviousRunningBuilds()
    if (branch_type == "master") {
        launchJiraBot() 
    } else {
        launchUnitTests()
    }
  }
  catch (err) {
      currentBuild.result = "FAILURE"   
      throw err
  }
  finally{
      notifyBuildStatus(currentBuild.result)
  }


////// Stoping old running builds to release slots of executors
def stopPreviousRunningBuilds() {
  def jenkins = Hudson.instance
  def jobName = env.JOB_NAME.split('/')[0]
  def jobBaseName = env.JOB_BASE_NAME
  def builds = jenkins.getItem(jobName).getItem(jobBaseName).getBuilds()

  builds.each{ build ->
    def exec = build.getExecutor()

    if (build.number < currentBuild.number && exec != null) {
      exec.interrupt(
        Result.ABORTED,
        build.result = Result.ABORTED,
        new CauseOfInterruption.UserInterruption(
          "Aborted by newer build #${currentBuild.number}"
        )
      )
    } 
  }
}

def launchJiraBot() {
    node(node_name) {
        stage ("Move Tickets") {
            withCredentials([usernamePassword(credentialsId: '79356c55-62e0-41c0-8a8c-85a56ad45e11', 
                                              passwordVariable: 'IOS_JIRA_PASSWORD', 
                                              usernameVariable: 'IOS_JIRA_USERNAME')]) {
                sh 'ruby Scripts/githooks/post-merge'
            }
        }
    }
}    

////////// build, deploy and testing func definition /////////
def launchUnitTests(){
  node(node_name){
    stage ("Unit Test"){
    checkout([
    $class: 'GitSCM',
    branches: scm.branches,
    extensions: [[$class: 'CloneOption', noTags: false, shallow: true, depth: 0, reference: '']],
    userRemoteConfigs: scm.userRemoteConfigs,
    ])
	    sh 'export LC_ALL=en_US.UTF-8'
	    // we add an || true in case there are no simulators available to avoid job to fail
	    sh 'killall "Simulator" || true'  
    	withCredentials([usernamePassword(credentialsId: 'fc7205d5-6635-441c-943e-d40b5030df0f', passwordVariable: 'LG_GITHUB_PASSWORD', usernameVariable: 'LG_GITHUB_USER')]) {
        sh 'fastlane ciJenkins'
      }
    }
  }
}

def get_branch_type(String branch_name) {
    def dev_pattern = ".*dev"
    def release_pattern = ".*release-.*"
    def feature_pattern = ".*feature-.*"
    def hotfix_pattern = ".*hotfix-.*"
    def master_pattern = ".*master"
    def pr_pattern     = "^PR-\\d+\$" 

    if (branch_name =~ dev_pattern) {
        return "dev"
    } else if (branch_name =~ release_pattern) {
        return "release"
    } else if (branch_name =~ master_pattern) {
        return "master"
    } else if (branch_name =~ feature_pattern) {
        return "feature"
    } else if (branch_name =~ hotfix_pattern) {
        return "hotfix"
    } else if (branch_name =~ pr_pattern) {
        return "pr"
    } else {
        return null;
    }
}

def notifyBuildStatus(String buildStatus = 'STARTED') {
  buildStatus =  buildStatus ?: 'SUCCESSFUL'
  def slack_channel = "${env.SLACK_CHANNEL}"
  def red = '#FF0000'
  def yellow = '#FFCC00'
  def green = '#228B22'
  def subject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
  def summary = "${subject} (${env.BUILD_URL})"

  if (buildStatus == 'STARTED') {
     slackSend (channel: slack_channel ,color: yellow, message: summary)  
  } 
  else if (buildStatus == 'SUCCESSFUL') {
     slackSend (channel: slack_channel ,color: green, message: summary) 
  }
  else if (buildStatus == 'ABORTED') {

  }
  else { 
     slackSend (channel: slack_channel ,color: red, message: summary)  
  } 
}

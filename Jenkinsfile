import hudson.model.Result
import jenkins.model.CauseOfInterruption.UserInterruption
properties([
   // Jenkins executions properties, keeping 20 executions, getting rollbackBuild Param and 2h timeout
  buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '5', numToKeepStr: '20')), 
  parameters([string(defaultValue: '', description: '', name: 'rollBackBuild')]), 
  pipelineTriggers([[$class: 'PeriodicFolderTrigger', interval: '2h']])
])
  
  node_name = 'mac-mini-1'
  try {
    stopPreviousRunningBuilds()
    launchUnitTests()
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
    	    sh 'fastlane ciJenkins'
    }
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
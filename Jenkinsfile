properties([
   // Jenkins executions properties, keeping 20 executions, getting rollbackBuild Param and 2h timeout
  buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '', numToKeepStr: '20')), 
  parameters([string(defaultValue: '', description: '', name: 'rollBackBuild')]), 
  pipelineTriggers([[$class: 'PeriodicFolderTrigger', interval: '2h']])
])
  
  node_name = 'mac-mini-1'
  try {
    launchUnitTests()
  }
  catch (err) {
      currentBuild.result = "FAILURE"   
      throw err
  }
  finally{
      notifyBuildStatus(currentBuild.result)
  }

////////// build, deploy and testing func definition /////////
def launchUnitTests(){
  node(node_name){
    stage ("Unit Test"){
	    checkout scm
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
  } else if (buildStatus == 'SUCCESSFUL') {
     slackSend (channel: slack_channel ,color: green, message: summary)  
  } else { 
     slackSend (channel: slack_channel ,color: red, message: summary)  
  }
}
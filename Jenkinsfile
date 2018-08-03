import hudson.model.Result
import jenkins.model.CauseOfInterruption.UserInterruption

properties([
   // Jenkins executions properties, keeping 20 executions, getting rollbackBuild Param and 2h timeout
  buildDiscarder(logRotator(artifactDaysToKeepStr: '', artifactNumToKeepStr: '', daysToKeepStr: '5', numToKeepStr: '15')), 
  parameters([string(defaultValue: '', description: '', name: 'rollBackBuild')]), 
  pipelineTriggers([[$class: 'PeriodicFolderTrigger', interval: '2h']])
])
  
node_name = 'osx-slave'
branch_type = get_branch_type "${env.BRANCH_NAME}"
try {
	parallel (
		"Move Tickets": {
			if (branch_type == "master") {
				markJiraIssuesAsDone() 
			} else if (branch_type == "release") {
				def release_identifier = get_release_identifier "${env.BRANCH_NAME}"
				moveMergedTicketsToTesting(release_identifier)
			}
		},
		"CI": { 
			if (branch_type == "pr") {
				stopPreviousRunningBuilds()
				launchUnitTests() 
        	} 
      	}
    )
} catch (err) {
	currentBuild.result = "FAILURE"   
	throw err
} finally {
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

def moveMergedTicketsToTesting(String release_version) {
	node(node_name) {
		stage ("Move tickets") {
			git branch: 'master', poll: false, url: 'git@github.com:letgoapp/letgo-ios-scripts.git'
			withCredentials([
				usernamePassword(credentialsId: '79356c55-62e0-41c0-8a8c-85a56ad45e11', 
					passwordVariable: 'IOS_JIRA_PASSWORD', 
					usernameVariable: 'IOS_JIRA_USERNAME'),
				usernamePassword(credentialsId: 'fc7205d5-6635-441c-943e-d40b5030df0f', 
					passwordVariable: 'LG_GITHUB_PASSWORD', 
					usernameVariable: 'LG_GITHUB_USER')]) {
			sh "ruby ./scripts/hooks/post-release-creation ${release_version}"
			}	
		}	
	}
}

def markJiraIssuesAsDone() {
	node(node_name) {
		stage ("Move Tickets") {
			git branch: 'master', poll: false, url: 'git@github.com:letgoapp/letgo-ios-scripts.git'
    			withCredentials([
				usernamePassword(credentialsId: '79356c55-62e0-41c0-8a8c-85a56ad45e11', 
					passwordVariable: 'IOS_JIRA_PASSWORD', 
					usernameVariable: 'IOS_JIRA_USERNAME'),
				usernamePassword(credentialsId: 'fc7205d5-6635-441c-943e-d40b5030df0f', 
					passwordVariable: 'LG_GITHUB_PASSWORD', 
					usernameVariable: 'LG_GITHUB_USER')]) {
			sh 'ruby ./scripts/hooks/post-merge'
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
    extensions: [[$class: 'CloneOption', timeout: 100, noTags: false, shallow: true, depth: 0, reference: '']] + [[$class: 'WipeWorkspace']],
    userRemoteConfigs: scm.userRemoteConfigs,
    ])
      sh 'export LC_ALL=en_US.UTF-8'
      sh 'killall "Simulator" || true'
      sh "xcrun simctl list devices |grep 'iPhone' |cut -d '(' -f2 | cut -d ')' -f1 | xargs -I {} xcrun simctl erase '{}' || true"
        
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
    def jira_integration = ".*jiraintegration.*"
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
    } else if (branch_name =~ jira_integration) {
        return "jiraintegration"
    } else {
        return null;
    }
}

def get_release_identifier(String branch_name) {
	return (branch_name =~ /release-(\S*)/).with { matches() ? it[0][1] : null }	
}

def notifyBuildStatus(String buildStatus = 'STARTED') {
  buildStatus =  buildStatus ?: 'SUCCESSFUL'
  def slack_channel = "${env.SLACK_CHANNEL_IOS}"
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



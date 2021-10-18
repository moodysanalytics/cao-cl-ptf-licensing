/*
 * Copyright Moody's Analytics.
 */
@NonCPS
def isJobStartedByTimer() {
    try {
        for ( buildCause in currentBuild.getBuildCauses() ) {
            if (buildCause != null) {
                if (buildCause.shortDescription.contains("Started by timer")) {
                    echo "build started by timer"
                    return true
                }
            }
        }
    } catch(theError) {
        echo "Error getting build cause: ${theError}"
    }
    return false
}
def isJobStartedByScm() {
    try {
        for ( buildCause in currentBuild.getBuildCauses() ) {
            if (buildCause != null) {
                if (buildCause.shortDescription.contains("Started by an SCM change")) {
                    echo "build Started by an SCM change"
                    return true
                }
            }
        }
    } catch(theError) {
        echo "Error getting build cause: ${theError}"
    }
    return false
}
def isJobStartedByUser() {
    try {
        for ( buildCause in currentBuild.getBuildCauses() ) {
            if (buildCause != null) {
                if (buildCause.shortDescription.contains("Started by user")) {
                    echo "build Started by user"
                    return true
                }
            }
        }
    } catch(theError) {
        echo "Error getting build cause: ${theError}"
    }
    return false
}
def isJobStartedByIndexing() {
    try {
        for ( buildCause in currentBuild.getBuildCauses() ) {
            if (buildCause != null) {
                if (buildCause.shortDescription.contains("Branch indexing")) {
                    echo "Branch indexing"
                    return true
                }
            }
        }
    } catch(theError) {
        echo "Error getting build cause: ${theError}"
    }
    return false
}
def isTimerBuild = isJobStartedByTimer()
def isScmBuild = isJobStartedByScm()
def isUserBuild = isJobStartedByUser()
def isBranchIndexingBuild = isJobStartedByIndexing()

def versionAffix = "21_41_0";
def moodysDatabase = "moodys_cl_${versionAffix}";
def moodysUsername = "moodys_cl_${versionAffix}";
def moodysPassword = "a";

pipeline {
    triggers {
        cron 'H H(0-2) * * *'
		pollSCM('H/5 * * * *')
    }
	options {
		buildDiscarder(logRotator(numToKeepStr: '10'))
		disableConcurrentBuilds()
		timestamps()
	}
    agent {label 'windows'}
	environment {
		NUGET_PACKAGES = "${env.WORKSPACE}\\ng-cache"
		NUGET_HTTP_CACHE_PATH = "${env.WORKSPACE}\\http-cache"
	}
	stages {
		stage ('Build') {
			when {
				expression {
				    isScmBuild == true || isUserBuild == true || isBranchIndexingBuild == false
				}
			}
			steps {
				script {
					def msbuild = tool name: 'msbuild', type: 'hudson.plugins.msbuild.MsBuildInstallation'
					if (isUnix()) {
						sh """
							${msbuild} Core.msbuild /p:NugetServer=http://sf1-wbroci101.analytics.moodys.net/NuGet/ /p:SkipCoverage=false /p:WarningLevel=0 /p:Configuration=Release /p:DebugSymbols=false /p:DebugType=none /p:Optimize=true
							"""
					} else {
						powershell """
                            $VERSION = Get-Content 'version' -TotalCount 1
                            $PACKAGE_VERSION = "$VERSION-build.${{ github.run_number }}"
                            Write-Output "Generating Package with version: $PACKAGE_VERSION ..."
                            dotnet pack '${{ env.SOLUTION }}' -o dist /p:DebugSymbols=false /p:DebugType=none /p:Optimize=true -p:Configuration=Release -p:Version=$VERSION -p:PackageVersion=$PACKAGE_VERSION -p:RepositoryType=git -p:RepositoryUrl=https://github.com/${{ github.repository }}.git -p:RepositoryBranch=$Branch -p:RepositoryCommit=${{ github.sha }}
                            dotnet nuget push dist\*.nupkg --source http://sf1-wbroci101.analytics.moodys.net/NuGet/
							"""
					}
				}
			}
		}
		stage ('success'){
			steps {
				script {
					currentBuild.result = 'SUCCESS'
				}
			}
		}
	}
	post {
		failure {
			emailext(
					body: '${SCRIPT, template="jenkins-html-email.template"}',
					mimeType: 'text/html',
					recipientProviders: [[$class: 'CulpritsRecipientProvider'],[$class: 'DevelopersRecipientProvider']],
					subject: '${DEFAULT_SUBJECT}',
					to: 'Prasann.Agrawal@moodys.com;Shiva.Aithal@moodys.com;AnnieSophia.Antony@moodys.com;Steven.Colgan@moodys.com;Varun.DeviReddy@moodys.com;Amit.Dhital@moodys.com;Yogesh.Gurav@moodys.com;Ramesh.Kadam@moodys.com;Daniel.Lee@moodys.com;Steven.Moberg@moodys.com;Venkat.Nistala@moodys.com;Rajeev.Patel@moodys.com;Shantaram.Patil@moodys.com;Boominathan.Perumal@moodys.com;Murali.Ramachandran@moodys.com;Amit.Raturi@moodys.com;John.Siluvaimuthu@moodys.com;Ganhao.Wu@moodys.com')
			script {
				currentBuild.result = 'FAILURE'
			}
		}
		success {
			emailext(
					body: '${SCRIPT, template="jenkins-html-email.template"}',
					mimeType: 'text/html',
					recipientProviders: [[$class: 'CulpritsRecipientProvider'],[$class: 'DevelopersRecipientProvider']],
					subject: '${DEFAULT_SUBJECT}',
					to: 'Prasann.Agrawal@moodys.com;Shiva.Aithal@moodys.com;AnnieSophia.Antony@moodys.com;Steven.Colgan@moodys.com;Varun.DeviReddy@moodys.com;Amit.Dhital@moodys.com;Yogesh.Gurav@moodys.com;Ramesh.Kadam@moodys.com;Daniel.Lee@moodys.com;Steven.Moberg@moodys.com;Venkat.Nistala@moodys.com;Rajeev.Patel@moodys.com;Shantaram.Patil@moodys.com;Boominathan.Perumal@moodys.com;Murali.Ramachandran@moodys.com;Amit.Raturi@moodys.com;John.Siluvaimuthu@moodys.com;Ganhao.Wu@moodys.com')
			xunit([xUnitDotNet(deleteOutputFiles: true, failIfNotNew: true, pattern: '**/**/xunit-results.xml', skipNoTestFiles: true, stopProcessingIfError: false)])
			publishHTML([allowMissing: true, alwaysLinkToLastBuild: false, keepAll: false, reportDir: '', reportFiles: 'index.htm', reportName: 'Code Coverage Report', reportTitles: ''])
		}
	}
}

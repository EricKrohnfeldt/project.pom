def releaseCandidate = false;
pipeline {
	agent none
	stages {
		stage( 'Deploy Snapshot' ) {
			when { beforeAgent true; not { branch pattern: 'master(-\\d+)?', comparator: 'REGEXP' } }
			agent { docker { image env.DOCKER_IMAGE; args env.DOCKER_ARGS; registryUrl env.DOCKER_URL; registryCredentialsId env.DOCKER_CREDS } }
			steps {
				sh 'mvn clean deploy'
			}
		}
		stage( 'Prepare merge' ) {
			when { beforeAgent true; not { branch pattern: 'master(-\\d+)?', comparator: 'REGEXP' } }
			agent { docker { image env.DOCKER_IMAGE; args env.DOCKER_ARGS; registryUrl env.DOCKER_URL; registryCredentialsId env.DOCKER_CREDS } }
			steps {
				sh "git branch -d jenkins_${BUILD_NUMBER} || true"
				sh "git checkout -b jenkins_${BUILD_NUMBER}"
				sh 'git checkout master'
				sh 'git reset --hard origin/master'
				script {
					releaseCandidate = 0 == sh(
						script: "git merge-base --is-ancestor master jenkins_${BUILD_NUMBER} && [ \"\$(git rev-parse master)\" != \"\$(git rev-parse jenkins_${BUILD_NUMBER})\" ]",
						returnStatus: true
					)
				}
			}
		}
		stage( 'Confirm merge' ) {
			when { beforeAgent true; not { branch pattern: 'master(-\\d+)?', comparator: 'REGEXP' }; expression { releaseCandidate } }
			steps {
				milestone 1
				input 'Merge to Master?'
			}
		}
		stage( 'Deploy Release' ) {
			when { beforeAgent true; not { branch pattern: 'master(-\\d+)?', comparator: 'REGEXP' }; expression { releaseCandidate } }
			agent { docker { image env.DOCKER_IMAGE; args env.DOCKER_ARGS; registryUrl env.DOCKER_URL; registryCredentialsId env.DOCKER_CREDS } }
			steps {
				milestone 2
				sh "git branch -d jenkins_${BUILD_NUMBER} || true"
				sh "git checkout -b jenkins_${BUILD_NUMBER}"
				sshagent( [ 'KirbyGitKey' ] ) {
					sh 'git fetch --all'
					sh 'git checkout master'
					sh 'git reset --hard origin/master'
					sh "git merge --ff-only jenkins_${BUILD_NUMBER}"
					sh 'mvn release:prepare release:perform --batch-mode'
				}
			}
		}
	}
	environment {
		DOCKER_IMAGE = 'docker.herb.herbmarshall.com/maven.herb'
		DOCKER_ARGS = '-v maven-data:/home/jenkins/.m2'
		DOCKER_URL = 'https://docker.herb.herbmarshall.com/'
		DOCKER_CREDS = 'Nexus'
	}
}

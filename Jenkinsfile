pipeline {
    agent { label 'Jenkins-Agent' }
    tools {
        jdk 'java21'
        maven 'maven3'
    }
  stages{
        stage("Cleanup Workspace"){
                steps {
                cleanWs()
                }
        }

        stage("Checkout from SCM"){
                steps {
                    git branch: 'main', credentialsId: 'github', url: 'https://github.com/Sree49/AWS'
                }
        }
    stage("Build Application"){
            steps {
                sh "mvn clean package"
            }

       }

       stage("Test Application"){
           steps {
                 sh "mvn test"
           }
       }
      stage("SonarQube Analysis"){
           steps {
	           script {
		        withSonarQubeEnv(credentialsId: 'sonar') { 
                        sh "mvn sonar:sonar"
		        }
	           }	
           }
      }
  }
}

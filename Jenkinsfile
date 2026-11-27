pipeline {
    agent { label 'Jenkins-Agent' }
    tools {
        jdk 'java21'
        maven 'maven3'
    }
	environment {
	    APP_NAME = "app-pipeline"
            RELEASE = "1.0.0"
            DOCKER_USER = "sreenija4363"
            DOCKER_PASS = 'dockersecret'
            IMAGE_NAME = "${DOCKER_USER}" + "/" + "${APP_NAME}"
            IMAGE_TAG = "${RELEASE}-${BUILD_NUMBER}"
	    
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
	  stage('SonarQube Analysis') {
    steps {
        script {
            withSonarQubeEnv('sonarqube') {
                sh '''
                    mvn clean verify \
                    org.sonarsource.scanner.maven:sonar-maven-plugin:sonar
                '''
            }
        }
    }
	  }
		  stage('Quality Gate') {
    steps {
        timeout(time: 5, unit: 'MINUTES') {
            script {
                def qg = waitForQualityGate()
                
                if (qg.status != 'OK') {
                    error "Pipeline aborted due to quality gate failure: ${qg.status}"
                }
            }
        }
    }
}

	   stage("Build & Push Docker Image") {
            steps {
                script {
                    docker.withRegistry('',DOCKER_PASS) {
                        docker_image = docker.build "${IMAGE_NAME}"
                    }

                    docker.withRegistry('',DOCKER_PASS) {
                        docker_image.push("${IMAGE_TAG}")
                        docker_image.push('latest')
                    }
                }
            }

       }

	  stage("Trivy Scan") {
           steps {
               script {
	            sh ('docker run -v /var/run/docker.sock:/var/run/docker.sock aquasec/trivy image sreenija4363/app-pipeline:latest --no-progress --scanners vuln  --exit-code 0 --severity HIGH,CRITICAL --format table')
               }
           }
       }
	  stage ('Cleanup Artifacts') {
           steps {
               script {
                    sh "docker rmi ${IMAGE_NAME}:${IMAGE_TAG}"
                    sh "docker rmi ${IMAGE_NAME}:latest"
               }
          }
       }
	  stage("Trigger CD Pipeline") {
            steps {
                script {
                    sh "curl -v -k --user sreenija:${JENKINS_API_TOKEN} -X POST -H 'cache-control: no-cache' -H 'content-type: application/x-www-form-urlencoded' --data 'IMAGE_TAG=${IMAGE_TAG}' 'ec2-16-179-200-12.ap-southeast-2.compute.amazonaws.com:8080/job/Project/buildWithParameters?token=gitopstoken'"
                }
            }
       }
    }

  }
}

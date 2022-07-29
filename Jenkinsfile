pipeline 
{
    agent any

    environment{
	SONAR_TOKEN = "ebe715a7d0fdd4ffb924ae703699a6131009211a"
        GIT_COMMIT_SHORT = sh(
     script: "printf \$(git rev-parse --short ${GIT_COMMIT})",
     returnStdout: true)
        imageName = "myapp"
        registryCredentials = "nexusid"
        registry = "18.208.249.204:8083"
        dockerImage = 'myapp'
    }
    options {
       buildDiscarder logRotator(daysToKeepStr: '5', numToKeepStr: '7')
       }
    stages
    {
        stage('Build')
        {
            steps
            {
                 sh script: 'mvn clean package'
            }
         }
         stage('SonarQubeServer') {
		  steps {
                        sh '''
                        mvn org.sonarsource.scanner.maven:sonar-maven-plugin:3.9.1.2184:sonar\
			-Dsonar.projectKey=pankajpatre11_simple-app \
			-Dsonar.projectName=PankajPatre \
                        -Dsonar.java.coveragePlugin=jacoco \
                        -Dsonar.jacoco.reportPaths=target/jacoco.exec \
    			-Dsonar.junit.reportsPaths=target/surefire-reports
    			'''
                   }
		  }
                            
 stage('SonarQube analysis') {
            
             
            steps {
                withSonarQubeEnv('SonarQube') {
                   sh "mvn clean install"
                    sh "mvn sonar:sonar -Dsonar.login='e1ddcc1c5d09f8131f66537b11a48dd95387c806'"
                   
                }
            }
        }
        
       stage('SQuality Gate') {
          steps {
                 timeout(time: 1, unit: 'MINUTES') {
                  waitForQualityGate abortPipeline: true
               }
               }
	       post{
		       always {
			       junit allowEmptyResults: true , testResults: '**/target/surefire-reports/*.xml'
			       jacoco(execPattern:  '**/target/*.exec')
		       }
	       }
           }

        stage('Upload War To Nexus'){
            steps{ 
                script{
                def mavenPom = readMavenPom file: 'pom.xml'
                def nexusRepoName = mavenPom.version.endsWith("SNAPSHOT") ? "maven-snapshots" : "maven-releases"
                nexusArtifactUploader artifacts: 
                    [[artifactId: 'maven-project',
                      classifier: '',
                      file: "target/maven-project-${mavenPom.version}.war",
                      type: 'war'
                     ]],
                    credentialsId: 'nexusid',
                    groupId: 'com.example',
                    nexusUrl: '18.208.249.204:8081',
                    nexusVersion: 'nexus3',
                    protocol: 'http',
                    repository: nexusRepoName ,
                    version: "${mavenPom.version}"
                }
            }
        }
	    
	    
	    
        stage('Build Docker image')
        {
            steps
            {
                script{
                    dockerImage = docker.build(imageName)
                }
            }
         }
      stage('Upload Docker image into Nexus')
        {
            steps
            {
                script{
                   docker.withRegistry("docker.io", "dockerhub")
                    {
                     dockerImage.push("latest")
                     }
                }
            }
         }	    
	    
	    
stage('Deploy to K8s')
		{
			steps{
				sshagent(['k8s-jenkins'])
				{
					sh 'scp -r -o StrictHostKeyChecking=no node-deployment.yaml username@102.10.16.23:/path'
					
					script{
						try{
							sh 'ssh username@102.10.16.23 kubectl apply -f /path/node-deployment.yaml --kubeconfig=/path/kube.yaml'

							}catch(error)
							{

							}
					}
				}
			}
		}
	    
	    
    }
}






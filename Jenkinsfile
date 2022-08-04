pipeline 
{
    agent any

    environment{
	//SONAR_TOKEN = "ebe715a7d0fdd4ffb924ae703699a6131009211a"
	SONAR_TOKEN = "${SONAR_TOKEN}"
	GIT_COMMIT_SHORT = sh(
     script: "printf \$(git rev-parse --short ${GIT_COMMIT})",
     returnStdout: true)
        imageName = "pankajpatre11/myapp"
        registryCredentials = "dockerhub"
        registry = "18.208.249.204:8083"
        dockerImage = ''
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
                   sh "mvn clean install sonar:sonar"
                   // sh "mvn sonar:sonar -Dsonar.login='e1ddcc1c5d09f8131f66537b11a48dd95387c806'"
	          sh "mvn sonar:sonar"
                   
                }
            }
        }
        


        stage('Upload War To Repo'){
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
      stage('Upload Docker image into Repo')
        {
            steps
            {
                script{ 
			sh 'docker tag myapp pankajpatre11/myapp'			
			sh 'docker login -u pankajpatre11 -p Pankaj@2211' 
		        sh 'docker push pankajpatre11/myapp' 
			sh 'pwd'
                 // docker.withRegistry("https://docker.io/pankajpatre11", "dockerhub")
                  // {
	           // sh 'docker tag myapp docker.io/myapp'
                    //sh 'docker images'
                   // dockerImage.push("latest")
                  // }
                }
            }
         }	    
	    
  stage ('K8S Deploy') {
	      steps{
       
                kubernetesDeploy(
                    configs: 'springboot-lb.yaml',
                    kubeconfigId: 'K8S',
                    enableConfigSubstitution: true
                    )               
        }
      }
	  	    
    
	    
	    
    }
}





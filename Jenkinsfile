pipeline 
{
    agent any

    environment{
        GIT_COMMIT_SHORT = sh(
     script: "printf \$(git rev-parse --short ${GIT_COMMIT})",
     returnStdout: true)
        imageName = "myapp"
        registryCredentials = "nexusid"
        registry = "44.201.219.187:8083"
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
       
stage('SonarQube analysis') {
    environment {
      SCANNER_HOME = tool 'Sonar-scanner'
    }
    steps {
    withSonarQubeEnv(credentialsId: 'sonarrr', installationName: 'SonarQube') {
         sh '''$SCANNER_HOME/bin/sonar-scanner \
         -Dsonar.projectKey=pankajpatre11_simple-app \
         -Dsonar.projectName=maven-project \
         -Dsonar.sources=src/ \
         -Dsonar.java.binaries=target/classes/ \
         -Dsonar.exclusions=src/test/java/****/*.java \
         -Dsonar.java.libraries=/var/lib/jenkins/.m2/**/*.jar \
         -Dsonar.projectVersion=${BUILD_NUMBER}-${GIT_COMMIT_SHORT}'''
       }
     }
}
   stage('SQuality Gate') {
     steps {
       timeout(time: 1, unit: 'MINUTES') {
       waitForQualityGate abortPipeline: true
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
                    nexusUrl: '54.172.86.109:8081',
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
                     docker.withRegistry('http://'+registry, registryCredentials)
                    {
                     dockerImage.push("latest")
                     }
                }
            }
         }
    }
}






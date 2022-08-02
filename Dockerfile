
FROM lolhens/baseimage-openjre
ADD target/springbootApp.jar springbootApp.jar
EXPOSE 8085
ENTRYPOINT ["java", "-jar", "springbootApp.jar"]

#FROM openjdk:8
#ADD target/*.war app.war
#ENTRYPOINT ["java", "-jar","app.war"]
#EXPOSE 8085

FROM tomcat:10.1-jdk21

COPY webapp/target/*.war /usr/local/tomcat/webapps/ROOT.war

EXPOSE 8080

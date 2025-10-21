FROM maven:3.9.9-eclipse-temurin-11 AS buildstage
RUN mkdir /opt/notes
WORKDIR /opt/notes
RUN git clone https://github.com/callicoder/spring-boot-mysql-rest-api-tutorial.git /opt/notes
RUN mvn package -f /opt/notes/pom.xml -Dmaven.test.skip=true

FROM eclipse-temurin:11-jre-alpine
RUN addgroup -S notes && adduser -S notes -G notes
RUN mkdir /opt/notes
RUN chown -R notes:notes /opt/notes
USER notes:notes
WORKDIR /opt/notes
COPY --from=buildstage /opt/notes/target/easy-notes-1.0.0.jar .
COPY application.properties application.properties
ENTRYPOINT ["java","-jar","/opt/notes/easy-notes-1.0.0.jar"]

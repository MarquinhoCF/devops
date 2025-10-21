FROM openjdk:11-jdk-slim
RUN addgroup --system notes && adduser --system --ingroup notes notes
RUN apt-get update && apt-get install -y wget tar
ENV MAVEN_VERSION=3.5.4
ENV MAVEN_HOME=/usr/lib/mvn
ENV PATH=$MAVEN_HOME/bin:$PATH
RUN wget http://archive.apache.org/dist/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz && \
    tar xzvf apache-maven-$MAVEN_VERSION-bin.tar.gz && \
    rm apache-maven-$MAVEN_VERSION-bin.tar.gz && \
    mv apache-maven-$MAVEN_VERSION $MAVEN_HOME
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*
RUN mkdir /opt/notes
RUN chown -R notes:notes /opt/notes
USER notes:notes
WORKDIR /opt/notes
RUN git clone https://github.com/callicoder/spring-boot-mysql-rest-api-tutorial.git /opt/notes
RUN mvn package -f /opt/notes/pom.xml -Dmaven.test.skip=true
ARG JAR_FILE=*.jar
RUN cp ./target/easy-notes-1.0.0.jar /opt/notes/easy-note.jar
COPY application.properties application.properties
ENTRYPOINT ["java","-jar","/opt/notes/easy-note.jar"]
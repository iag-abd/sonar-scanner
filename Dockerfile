FROM java:openjdk-8-jdk

ARG SONAR_VERSION=3.0.3.778-linux
ENV SONAR_RUNNER_HOME=/opt/sonar/sonar-scanner-${SONAR_VERSION}
ENV SONAR_SCANNER_OPTS -Xmx512m

ARG TZ=Australia/Melbourne
ARG user=scanner
ARG group=scanner
ARG uid=1000
ARG gid=1000

ARG MAVEN_MAJOR=3
ARG MAVEN_VERSION=3.5.0
ENV MAVEN_REMOTE_LOCATION http://apache.uberglobalmirror.com/maven/maven-${MAVEN_MAJOR}/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz
ENV MAVEN_HOME /opt/maven/latest

ARG PROPERTIES_PREFIX=base.

COPY build.properties /${PROPERTIES_PREFIX}build.properties

RUN groupadd -g ${gid} ${group} && \
    useradd -u ${uid} -g ${gid} -m -s /bin/bash ${user} && \
    mkdir /app && \
    chown ${uid}:${gid} /app

RUN echo "basic setup" && \
    apt-get update --allow-unauthenticated -qq && \
    apt-get install --allow-unauthenticated -qq -y --no-install-recommends \
      curl \
      wget \
      git && \
  apt-get clean -y && \
  apt-get autoclean -y && \
  apt-get autoremove -y && \
  rm -rf /usr/share/locale/* && \
  rm -rf /var/cache/debconf/*-old && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /usr/share/doc/* && \
  ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

WORKDIR /usr/src

RUN echo "setups sonar" && \
  wget https://sonarsource.bintray.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-${SONAR_VERSION}.zip && \
  unzip sonar-scanner-cli-${SONAR_VERSION}.zip && \
  rm sonar-scanner-cli-${SONAR_VERSION}.zip  && \
  mkdir /opt/sonar && \
  mv sonar-scanner-${SONAR_VERSION} /opt/sonar && \
  ln -s /opt/sonar/sonar-scanner-${SONAR_VERSION} /opt/sonar/latest && \
  ln -s /opt/sonar/latest/bin/sonar-scanner /usr/bin/sonar-scanner && \
  ln -s /opt/sonar/latest/bin/sonar-scanner-debug /usr/bin/sonar-scanner-debug

ADD  $MAVEN_REMOTE_LOCATION /usr/src/maven.tar.gz

RUN echo "setup maven" && \
  mkdir -p /opt/maven  && \
  tar xvf /usr/src/maven.tar.gz -C /opt/maven  && \
  ln -s /opt/maven/apache-maven-${MAVEN_VERSION} /opt/maven/latest && \
  ln -s /opt/maven/latest/bin/mvn /usr/bin/mvn  && \
  mkdir -p /home/${user}/.m2/repository && \
  chown -R ${user}: /home/${user}/

RUN echo "hi"
  
USER 1000
WORKDIR /app

ENTRYPOINT ["/opt/sonar/latest/bin/sonar-scanner"]
CMD ["-Dsonar.projectBaseDir=/app"]

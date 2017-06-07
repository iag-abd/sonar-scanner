# sonar-scanner

## Docker Container for sonar-scanner

For config see https://docs.sonarqube.org/display/SCAN/Analyzing+with+SonarQube+Scanner

try with something like this  

```
-Dsonar.projectBaseDir=/app -Dsonar.host.url=$SONAR_HOST_URL -Dsonar.login=$SONAR_AUTH_TOKEN -Dproject.settings=~/myproject.properties -Dsonar.projectKey=myproject
```

test with cmd = --help

One could mount conf to /opt/sonar/latest/conf/sonar-runner.properties


### Building the Docker Image locally and testing

You used the --name jenkins option to give your container an easy-to-remember name;    otherwise a random hexadecimal ID would be used instead (e.g. f1d701324553). You also specified the --rm flag so the container will automatically be removed after you’ve stopped the container process. Lastly, you’ve configured your server host’s port 8080 to proxy to the container’s port 8080 using the -p flag; 8080 is the default port where the Jenkins web UI is served from.

```
docker build -t jenkins:jcasc .
docker run --name jenkins --rm -p 8080:8080 jenkins:jcasc
```

Passing in user-name and password command line
```
docker run --name jenkins --rm -p 8080:8080 --env JENKINS_ADMIN_ID=admin --env JENKINS_ADMIN_PASSWORD=password jenkins:jcasc
```

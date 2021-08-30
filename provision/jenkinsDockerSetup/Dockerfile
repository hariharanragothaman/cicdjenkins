FROM jenkins/jenkins:latest
# ALLOWS TO SKIP JENKINS SETUP WIZARD
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false
ENV CASC_JENKINS_CONFIG /var/jenkins_home/casc.yaml

# CONFIGURATION AS CODE TO INSTALL PLUGINS
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
COPY casc.yaml /var/jenkins_home/casc.yaml
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt

#ENV JENKINS_USER admin
#ENV JENKINS_PASS admin

## MAKE JENKINS RUN ALL GROOVY FILES IN init.groovy.d directory
## THIS IS USED FOR CREATING DEFAULT ADMIN USER
#COPY default-user.groovy /usr/share/jenkins/ref/init.groovy.d/
#
## VOLUME FOR JENKINS SETTINGS
#VOLUME /var/jenkins_home

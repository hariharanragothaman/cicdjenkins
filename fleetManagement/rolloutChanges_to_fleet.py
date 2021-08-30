"""
The purpose of this script is to roll a change to the entire fleet
This can be of the following 2 sides:

    a. Jenkins Docker Image
        1. Say a plugin change
        2. Jenkins Upgrade
    b. EC2 Instance Side
        1. Instance Size
        2. Networking related updates etc.


Possible Steps involved:

a. Typically involves in rebuilding the docker image
b. Rolling out the docker image to the all EC2 containers running jenkins using 'terraform'
"""

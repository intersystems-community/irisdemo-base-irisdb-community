#FROM intersystemsdc/irisdemo-base-irisdb-community:iris-community.2019.4.0.379.0
# FROM intersystemsdc/irisdemo-base-irisdb-community:iris-community.2020.2.0.196.0
# FROM intersystemsdc/irisdemo-base-irisdb-community:iris-community.2020.2.0.211.0
# FROM intersystemsdc/irisdemo-base-irisdb-community:iris-community.2020.3.0.200.0
# FROM intersystemsdc/irisdemo-base-irisdb-community:iris-community.2021.1.0.215.0
# FROM intersystemsdc/irisdemo-base-irisdb-community:iris-community.2021.2.0.637.0
# FROM intersystemsdc/irisdemo-base-irisdb-community:iris-community.2021.2.0.649.0
# FROM intersystemsdc/irisdemo-base-irisdb-community:iris-community.2021.2.0.651.0
# FROM intersystemsdc/irisdemo-base-irisdb-community:iris-community.2022.1.0.209.0
# FROM containers.intersystems.com/intersystems/iris-community:2023.2.0.202.0
# FROM containers.intersystems.com/intersystems/iris-community:2024.1
FROM containers.intersystems.com/intersystems/iris-community:2026.1

LABEL maintainer="Amir Samary <amir.samary@intersystems.com>" 

#
# We can't use ISC_CPF_MERGE_FILE because we are not using Durable %SYS on our demos
#

# Name of the project folder ex.: irisdemodb-atelier-project
ARG IRIS_PROJECT_FOLDER_NAME=irisdemodb-atelier-project

# Used to specify a folder on the container with the source code (csp pages, classes, etc.)
# to load into the CSP application.
ENV IRIS_APP_SOURCEDIR=/tmp/iris_project/

# Name of the application. This will be used to define the namespace, database and 
# name of the CSP application of this application.
ENV IRIS_APP_NAME="APP"

# IRIS Global buffers and Routine Buffers
ENV IRIS_GLOBAL_BUFFERS=128
ENV IRIS_ROUTINE_BUFFERS=64

# Changing to root so we can add the files and then use the chown command to 
# change the permissions to irisowner/irisowner 
USER root

# Adding source code that will be loaded by the installer
# The ADD command ignores the current USER and always add as root. 
# That is why were are doing the chown
ADD ./${IRIS_PROJECT_FOLDER_NAME}/ $IRIS_APP_SOURCEDIR
RUN chown -R irisowner:irisowner $IRIS_APP_SOURCEDIR

# Adding scripts to load base image source and child image source
ADD ./imageBuildingUtils.sh /demo/imageBuildingUtils.sh
ADD ./irisdemobaseinstaller.sh /demo/irisdemobaseinstaller.sh
ADD ./irisdemoinstaller.sh /demo/irisdemoinstaller.sh
RUN chown -R irisowner:irisowner /demo

# Now we change back to irisowner so that the RUN command will be run with this user
USER irisowner 

# This must be called only on this base images. Child images must call irisdemoinstaller.sh instead.
RUN /demo/irisdemobaseinstaller.sh

HEALTHCHECK --interval=5s CMD /irisHealth.sh || exit 1
#FROM intersystemsdc/irisdemo-base-irisdb-community:iris-community.2019.4.0.379.0
FROM intersystemsdc/irisdemo-base-irisdb-community:iris-community.2020.2.0.196.0
FROM intersystemsdc/irisdemo-base-irisdb-community:iris-community.2020.2.0.211.0

LABEL maintainer="Amir Samary <amir.samary@intersystems.com>" 

#
# We can't use ISC_CPF_MERGE_FILE because we are not using Durable %SYS on our demos
#

# Configuring Alternate Journal Directory for IRIS for Health, setting correct permissions on
# modified iris.cpf and newly created journal directory.
# This must be done as root so that "chown" is permitted
USER root
RUN sed -i "s/AlternateDirectory=.*/AlternateDirectory=\/usr\/irissys\/mgr\/journal2\//" /usr/irissys/iris.cpf && \
    chown irisowner:irisuser /usr/irissys/iris.cpf && \
    mkdir /usr/irissys/mgr/journal2/ && \
    chown irisowner:irisuser /usr/irissys/mgr/journal2 && \
    chmod g+w /usr/irissys/mgr/journal2

# Going back to irisowner now
USER irisowner

# Name of the project folder ex.: irisdemodb-atelier-project
ARG IRIS_PROJECT_FOLDER_NAME=irisdemodb-atelier-project

# Used to specify a folder on the container with the source code (csp pages, classes, etc.)
# to load into the CSP application.
ENV IRIS_APP_SOURCEDIR=/tmp/iris_project/

# Name of the application. This will be used to define the namespace, database and 
# name of the CSP application of this application.
ENV IRIS_APP_NAME="APP"

# This is an image for using with demos. I don't care about protecting the password. I just
# want all instances to have the same password.
RUN echo "sys" >> /tmp/pwd.isc && /usr/irissys/dev/Container/changePassword.sh /tmp/pwd.isc

# IRIS Global buffers and Routine Buffers
ENV IRIS_GLOBAL_BUFFERS=128
ENV IRIS_ROUTINE_BUFFERS=64

# Adding source code that will be loaded by the installer
# The ADD command ignores the current USER and always add as root. 
# That is why were are doing the chown
ADD --chown=irisowner:irisuser ./${IRIS_PROJECT_FOLDER_NAME}/ $IRIS_APP_SOURCEDIR

# Adding scripts to load base image source and child image source
ADD ./imageBuildingUtils.sh $ISC_PACKAGE_INSTALLDIR/demo/imageBuildingUtils.sh
ADD ./irisdemobaseinstaller.sh $ISC_PACKAGE_INSTALLDIR/demo/irisdemobaseinstaller.sh
ADD ./irisdemoinstaller.sh $ISC_PACKAGE_INSTALLDIR/demo/irisdemoinstaller.sh

# This must be called only on this base images. Child images must call irisdemoinstaller.sh instead.
RUN $ISC_PACKAGE_INSTALLDIR/demo/irisdemobaseinstaller.sh

HEALTHCHECK --interval=5s CMD /irisHealth.sh || exit 1
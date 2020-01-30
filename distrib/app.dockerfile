# Will dockerize a node js application
FROM ubuntu:18.04
ARG VERSION=0.0.0-devlocal
ARG deb_file
# Any other arguments from the dockerization

# Environment variables to be set for the application
ENV TZ=Zuru

# Uploading the Ubuntu base image with latest liraryies and downloading curl and timezone data modules.
RUN apt-get update; \
    apt-get install -y \
        curl \
        tzdata;

# Download the necessary softwares and liraries needed for running the application

RUN curl -sL http://deb.nodesource.com/setup_10.x | bash -; \
    apt-get install -y \
        locales \
        locales-all \
        nodejs;

# Installing the application debian package to containerize
RUN ls *.deb; dpkg -i *.deb && rm -rf *.deb;

# Configuring the container timezone
RUN rm /etc/localtime && ln -snf /usr/share/zoneinfo/${TZ} /etc/localtime; \
    dpkg-reconfigure -f noninteractive tzdata;

# Purge the container and clean dangling library references
RUN apt-get autoremove --purge -y; apt-get clean \
    rm -rf /var/lib/apt/lists/*

# Setting environment locales
ENV LC_ALL en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US.UTF-8

WORKDIR /usr/lib/app/${VERSION}

RUN npm install

# This is a command from installing debian, which we have to configure
CMD ["start-app"]





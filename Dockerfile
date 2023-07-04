###
### ASXTrade Viewer Image
###

# Use latest Ubuntu LTS image with Python 3.9 installed
FROM ubuntu:latest as base_os

# Update Ubuntu and add locales
RUN apt-get update && apt-get install -y locales && rm -rf /var/lib/apt/lists/* \
	&& localedef -i en_US -c -f UTF-8 -A /usr/share/locale/locale.alias en_US.UTF-8
ENV LANG en_US.utf8

# Install Python 3.9 and upgrade pip
RUN apt-get update && apt-get install -y python3.9 python3-pip python3.9-dev \
    && cd /usr/local/bin \
    && ln -s /usr/bin/python3.9 python \
    && pip3 install --upgrade pip

# Set the working directory to /src
WORKDIR /src

# Copy the current directory contents into the container at /src/asxtrade
COPY . /src/asxtrade

# Copy requirements.txt into the container at /src/asxtrade
COPY ../requirements.txt /src/asxtrade

# Install any needed packages specified in requirements.txt
RUN pip3 install --trusted-host pypi.python.org -r requirements.txt

# Use mongodb image
FROM mongo:latest as mongo_db

# Create a wrapper script to start /src/asxtrade/asxtrade.py from /docker-entrypoint-initdb.d/
RUN echo "#!/bin/bash" > /docker-entrypoint-initdb.d/asxtrade.sh
RUN echo "python3 /src/asxtrade/asxtrade.py" >> /docker-entrypoint-initdb.d/asxtrade.sh
RUN chmod +x /docker-entrypoint-initdb.d/asxtrade.sh

# Add the default entrypoint script from the mongodb image to /docker-entrypoint-initdb.d/
ADD https://raw.githubusercontent.com/docker-library/mongo/master/docker-entrypoint.sh /docker-entrypoint-initdb.d/

# Expose webapp port 80
EXPOSE 80

# Expose mongo port 27017
EXPOSE 27017

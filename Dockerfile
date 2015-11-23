FROM ubuntu:latest

# SET ENV VARIABLES FROM BUILD ARGS
ARG slackWebhookUrl
ARG gcloudServiceAccountId
ARG gcloudProjectName
ARG gcloudModuleName
ARG googleAppenginePath
ARG apiBranch
#USER $slackWebhookUrl
RUN echo $slackWebhookUrl

ENV SLACKWEBHOOKURL $slackWebhookUrl
ENV GCLOUDSERVICEACCOUNTID $gcloudServiceAccountId
ENV GCLOUDPROJECTNAME $gcloudProjectName 
ENV GCLOUDMODULENAME $gcloudModuleName 
ENV GOOGLEAPPENGINEPATH $googleAppenginePath 
ENV APIBRANCH $apiBranch

# INSTALL THE BASICS
RUN apt-get update
RUN apt-get install --no-install-recommends -y -q curl libyaml-dev libreadline6-dev libncurses5-dev libssl-dev libgdbm-dev libqdbm-dev libffi-dev libz-dev libgmp-dev build-essential autoconf ca-certificates systemtap sqlite3 libsqlite3-dev zip unzip sudo

RUN apt-get install -y software-properties-common

RUN \
  echo oracle-java8-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections && \
  add-apt-repository -y ppa:webupd8team/java && \
  apt-get update && \
  apt-get install -y oracle-java8-installer && \
  rm -rf /var/lib/apt/lists/* && \
  rm -rf /var/cache/oracle-jdk8-installer

# UPDGRADE REPOS
RUN echo deb http://archive.ubuntu.com/ubuntu precise universe multiverse >> /etc/apt/sources.list; apt-get update; apt-get -y install autoconf automake git wget; apt-get clean

# get watcher repo
# RUN git clone git@github.com:nelsoncash/gconsole-watcher.git
ADD ./gconsole-watcher /gconsole-watcher

ENV WATCHER /gconsole-watcher

# Install Python
RUN apt-get install -y python2.7 python2.7-dev python-setuptools python-lxml

# Do following install tasks in /tmp
WORKDIR /tmp

# Install latest pip
RUN wget https://bootstrap.pypa.io/get-pip.py
RUN python2.7 get-pip.py

WORKDIR /root

# INSTALL GOOGLE CLOUD SDK
RUN echo $GOOGLEAPPENGINEPATH
RUN ls -a
RUN pwd
RUN mkdir $GOOGLEAPPENGINEPATH
RUN cd ~/$GOOGLEAPPENGINEPATH && wget https://storage.googleapis.com/appengine-sdks/featured/google_appengine_1.9.28.zip -O google_appengine.zip
RUN cd $GOOGLEAPPENGINEPATH && unzip -qq google_appengine.zip
RUN curl https://dl.google.com/dl/cloudsdk/release/google-cloud-sdk.tar.gz > /tmp/google-cloud-sdk.tar.gz
RUN sudo mkdir -p /usr/local/gcloud
RUN tar -C /usr/local/gcloud -xvf /tmp/google-cloud-sdk.tar.gz
RUN /usr/local/gcloud/google-cloud-sdk/install.sh
ENV PATH $PATH:/usr/local/gcloud/google-cloud-sdk/bin

# INSTAL API TEST DEPS
RUN pip install unittest2
RUN pip install webtest
RUN pip install gitpython


# CLONE API REPO

COPY . /tmp
WORKDIR /tmp
RUN gcloud auth activate-service-account $GCLOUDSERVICEACCOUNTID --key-file /tmp/credentials/gcloud.json
RUN gcloud auth list
RUN gcloud config set account $GCLOUDSERVICEACCOUNTID
RUN gcloud config set project $GCLOUDPROJECTNAME
RUN gcloud source repos clone $GCLOUDMODULENAME
RUN chmod -R 777 $GCLOUDMODULENAME/

# Set path to SPACKLE
ENV PROJECT ~/../tmp/$GCLOUDMODULENAME

# Add files for tests

ADD scripts/python-tests.sh /usr/bin/python-tests
ADD scripts/run-watcher.sh /usr/bin/run-watcher
ADD scripts/run-watchers.sh /usr/bin/run-watchers
ADD scripts/run-all-tests.sh /usr/bin/run-all-tests
RUN chmod +x /usr/bin/python-tests
RUN chmod +x /usr/bin/run-watcher
RUN chmod +x /usr/bin/run-watchers
RUN chmod +x /usr/bin/run-all-tests

ENTRYPOINT ["/bin/bash"]
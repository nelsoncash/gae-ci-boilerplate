## Google App Engine CI Server Scaffold

### Running the CI server

Running the ci server requires two config files. One is the env.json file and the other is the gcloud.json file. To generate the gcloud.json file, check out (this article)[https://console.developers.google.com/projectselector/apis/credentials?_ga=1.219282972.407585717.1422033448]. This needs to go into the credentials.

The docker image requires the --build-arg commands for all of the fields in the env.json file. An example command would be ```docker build -t <image-name> --build-arg slackWebhookUrl=https://cool.biz --build-arg gcloudServiceAccountId=ACCOUNT --build-arg gcloudProjectName=PROJECTNAME --build-arg gcloudModuleName=default --build-arg googleAppenginePath=local --build-arg apiBranch=master```
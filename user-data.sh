#!/bin/bash -xe
yum -y update
yum -y upgrade

## Installing all the required software
yum -y install python3 git jq httpd wget

## Creating a health check page
cd /var/www/html
echo "<html><head><title>test</title></head><body>test</body></html>" > /var/www/html/healthcheck.html

## Starting the apache
systemctl enable httpd
systemctl start httpd

## configuring the environment
cd /home/ec2-user

rm -fr /usr/local/aws
rm -fr /usr/local/bin/aws

curl "https://s3.amazonaws.com/aws-cli/awscli-bundle.zip" -o "awscli-bundle.zip"

unzip awscli-bundle.zip

./awscli-bundle/install -b ~/bin/aws

ln -fs /usr/bin/pip-3.7 /usr/bin/pip
ln -fs /usr/bin/pip-3 /usr/bin/pip
ln -fs /usr/bin/pip3 /usr/bin/pip

aws configure set region `curl --silent http://169.254.169.254/latest/dynamic/instance-identity/document | jq -r .region`

## Installing webapp flask app
cd /home/ec2-user
git clone https://github.com/paachary/flask-app.git

chown ec2-user:root -R flask-app/

cd /home/ec2-user/flask-app

pip install install virtualenv
virtualenv myenv
. myenv/bin/activate
pip install -r requirements.txt

## Setting up webapp db connection details

. myenv/bin/activate
export POSTGRES_USER=$(aws ssm get-parameters --region ${AWS::Region} --names PostgresUser --query Parameters[0].Value | tr -d '"')
export POSTGRES_PW=$(aws secretsmanager get-secret-value --secret-id PostgresPwd | jq -r '.SecretString' | tr -d '"')
export POSTGRES_DB=$(aws ssm get-parameters --region ${AWS::Region} --names PostgresDb --query Parameters[0].Value | tr -d '"')                    
export FLASK_APP=$(aws ssm get-parameters --region ${AWS::Region} --names FlaskApp --query Parameters[0].Value | tr -d '"')

## Initializing the flask database

flask db init
flask db migrate -m "installing the db code"
flask db upgrade

## Launching the application and making it available on port 8000.
gunicorn -b :8000 --access-logfile - --error-logfile - microblog:app --daemon
exit 0
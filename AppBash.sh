#!/bin/bash

apt-get update

git clone https://github.com/GuyR53/bootcamp-app.git

cd /bootcamp-app 

curl -sL https://deb.nodesource.com/setup_14.x | sudo bash - 

apt install nodejs

npm install pm2@latest -g

pm2 startup

cat <<EOF >.env
# Host configuration
PORT=8080
HOST=0.0.0.0

# Postgres configuration
PGHOST=10.0.1.4
PGUSERNAME=postgres
PGDATABASE=postgres
PGPASSWORD=p@ssw0rd42
PGPORT=5432

HOST_URL=http://20.228.168.56:8080
COOKIE_ENCRYPT_PWD=superAwesomePasswordStringThatIsAtLeast32CharactersLong!
NODE_ENV=development

# Okta configuration
OKTA_ORG_URL=https://dev-14480648.okta.com
OKTA_CLIENT_ID=0oa42lil8krSmSfF25d7
OKTA_CLIENT_SECRET=SpLrCPEcnXt68xMLS7V8t7C_XASwKYGw6itGKlc_

EOF

npm install

npm run initdb 

pm2 start src/index.js 

pm2 save 

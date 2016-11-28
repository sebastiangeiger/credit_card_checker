git pull
git remote add flynn https://user:$FLYNN_KEY@$FLYNN_GIT_URL
GIT_SSL_NO_VERIFY=true git push --force flynn master

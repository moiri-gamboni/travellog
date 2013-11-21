#!/bin/bash
rm apiclient
rm httplib2
rm oauth2client
rm uritemplate
rm dateutil
rm six.py

ln -s /Library/Python/2.7/site-packages/apiclient
ln -s /Library/Python/2.7/site-packages/httplib2
ln -s /Library/Python/2.7/site-packages/oauth2client
ln -s /Library/Python/2.7/site-packages/uritemplate
ln -s /Library/Python/2.7/site-packages/dateutil
ln -s /Library/Python/2.7/site-packages/six.py

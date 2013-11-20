#!/bin/bash
rm apiclient
rm httplib2
rm oauth2client
rm uritemplate

ln -s /Library/Python/2.7/site-packages/apiclient
ln -s /Library/Python/2.7/site-packages/httplib2
ln -s /Library/Python/2.7/site-packages/oauth2client
ln -s /Library/Python/2.7/site-packages/uritemplate

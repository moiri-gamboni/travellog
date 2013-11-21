#!/bin/bash
rm apiclient
rm httplib2
rm oauth2client
rm uritemplate
rm dateutil
rm six.py

ln -s /usr/local/lib/python2.7/dist-packages/apiclient
ln -s /usr/local/lib/python2.7/dist-packages/httplib2
ln -s /usr/local/lib/python2.7/dist-packages/oauth2client
ln -s /usr/local/lib/python2.7/dist-packages/uritemplate
ln -s /usr/local/lib/python2.7/dist-packages/dateutil
ln -s /usr/lib/python2.7/site-packages/six.py

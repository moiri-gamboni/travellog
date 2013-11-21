#!/bin/bash
rm apiclient
rm httplib2
rm oauth2client

ln -s /usr/local/lib/python2.7/dist-packages/apiclient
ln -s /usr/local/lib/python2.7/dist-packages/httplib2
ln -s /usr/local/lib/python2.7/dist-packages/oauth2client

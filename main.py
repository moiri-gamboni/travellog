import os
import sys
import inspect
import webapp2

indexPath = os.path.join(os.path.dirname(__file__), 'index.html')

# setting up subfolder
handlers = os.path.realpath(os.path.abspath(os.path.join\
  (os.path.split(inspect.getfile( inspect.currentframe() ))[0],"lib")))
if handlers not in sys.path:
  sys.path.insert(0, handlers)

from data_api import LogHandler, LogIdHandler, DriveHandler, DriveSyncHandler
import gdrive

application = webapp2.WSGIApplication([
  ('/logs', LogHandler), (r"/log/(\w+)/edit", LogIdHandler),
  ("/drive", DriveHandler), ("/drive/sync", DriveSyncHandler)
], debug=True)

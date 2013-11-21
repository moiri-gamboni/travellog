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

from data_api import LogHandler, DriveHandler
import gdrive

class IndexPage(webapp2.RequestHandler):
  def get(self):
    self.response.out.write(template.render(indexPath, None))

application = webapp2.WSGIApplication([
  ('/logs', LogHandler),
  ("/drive", DriveHandler)
], debug=True)

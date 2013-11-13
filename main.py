import os
import sys
import inspect
import webapp2

from google.appengine.ext.webapp import template

indexPath = os.path.join(os.path.dirname(__file__), 'index.html')

# setting up subfolder
handlers = os.path.realpath(os.path.abspath(os.path.join\
  (os.path.split(inspect.getfile( inspect.currentframe() ))[0],"handlers")))
if handlers not in sys.path:
  sys.path.insert(0, handlers)

from data_api import DataHandler, CreateCountry
import gdrive_sync


class IndexPage(webapp2.RequestHandler):
  def get(self):
    self.response.out.write(template.render(indexPath, None))

application = webapp2.WSGIApplication([
  ('/', IndexPage), ('/data', DataHandler), ('/country', CreateCountry)
], debug=True)

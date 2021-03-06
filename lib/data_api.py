import webapp2
import json
import models

from google.appengine.ext import ndb
import gdrive
import dateutil.parser

class LogHandler(webapp2.RequestHandler):
  post_params = ["gdriveId", "lat", "lng", "country"]

  def get(self):
    # return all logs if id is not in the argument
    if "id" not in self.request.arguments():
      self.response.headers['Content-Type'] = "application/json"
      self.response.write(json.dumps({"status": 200, "logs":\
        models.get_all_logs()}))
    else:
      try:
        # try fetch the requested id by key
        self.response.headers['Content-Type'] = "application/json"
        self.response.write(json.dumps({"status": 200, "log":\
          models.get_log_by_key(self.request.get("id"))}))
      except:
        self.response.headers['Content-Type'] = "application/json"
        self.response.write(json.dumps({"status": 404, "error":\
          "log with id %s not found" %\
          (self.request.get("id"))}))
        return

  def post(self):
    self.params = json.loads(self.request.body)
    for param in self.post_params:
      if param not in self.params.keys():
        self.response.headers['Content-Type'] = "application/json"
        self.response.write(json.dumps({"status": 400, "error":\
            "You must have a %s parameter" % param}))
        return

    # create a country if it is mising
    if not models.get_country_object_by_key(self.params["country"]):
      if ("countryLat" not in self.params) or ("countryLng" not in self.params):
          self.response.write(json.dumps({"status": 400,\
            "error": "You must pass countryLat and countryLng for new countries"}))
          return
      else:
        models.create_country(self.params["country"], self.params["countryLat"], self.params["countryLng"])

    # construct the child
    log = models.create_log(self.params["gdriveId"], self.params["lat"], self.params["lng"], self.params["country"])

    # grab either a profileId or profileName depending on what was passed in
    if "profileId" in self.params.keys():
      log.profileId = self.params["profileId"]
    elif "profileName" in self.params.keys():
      log.profileId = self.params["profileName"]
    else:
      self.response.headers['Content-Type'] = "application/json"
      self.response.write(json.dumps({"status": 400, "error":\
          "You must have either a profileId or profileName parameter"}))
      return
    try:
      # process the log, fetching its html content
      gdrive.process_log(log)
    except:
      self.response.headers['Content-Type'] = "application/json"
      self.response.write(json.dumps({"status": 400, "error":\
          "Could not process drive document with id %s," +
          " perhaps it is not a Google Drive Document?" +
          " (We can't accept Microsoft Office Documents)" %\
          self.params["gdriveId"]}))
      return
    log.put()
    self.response.headers['Content-Type'] = "application/json"
    self.response.write(json.dumps({"status": 200}))

class CountryHandler(webapp2.RequestHandler):

  def get(self):
    # return all countries
    if "id" not in self.request.arguments():
      self.response.headers['Content-Type'] = "application/json"
      self.response.write(json.dumps({"status": 200, "countries":\
        models.get_all_countries()}))

class DriveHandler(webapp2.RequestHandler):
  def get(self):
    self.response.headers['Content-Type'] = "application/json"
    # preferably, get the ids of the articles for a specific country
    if "id" in self.request.arguments():
      try:
        document = drive.get_file()
        self.response.write(json.dumps({"status": 200, "gdrive": gdrive.all_files()}))
      except:
        self.response.write(json.dumps({"status": 404, "error":\
          "drive document with id %s not found" % self.request.get("id")}))
        return
    # if there is no param for id, return all drive documents
    else:
      self.response.headers['Content-Type'] = "application/json"
      self.response.write(json.dumps({"status": 200, "gdrive": gdrive.all_files()}))

class DriveSyncHandler(webapp2.RequestHandler):
  def get(self):
    # sync the documents
    updated = []
    old_documents = models.get_all_logs_objects()
    new_documents = gdrive.retrieve_all_changes()
    for document in new_documents:
      # make sure the file hasn't been deleted and is in our database
      if "file" in document.keys() and document["file"]["id"] in old_documents:
        document = document[u'file']
        updatedTime = dateutil.parser.parse(document["modifiedDate"][:-1])
        # invalidate the db record if it exists already and is newer
        old_document = old_documents[document["id"]]
        if old_document.modifiedDate < updatedTime:
          old_document.modifiedDate = updatedTime
          old_document.title = document["title"]
          old_document.body = gdrive.file_to_html(document)
          old_document.put()
          updated.append(document["id"])
    self.response.write(json.dumps({"status": 200, "updated": updated}))
    return

class LogIdHandler(webapp2.RequestHandler):
  def get(self, logId):
    self.response.write(json.dumps({"status": 200, "log":\
      models.get_log_by_key(logId)}))

  def post(self, logId):
    self.params = json.loads(self.request.body)
    log = models.get_log_object_by_key(logId)

    if not log:
      self.response.write(json.dumps({"status": 404, "error": "Log with id %s not found" % logId}))

    for param in self.params:
      if param in models.logFields:
        setattr(log, param, self.params[param])

    if "country" in self.params and not models.get_country_object_by_key(self.params["country"]):
      if ("countryLat" not in self.params) or ("countryLng" not in self.params):
          self.response.write(json.dumps({"status": 400,\
            "error": "You must pass countryLat and countryLng for new countries"}))
          return
      else:
        models.create_country(self.params["country"], self.params["countryLat"], self.params["countryLng"])

    log.put()
    self.response.write(json.dumps({"status": 200, "log":\
      models.get_log_by_key(logId)}))


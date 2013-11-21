import webapp2
import json
import models

from google.appengine.ext import ndb
import gdrive
import dateutil.parser

class LogHandler(webapp2.RequestHandler):
  post_params = ["gdriveId", "lat", "lng"]

  def get(self):
    # return all logs if id is not in the argument
    if "id" not in self.request.arguments():
      self.response.headers['Content-Type'] = "application/json"
      self.response.write(json.dumps({"status": 200, "logs":\
        models.get_all_logs()}))
    else:
      # try:
        # try fetch the requested id by key
      self.response.headers['Content-Type'] = "application/json"
      self.response.write(json.dumps({"status": 200, "log":\
        models.get_log_by_key(self.request.get("id"))}))
      # except:
      #   self.response.headers['Content-Type'] = "application/json"
      #   self.response.write(json.dumps({"status": 404, "error":\
      #     "log with id %s not found" %\
      #     (self.request.get("id"))}))
      #   return

  def post(self):
    self.parseJson()
    for param in self.post_params:
      if param not in self.params.keys():
        self.response.headers['Content-Type'] = "application/json"
        self.response.write(json.dumps({"status": 400, "error":\
            "You must have a %s parameter" % param}))
        return
    # construct the child
    log = models.create_log(self.params["gdriveId"], self.params["lat"], self.params["lng"])
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
          "Could not process drive document with id %s" %\
          self.params["gdriveId"]}))
      return
    log.put()
    self.response.headers['Content-Type'] = "application/json"
    self.response.write(json.dumps({"status": 200}))

  def parseJson(self):
    self.params = json.loads(self.request.body)

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


import requests
import json
import random

data = {
  "profileId": "107803280249128570180"
};

lastLat = 0
lastLng = 0

def randLat(seed):
  return seed + random.randint(-1, 1)

def randLng(seed):
  return seed + random.randint(-1, 1)

data["country"] = "USA"
for ids in ["1bMUS1TNaLZtJ8khEpa1RdutsLTJoCh6p5aGUlwwzLRM",
    "1BhomhZkJthbQtO0aMUEVIF43jRf3OVo51jSqijjWAXs"]:
  data["gdriveId"] = ids
  data["lat"] = randLat(40)
  data["lng"] = randLng(-100)
  data["countryLat"] = 40
  data["countryLng"] = -100
  r = requests.post("http://localhost:8080/logs", data=json.dumps(data))
  print r.text


data["country"] = "China"
for ids in ["1nLlul_8Oh2RmwvkPEIS1_flDkIAhk9pT_SQqKlLNh_8",
  "1mHCvrR1e4zxOIcUFLHatGRCMTOBnnzcr3VZkKOSgSwM",
  "1ExA0H6Kx-cL-g2j1TyuhC3xwBpagGnIgdsY0xfV31gw"]:
  data["gdriveId"] = ids
  data["lat"] = randLat(35)
  data["lng"] = randLng(103)
  data["countryLat"] = 35
  data["countryLng"] = 103
  r = requests.post("http://localhost:8080/logs", data=json.dumps(data))
  print r.text

data["country"] = "UAE"
for ids in ["1XPUPhLyL3akl7tQ0ODHFxo2kUmd4U05Q9ROvGY3qmow"]:
  data["gdriveId"] = ids
  data["lat"] = randLat(23)
  data["lng"] = randLng(54)
  data["countryLat"] = 23
  data["countryLng"] = 54
  r = requests.post("http://localhost:8080/logs", data=json.dumps(data))
  print r.text

data["country"] = "Oman"
for ids in ["1_1vivrYBkxBf2DAVI5dkI3A-uCnDNZFHWq3_cQTxyOs",
  "1sJn_dPHmOIXsuahOFP6mGGJR071dRNC7ZOTvPwe-Gu4",
  "1nuIyAbdjZ08yget-ykEdLuWndjWPP6CA6-_ougJl8VA",
  "1Gq9iT-yb6GFJN7BrBapZr7Ep0ZL2SdP8wtxJm_GRmm0",
  "1cvZwDh0nIujTSNroTXofmR0oce3vK2Z9MnBQxELivWs",
  "1Ja-j3r1Yg9G5zTXCGzzNuQNVYeo4jBL3NKipTjOZWI8"]:
  data["gdriveId"] = ids
  data["lat"] = randLat(20)
  data["lng"] = randLng(54)
  data["countryLat"] = 20
  data["countryLng"] = 54
  r = requests.post("http://localhost:8080/logs", data=json.dumps(data))
  print r.text

data["country"] = "New Zealand"
for ids in ["1mSUcNM7gInwrN1IwvLSJyOb3WQuRHrSTV6nLj34GUkI",
          "1vuOYKLnNY8sQTk0AcedgNtH4r_kGeMTRLBI05_yQzT0",
          "141bF1qpAsfijCn0pL7XUFcgip3y8RGMHlre-prO34WI"]:
  data["gdriveId"] = ids
  data["lat"] = randLat(-42)
  data["lng"] = randLng(174)
  data["countryLat"] = -42
  data["countryLng"] = 174
  r = requests.post("http://localhost:8080/logs", data=json.dumps(data))
  print r.text


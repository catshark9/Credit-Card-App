import csv
import json
import pandas as pd
import sys, getopt, pprint
from pymongo import MongoClient
import os.path
import re

MONGODB_HOST = 'localhost'
MONGODB_PORT = 27017
DBS_NAME = 'CreditCards'
COLLECTION_NAME = 'CurrentValue'
FIELDS = {'CardName': True, 'Program': True, 'Issuer': True, 'Link': True, 'Cash': True, 'Points': True, 'Nights': True, 'Credit': True, 'Fee': True, 'img': True, 'Spend': True, 'Rate': True, 'Value': True, '_id': False}
connection = MongoClient(MONGODB_HOST)
collection = connection[DBS_NAME][COLLECTION_NAME]

if(collection.find().count() > 0):
    collection.drop()

csvfile = open(os.path.join(os.path.dirname(__file__),"scraper/data/CurrentValues.csv"))
reader = csv.DictReader( csvfile )

header= ["CardName", "Program", "Issuer",	 "Link",	"IntroOffer",	"Cash",	"Points",	"Nights",	"Credit",	"FeeWaived1stYr", "Fee", "Spend",	"img",	"Rate",	 "Value"]
for each in reader:
    row={}
    for field in header:
        if field in ['Value', 'Cash', 'Points', 'Nights']:
            each[field] = re.sub("\.00E\+05", "00000", each[field])
            row[field]=int(each[field])
        else:
            row[field]=each[field]
    collection.insert_one(row)


COLLECTION_NAME = 'Rates'
collection = connection[DBS_NAME][COLLECTION_NAME]

if(collection.find().count() > 0):
    collection.drop()

csvfile = open(os.path.join(os.path.dirname(__file__),"scraper/data/rates.csv"))
reader = csv.DictReader( csvfile )

header= ["Program", "This_Month", "Last_Month", "Notes"]
for each in reader:
    row={}
    for field in header:
        row[field]=each[field]
    collection.insert_one(row)

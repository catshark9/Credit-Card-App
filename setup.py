import csv
import json
import pandas as pd
import sys, getopt, pprint
from pymongo import MongoClient
import os.path

MONGODB_HOST = 'localhost'
MONGODB_PORT = 27017
DBS_NAME = 'CreditCards'
COLLECTION_NAME = 'CurrentValue'
FIELDS = {'CardName': True, 'Program': True, 'Issuer': True, 'Link': True, 'Cash': True, 'Points': True, 'Nights': True, 'Credit': True, 'Fee': True, 'img': True, 'Spend': True, 'Rate': True, 'Value': True, '_id': False}
connection = MongoClient(MONGODB_HOST)
collection = connection[DBS_NAME][COLLECTION_NAME]

if(collection.find().count() > 0):
    collection.drop()

csvfile = open(os.path.join(os.path.dirname(__file__),"data/CurrentValues.csv"))
reader = csv.DictReader( csvfile )

header= ["CardName", "Program", "Issuer",	 "Link",	"IntroOffer",	"Cash",	"Points",	"Nights",	"Credit",	"FeeWaived1stYr", "Fee", "Spend",	"img",	"Rate",	"MaxValue",	"isMax",	"newMax",	"Value"]
for each in reader:
    row={}
    for field in header:
        if field=='Value':
            row[field]=int(each[field])
        else:
            row[field]=each[field]
    collection.insert_one(row)
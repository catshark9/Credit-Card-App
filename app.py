from flask import Flask, jsonify, render_template, redirect
from pymongo import MongoClient
import pymongo
import json
from bson import json_util
from bson.json_util import dumps
from bson.objectid import ObjectId # For ObjectId to work
from flask import request

MONGODB_HOST = 'localhost'
MONGODB_PORT = 27017
DBS_NAME = 'CreditCards'
COLLECTION_NAME = 'CurrentValue'
FIELDS = {'CardName': True, 'Program': True, 'Issuer': True, 'Link': True, 'Cash': True, 'Points': True, 'Nights': True, 'Credit': True, 'Fee': True, 'img': True, 'Spend': True, 'Rate': True, 'Value': True, '_id': False}
connection = MongoClient(MONGODB_HOST)
collection = connection[DBS_NAME][COLLECTION_NAME]

programs = collection.distinct("Program")
issuers = collection.distinct("Issuer")


app = Flask(__name__)
title = "Credit Cards"
heading = "Credit Cards"

def redirect_url():
    return request.args.get('next') or \
           request.referrer or \
           url_for('index')

@app.route("/")
@app.route("/list")
def list():
	#Display all credit cards
	CurrentValue = collection.find({"Value":{"$ne":'NA'}}).sort('Value', pymongo.DESCENDING)
	return(render_template('index.html',cards=CurrentValue, programs=programs, issuers=issuers, t=title, h=heading))

@app.route("/view")
def view():
	#to edit informaion for cards
	CurrentValue = collection.find().sort('Value', pymongo.DESCENDING)
	return(render_template('view.html',cards=CurrentValue, t=title, h=heading))

@app.route("/delete")
def delete():
	#to edit informaion for cards
	key=request.values.get("_id")
	collection.remove({"_id":ObjectId(key)})
	return(redirect("/view"))

@app.route("/update")
def update():
	id=request.values.get("_id")
	CurrentValue = collection.find({"_id":ObjectId(id)})
	return render_template('update.html',cards=CurrentValue,h=heading,t=title)

@app.route("/CurrentCards/CurrentValue", methods=['GET'])
def CurrentCards_CurrentValue():
    CurrentValue = collection.find({"Value":{"$ne":'NA'}}).sort('Value', pymongo.DESCENDING)
    json_CurrentValue = []
    for cv in CurrentValue:
        json_CurrentValue.append(cv)
    json_CurrentValue = json.dumps(json_CurrentValue, default=json_util.default)
    return(jsonify(json_CurrentValue))


@app.route("/filter", methods=['POST'])
def filter():
	#filtering
	type=request.values.get("type")
	program=request.values.get("programs")
	issuer=request.values.get("issuers")
	if (type == 'All') & (program == 'All') & (issuer == 'All'):
		CurrentValue = collection.find({ "Value":{"$ne":'NA'}}).sort('Value', pymongo.DESCENDING)
	elif (type == 'All') & (program == 'All') & (issuer != 'All'):
		CurrentValue = collection.find({"Issuer":issuer, "Value":{"$ne":'NA'}}).sort('Value', pymongo.DESCENDING)
	elif (type == 'All') & (program != 'All') & (issuer == 'All'):
		CurrentValue = collection.find({"Program":program, "Value":{"$ne":'NA'}}).sort('Value', pymongo.DESCENDING)
	elif (type == 'All') & (program != 'All') & (issuer != 'All'):
		CurrentValue = collection.find({"Issuer":issuer, "Program":program, "Value":{"$ne":'NA'}}).sort('Value', pymongo.DESCENDING)
	elif (type != 'All') & (program == 'All') & (issuer == 'All'):
		CurrentValue = collection.find({type:{"$gt":0}, "Value":{"$ne":'NA'}}).sort('Value', pymongo.DESCENDING)
	elif (type != 'All') & (program == 'All') & (issuer != 'All'):
		CurrentValue = collection.find({type:{"$gt":0}, "Issuer":issuer, "Value":{"$ne":'NA'}}).sort('Value', pymongo.DESCENDING)
	elif (type != 'All') & (program != 'All') & (issuer == 'All'):
		CurrentValue = collection.find({type:{"$gt":0}, "Program":program, "Value":{"$ne":'NA'}}).sort('Value', pymongo.DESCENDING)
	else:
		CurrentValue = collection.find({type:{"$gt":0}, "Program":program, "Issuer":issuer, "Value":{"$ne":'NA'}}).sort('Value', pymongo.DESCENDING)
	return(render_template('index.html',cards=CurrentValue,t=title,h=heading, programs=programs, issuers=issuers))

@app.route("/modify_action", methods=['POST'])
def modify_action():
	#Updating a card with various references
	name=request.values.get("name")
	cash=request.values.get("cash")
	points=request.values.get("points")
	nights=request.values.get("nights")
	spend=request.values.get("spend")
	fee=request.values.get("fee")
	value=request.values.get("value")
	id=request.values.get("_id")
	collection.update({"_id":ObjectId(id)}, {'$set':{ "CardName":name, "Cash":cash, "Points":points, "Nights":nights, "Spend":spend, "Fee":fee, "Value":value }})
	return(redirect("/view"))

if __name__ == "__main__":
    app.run(debug=True)
# Careful with the debug mode..



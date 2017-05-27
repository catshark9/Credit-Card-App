from flask import Flask, render_template,request,redirect,url_for # For flask implementation
from pymongo import MongoClient # Database connector
from bson.objectid import ObjectId # For ObjectId to work

client = MongoClient('localhost', 27017)    #Configure the connection to the database
db = client.budget    #Select the database
current_budget = db.current_budget #Select the collection

app = Flask(__name__)
title = "Budget with Flask"
heading = "Budget"

cfs_t = current_budget.find()
total_in = 0
total_out = 0
for cf in cfs_t:
	if cf['io'] == 'in':
		total_in = total_in + float(cf['amount'])
	else:
		total_out = total_out + float(cf['amount'])
total_all = total_in - total_out


def redirect_url():
    return request.args.get('next') or \
           request.referrer or \
           url_for('index')

@app.route("/list")
def lists ():
	#Display all Cash Flow
	cfs = current_budget.find()
	a1="active"
	return render_template('index.html',a1=a1,cfs=cfs,t=title,h=heading, total=total_all)

@app.route("/")
@app.route("/cf_in")
def tasks ():
	#Display Cash flows coming in
	cfs = current_budget.find({"io":"in"})
	a2="active"
	return render_template('index.html',a2=a2,cfs=cfs,t=title,h=heading, total=total_in)
	
@app.route("/cf_out")
def completed ():
	#Display cash flows coming out
	cfs = current_budget.find({"io":"out"})
	a3="active"
	return render_template('index.html',a3=a3,cfs=cfs,t=title,h=heading, total=total_out)
	
@app.route("/add", methods=['POST'])
def add ():
	#Adding a Task
	name=request.values.get("name")
	amount=request.values.get("amount")
	month=request.values.get("month")
	year=request.values.get("year")
	io=request.values.get("io")
	current_budget.insert({ "name":name, "amount":amount, "month":month, "year":year, "io":io})
	return redirect("/list")	
	
@app.route("/remove")
def remove ():
	#Deleting a cash flow with various references
	key=request.values.get("_id")
	current_budget.remove({"_id":ObjectId(key)})
	return redirect("/")
	
@app.route("/update")
def update ():
	id=request.values.get("_id")
	cfs=current_budget.find({"_id":ObjectId(id)})
	return render_template('update.html',cfs=cfs,h=heading,t=title)

@app.route("/action3", methods=['POST'])
def action3 ():
	#Updating a Task with various references
	name=request.values.get("name")
	amount=request.values.get("amount")
	month=request.values.get("month")
	year=request.values.get("year")
	io=request.values.get("io")
	id=request.values.get("_id")
	current_budget.update({"_id":ObjectId(id)}, {'$set':{ "name":name, "amount":amount, "month":month, "year":year, "io":io }})
	return redirect("/")

@app.route("/search", methods=['GET'])
def search():
	#Searching a cashflow with various references

	key=request.values.get("key")
	refer=request.values.get("refer")
	if(key=="_id"):
		cfs = current_budget.find({refer:ObjectId(key)})
	else:
		cfs = current_budget.find({refer:key})
	return render_template('searchlist.html',cfs=cfs,t=title,h=heading)
	
	
@app.route("/about")
def about():
	return render_template('credits.html',t=title,h=heading)

if __name__ == "__main__":
    app.run(debug=True)
# Careful with the debug mode..



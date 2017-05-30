# Credit-Card-App

Python libraries needed:
flask, pymongo, bson, json, pandas

install in cmd by pip install package

start mongodb
run setup.py in the root directory by python setup.py

then run the app by python app.py and point your browser to http://localhost:5000/

api is found at http://localhost:5000/CurrentCards/CurrentValue

For the scraper,
R packages needed:
rvest, stringr

install in r by install.packages('package') # including the quotes

Edit 'fullScript.R' to include the path to the scraper folder
Edit 'fullScripts.bat' to include the path to the 'fullScript.R" file
Right click 'fullScripts.bat' to run, or set up a task scheduler to run routinely 

The app should work without running the scraper as I update the currentvalue list myself. 


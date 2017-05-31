# Credit-Card-App
This app is built off Python 3

Python libraries needed:

flask, pymongo, bson, json



open cmd

type pip install flask 

Do the same for the rest



start mongodb

run setup.py in the root directory


then run app.py and point your browser to http://localhost:5000/


api is found at http://localhost:5000/CurrentCards/CurrentValue


The app should work without running the scraper as I update the currentvalue list myself and push to my github


For the scraper

R packages needed:

rvest, stringr


install in r by install.packages('package') # including the quotes


phantomjs.exe is also needed to be downloaded and extracted into /scraper

That can be downloaded here: http://phantomjs.org/


Edit 'fullScript.R' to include the path to the scraper folder

Edit 'fullScripts.bat' to include the path to the 'fullScript.R" file

Right click 'fullScripts.bat' to run, or set up a task scheduler to run routinely 




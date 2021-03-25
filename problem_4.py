# Problem 4: Following the context of problem 3, set up an application server and do the following:
# 1.  List all employees with their first name and last name and their titles.
# 2.  Provide a list of checkboxes for each title (VP, Director, Manager, etc.) in a form, list the first name and last name of all employees whose titles are selected in the checkboxes.
# 3.  Bonus: Provide a form that could allow you to add Team D to to Manager B of Development under Studio B.

# Hint: You can use nginx as web server and either php7 or python3 as the programing language for the application. Attach the document that instructs how to install the web server, exact php version and python version and MySQL server version and where to put your code to the system. Or you can provide such code and the instruction via GitHub so we can download it from there.


import requests
from fastapi import FastAPI

app = FastAPI()


@app.get("/")
async def root():
    return {"Hello": "API"}


@app.get("/domain/{domain}")
async def get_domain(domain: str):
    response = requests.get("http://ip-api.com/json/" + domain)
    return response.json()



import os

environment = os.getenv("SHELL")
if environment == "/bin/bash":
    print("Greetings bash")
else:
    print("Hello " + environment)

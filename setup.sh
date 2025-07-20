# This script ensures that the repository is ready to be run.

# Create a Python virtual environment and activate it
python3 -m venv "./.venv";
source "./.venv/bin/activate";

# Prompt for a secret key
SECRETKEY="";
echo "Provide a secret key (leave blank to seed with the nanoseconds since the UNIX Epoch):";
read SECRETKEY;
if [ "$SECRETKEY" = "" ]; then
	echo "No key provided, using nanoseconds since the UNIX Epoch";
	SECRETKEY="$(date +%s%N)";
fi;

# Append new secret key to a new or existing ./.env file
if [ ! -f "./.env" ]; then
	echo "Creating new .env file with secret key";
	touch "./.env";
else
	echo "Appending new secret key to existing .env file";
fi;
printf '$\nSECRET_KEY=\"<%s>\"\n' "$SECRETKEY" >> "./.env";

# Install dependencies
pip install -r "./requirements.txt";

# Make database migrations and apply them
python3 "./manage.py" makemigrations;
python3 "./manage.py" makemigrations cosmos_app;
python3 "./manage.py" makemigrations accounts_app;
python3 "./manage.py" migrate;

# Deactivate the python virtual environment
deactivate;
return 0;

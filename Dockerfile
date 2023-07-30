FROM python:3.10.2-slim-bullseye
LABEL Name=python_ph_bot Version=0.0.1
RUN apt-get -y update
RUN apt-get install gcc -y

RUN mkdir -p /srv/python/
WORKDIR /srv/python/
COPY . .
# RUN pip install --upgrade pip
# RUN pip install discord
RUN pip install -r requirements.txt

# CMD python run.py token
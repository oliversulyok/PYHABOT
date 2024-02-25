FROM python:3.11.8-slim-bullseye
LABEL Name=python_ph_bot Version=0.0.1

RUN apt-get update
RUN apt-get install gcc python3-dev -y

RUN mkdir -p /srv/python/
ADD . /srv/python/
WORKDIR /srv/python/
# RUN pip install --upgrade pip
# RUN pip install discord
RUN pip install -r requirements.txt

ENTRYPOINT ["python", "run.py"]
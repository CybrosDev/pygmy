import datetime
import os

from flask import Flask
from flask_cors import CORS
from flask_jwt_extended import JWTManager
from pygmy.config import config

app = Flask(__name__)
default_origins = [
    "https://snipzy.cybroscloud.com",
    "http://127.0.0.1:8000",
    "http://localhost:8000",
]
cors_origins = [
    origin.strip().rstrip('/')
    for origin in os.environ.get('CORS_ALLOWED_ORIGINS', ','.join(default_origins)).split(',')
    if origin.strip()
]
CORS(app, resources={r"/*": {"origins": cors_origins}})
app.config['DEBUG'] = config.debug
app.config.setdefault('JWT_ACCESS_TOKEN_EXPIRES', datetime.timedelta(minutes=1))
app.config.setdefault('JWT_REFRESH_TOKEN_EXPIRES', datetime.timedelta(days=7))
app.config.setdefault('JWT_HEADER_NAME', 'JWT_Authorization')
app.secret_key = config.secret

jwt = JWTManager(app)

# This import is required. Removing this will break all hell loose.
import pygmy.rest.urls as _


def run():
    app.run(host=config.host, port=int(config.port))

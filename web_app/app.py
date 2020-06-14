from flask import Flask, redirect, url_for, request, render_template
from werkzeug.utils import secure_filename
from gevent.pywsgi import WSGIServer
import tensorflow as tf


app = Flask(__name__)
model = tf.keras.models.load_model('model/GoogLeNet.h5')
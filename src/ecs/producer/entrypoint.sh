#!/bin/sh
gunicorn main:app --config ./gunicorn.conf.py

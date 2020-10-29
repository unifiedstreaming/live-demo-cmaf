#!/bin/sh

if [ $# -eq 0 ]
then
  python3 /usr/local/bin/entrypoint.py
else
  exec "$@"
fi
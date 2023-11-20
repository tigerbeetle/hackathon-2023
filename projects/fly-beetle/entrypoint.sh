#!/bin/sh -eu
rm /data/tigerbeetle

if ! [ -e /data/tigerbeetle ]; then
    /tigerbeetle format --cluster=0 --replica=0 --replica-count=1 /data/tigerbeetle
fi
exec /tigerbeetle start --cache-grid=512mb --addresses=0.0.0.0:5000 /data/tigerbeetle


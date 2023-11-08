Participant: Chandrakant Gopalan (individual)


# tbcli
a TigerBeetle REPL with syntax highlighting and autocomplete. Inspired by the CLIs in [dbcli](https://www.dbcli.com/) 

## Quickstart

Create and activate virtual env:
```
python -m venv myenv
source myenv/bin/activate
```
CD to the project root (`tbrepl` directory) and install required packages
```
pip install -r requirements.txt
```
Start your tigerbeetle database if not already started (in another terminal):
```
path/to/tigerbeetle/executable start --addresses=3000 0_0.tigerbeetle
```
Start the REPL:
```
python tbcli.py full/path/to/tigerbeetle/executable
```

## Features

tbcli is written using `prompt_toolkit` and `pygments` so it has autocomplete and syntax highlighting.


## Why this should not be used yet

- Ideally it should use a Python client as backend, but TB's Python client is still not released yet
- So it echos commands to the TB client, which means for every command it starts up the client, runs the command and closes the connection.
- Output is properly parsed only in few cases, and needs a lot of work.
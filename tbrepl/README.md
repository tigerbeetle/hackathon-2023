Participant: Chandrakant Gopalan (individual)


# tbcli
a TigerBeetle REPL with syntax highlighting and autocomplete. Inspired by the CLIs in [dbcli](https://www.dbcli.com/) 

## Screenshots
<img width="484" alt="Screen Shot 2023-11-07 at 3 08 42 PM" src="https://github.com/cgopalan/hackathon-2023/assets/395294/d2b41c53-05ed-4824-aaa1-add273a7938f">

<img width="524" alt="Screen Shot 2023-11-07 at 3 09 25 PM" src="https://github.com/cgopalan/hackathon-2023/assets/395294/b745e3c1-ab60-4a79-a977-d59c03c42345">

<img width="449" alt="Screen Shot 2023-11-07 at 3 10 01 PM" src="https://github.com/cgopalan/hackathon-2023/assets/395294/043c1382-a1ee-4f4f-b60e-63d43926a405">


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

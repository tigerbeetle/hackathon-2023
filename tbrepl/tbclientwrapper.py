import subprocess
import json


def execute(tbpath, cmd, cluster=0, addresses=3000):
    prepared_cmd = f'echo "{cmd};" | {tbpath} client --cluster={cluster} --addresses={addresses}'
    cp = subprocess.run(["sh", "-c", prepared_cmd], capture_output=True)
    out_msg = cp.stdout
    err_msg = cp.stderr
    json_str = out_msg[out_msg.find(b"{"):out_msg.find(b"}")+1]
    if json_str:
        return json.dumps(json.loads(json_str), indent=4)
    else:
        start_pos = out_msg.find(b"> ")
        end_pos = out_msg.find(b"\nExiting.")
        return out_msg[start_pos:end_pos] + (b'' if b"info" in err_msg else err_msg)

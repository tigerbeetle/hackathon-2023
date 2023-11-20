# fly-beetle

Teaching the tigerbeetle to fly.

Prerequisites:
- [fly.io cli](https://fly.io/docs/hands-on/install-flyctl/)
- An account at fly.io

```bash
# Init a new application (But don't deploy it yet)
fly launch --no-deploy

# Need to allocate a static ip for the beetle
fly ip allocate-v4

# Ensure that the volume is at least 2GB
fly volumes extend --size 2 

# The beetle is a hungry hippo
fly scale memory 4608 
fly scale vm shared-cpu-4x

# Deploy the beetle
fly deploy

# Connect to the beetle
./tigerbeetle client --cluster=0 --addresses=[insert ip here]:5000
```
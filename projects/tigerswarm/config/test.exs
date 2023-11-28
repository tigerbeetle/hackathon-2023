import Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :tigerswarm, TigerSwarmWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "2uSjO7qgR/+NSbrVaaQL3bDDwPT4FXBfIPZRYW3RN5JI3Ges6w2My1zIdhYCL7Jr",
  server: false

# Print only warnings and errors during test
config :logger, level: :warning

# Initialize plugs at runtime for faster test compilation
config :phoenix, :plug_init_mode, :runtime

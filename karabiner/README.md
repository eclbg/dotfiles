# Karabiner config

## Generate config

`generate_config.py` generates a complete config using `base-config.json` as a starting point.
It writes the full config in the `full-config.json` file, that has to be copied to
`~/.config/karabiner/karabiner.json`

`generate_config.py` takes care of adding complex modifications to the base config, as they
can be very tedious to write manually and it's easy to make mistakes.

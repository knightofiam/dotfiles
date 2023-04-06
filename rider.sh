#!/usr/bin/env bash

properties_file="/Applications/Rider.app/Contents/bin/idea.properties"

# Enable unlimited console scrollback depth for JetBrains Rider.
grep -xq "^idea.cycle.buffer.size=.*$" "${properties_file}" && gsed -i "s@^idea.cycle.buffer.size=.*@idea.cycle.buffer.size=disabled@g" "${properties_file}"

grep -xq "^idea.cycle.buffer.size=disabled$" "${properties_file}" && \
  echo "Successfully enabled unlimited console scrollback depth for JetBrains Rider in ${properties_file}." || \
  echo "Error: Failed to enable unlimited console scrollback depth for JetBrains Rider in ${properties_file}."

#!/bin/sh
sed -ri -e 's/^Exec=steam /Exec=flatpak run com.valvesoftware.Steam /' "$@"

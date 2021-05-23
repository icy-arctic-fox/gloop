#!/bin/sh

xvfb-run -a -s "-screen 0 '${XVFB_WHD}' -nolisten tcp +extension GLX +render -noreset" "$@"

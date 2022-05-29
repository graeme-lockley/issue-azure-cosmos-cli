#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

shellcheck -x "$SCRIPT_DIR"/../scripts/*.sh
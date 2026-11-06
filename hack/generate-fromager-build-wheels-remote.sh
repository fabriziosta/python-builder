#!/bin/bash

set -euo pipefail

ROOT="$( cd "$( dirname "${BASH_SOURCE[0]}" )/.." >/dev/null 2>&1 && pwd )"

cd "${ROOT}/task-generator/remote"
GOTOOLCHAIN=auto GOSUMDB=sum.golang.org go build -o /tmp/fromager-build-wheels-remote-generator main.go

/tmp/fromager-build-wheels-remote-generator \
    --source-task="${ROOT}/tekton/tasks/python-fromager-build-wheels/0.2/python-fromager-build-wheels.yaml" \
    --remote-task="${ROOT}/tekton/tasks/python-fromager-build-wheels-remote/0.2/python-fromager-build-wheels-remote.yaml"

# python-fromager-build-wheels remote task generation

The `python-fromager-build-wheels` task builds Python wheels with
`lightwell-build-wheels` and publishes them as an OCI artifact. The standard
task runs in-cluster. The remote variant offloads the `build-wheels` step to a
VM provisioned by the
[Multi-Platform Controller](https://github.com/konflux-ci/multi-platform-controller)
(MPC), which provides SSH credentials via a Kubernetes Secret.

The remote task is **programmatically generated** from the vanilla task so the
two stay in sync. **Do not hand-edit**
`tekton/tasks/python-fromager-build-wheels-remote/0.2/python-fromager-build-wheels-remote.yaml`.
Edit `tekton/tasks/python-fromager-build-wheels/0.2/python-fromager-build-wheels.yaml`
and regenerate.

This tool is used by `hack/generate-fromager-build-wheels-remote.sh`.

## Arguments

- `source-task` — path to the vanilla task YAML (required)
- `remote-task` — path to the remote task YAML to overwrite (required)

Example:

```bash
go run . \
  --source-task ../../tekton/tasks/python-fromager-build-wheels/0.2/python-fromager-build-wheels.yaml \
  --remote-task ../../tekton/tasks/python-fromager-build-wheels-remote/0.2/python-fromager-build-wheels-remote.yaml
```

Or from the repository root:

```bash
./hack/generate-fromager-build-wheels-remote.sh
```

## MPC contract

The generated task:

1. Declares a required volume secret named `multi-platform-ssh-$(context.taskRun.name)`
2. Adds a `PLATFORM` parameter (e.g. `linux/arm64`)
3. Adds `IMAGE_APPEND_PLATFORM` (default `false`) so matrixed pipelines can set
   it to `true` and get unique per-arch OCI tags (same as buildah-remote)

MPC watches TaskRuns with that secret prefix and `PLATFORM`, provisions a host,
and creates the secret. The `build-wheels` step then SSHes to the VM, rsyncs
`workdir`, runs `$(params.PYTHON_BUILDER_IMAGE)` via `podman run`, and rsyncs
results back so the local `create-manifest-artifact` step continues to work.

Pipelines fan out platforms with a Tekton matrix over `build-platforms` (array)
injecting `PLATFORM` into a single remote task — not one hardcoded task per arch.

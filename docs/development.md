# Local verification

Docker is the only development prerequisite. From the repository root:

```sh
docker build -t plex-s3fs-test .
docker run --rm --network none --read-only --cap-drop ALL \
  --security-opt no-new-privileges --tmpfs /tmp:rw,nosuid,nodev,size=64m \
  plex-s3fs-test
```

`test.sh` runs ShellCheck on both shell scripts, then runs the real installer with
fake input and a private temporary filesystem. An allowlisted `sudo` mock and
restricted PATH intercept package installation and mounting. Unexpected commands
fail closed. The container runs unprivileged, offline, and read-only apart from
its temporary directory; no Docker socket or host directories are mounted.

The checks verify credential contents and mode `0600`, mount-directory creation,
fstab contents, repeat-run behavior, failure propagation, incomplete input, and
absence of fake credentials from output. Real package installation, AWS access,
FUSE behavior, and Plex playback require separate deployment testing.

There are no hosted workflows, Git hooks, JavaScript tools, or environment managers.
Documentation diagrams render directly on GitHub.

## Code readability

Prefer descriptive names, explicit error handling, and blank lines between logical
steps. Keep one operation per line and use comments to explain non-obvious intent.
Readable code takes priority over a smaller line count.

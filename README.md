# <img src="assets/brand/logo.png" alt="" height="64" /> plex-s3fs

<img src="assets/brand/social-preview.png" alt="plex-s3fs — your media, backed by S3, with a cloud-and-cinema mascot" width="1280" />

![Shell](https://img.shields.io/badge/Shell-1C2230?logo=gnubash&logoColor=white)
![Plex](https://img.shields.io/badge/Plex-1C2230?logo=plex&logoColor=FFCC4D)
![Amazon S3](https://img.shields.io/badge/Amazon_S3-5EAD9B)
![s3fs](https://img.shields.io/badge/s3fs-F05B62)
[![License](https://img.shields.io/badge/License-PolyForm_Shield_1.0.0-F05B62)](./LICENSE)
[![Local verification](https://img.shields.io/badge/verification-local_Docker-5EAD9B)](docs/development.md)
![Bun](https://img.shields.io/badge/Bun-1.3.11-1C2230?logo=bun)
![Flox](https://img.shields.io/badge/Flox-dev_environment-5EAD9B)
![Say Thanks](https://img.shields.io/badge/say-thanks-ff69b4.svg)

A Plex Media Server backed by an Amazon S3 bucket through s3fs.

This legacy Bash installer configures an Ubuntu host, installs Plex through
Snap, and adds an S3 filesystem mount. Review the deployment prerequisites
before running it: current Ubuntu, Snap confinement, FUSE permissions, and
Plex access to the mount require server-specific validation.

## Documentation

- [Getting started](docs/getting-started.md): prerequisites, reviewed installation,
  and headless server setup.
- [Architecture](docs/architecture.md): media flow, installer behavior, and limitations.
- [Local development](docs/development.md): Flox, Docker checks, and pre-commit.
- [Brand assets](assets/brand/README.md): logo, palette, and usage.

## Local verification

With Docker running:

```sh
flox activate -- ./test/verify.sh
```

Or run `./test/verify.sh` directly. The full local pipeline checks shell syntax,
ShellCheck, Markdown, Mermaid rendering, negative controls, and a 250-line
handwritten code/config budget. No hosted CI service is configured.

Verification never executes the installer, installs Plex, mounts S3, or uses
AWS credentials. See the [verification scope](docs/development.md) before deploying.

## Liability

The creator of this repo is not responsible if your machine ends up in a state
you are not happy with.

## License

Copyright © 2026 Nicholas Adamou.

The project is licensed under [PolyForm Shield License 1.0.0](LICENSE),
with Nicholas Adamou as the holder.

The original Apache license for earlier code is preserved in
[LICENSES/Apache-2.0.txt](LICENSES/Apache-2.0.txt); see [NOTICE](NOTICE).

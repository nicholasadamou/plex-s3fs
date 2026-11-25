# <img src="assets/brand/logo.png" alt="" height="64" /> plex-s3fs

<img src="assets/brand/social-preview.png" alt="plex-s3fs — your media, backed by S3, with a cloud-and-cinema mascot" width="1280" />

![Shell](https://img.shields.io/badge/Shell-1C2230?logo=gnubash&logoColor=FFF4D6&labelColor=1C2230)
![Plex](https://img.shields.io/badge/Plex-1C2230?logo=plex&logoColor=FFCC4D&labelColor=1C2230)
![Amazon S3](https://img.shields.io/badge/Amazon_S3-5EAD9B?labelColor=1C2230)
![s3fs](https://img.shields.io/badge/s3fs-F05B62?labelColor=1C2230)
[![License](https://img.shields.io/badge/License-PolyForm_Shield_1.0.0-F05B62?labelColor=1C2230)](./LICENSE)
[![Local verification](https://img.shields.io/badge/verification-local_Docker-5EAD9B?labelColor=1C2230)](docs/development.md)
![Bun](https://img.shields.io/badge/Bun-1.3.11-1C2230?logo=bun&logoColor=FFF4D6&labelColor=1C2230)
![Flox](https://img.shields.io/badge/Flox-dev_environment-5EAD9B?labelColor=1C2230)
![Say Thanks](https://img.shields.io/badge/say-thanks-FFCC4D?labelColor=1C2230)

A Plex Media Server backed by an Amazon S3 bucket through s3fs.

This Bash installer configures an Ubuntu host, installs Plex through Snap,
and adds an S3 filesystem mount. It uses standard system commands without
downloading shell helpers. Review the deployment prerequisites
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
ShellCheck, mocked installer integration, Markdown, Mermaid rendering, negative
controls, and a 350-line
handwritten code/config budget. No hosted CI service is configured.

Integration tests execute the real installer inside Docker with fail-closed
system mocks and fake credentials. They never install Plex, mount S3, or contact
AWS. See the [verification scope](docs/development.md) before deploying.

## Liability

The creator of this repo is not responsible if your machine ends up in a state
you are not happy with.

## License

Copyright © 2026 Nicholas Adamou.

The project is licensed under [PolyForm Shield License 1.0.0](LICENSE),
with Nicholas Adamou as the holder.

The original Apache license for earlier code is preserved in
[LICENSES/Apache-2.0.txt](LICENSES/Apache-2.0.txt); see [NOTICE](NOTICE).

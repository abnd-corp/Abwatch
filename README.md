# Abwatch

Helper script for Docker image security auditing. It sets up the two tools Abwatch relies on: [Trivy](https://trivy.dev) (vulnerability scanner) and [Dockle](https://github.com/goodwithtech/dockle) (container image linter).

> **Status: early.** `script.sh` currently checks that Trivy and Dockle are installed and offers to install them. The audit itself (running both tools on an image and reporting the result) is not written yet.

## What it does today

1. Checks that `trivy` and `dockle` are available.
2. If one is missing, asks whether to download it into `~/.local/bin`.
3. Re-checks, and optionally adds `~/.local/bin` to your `PATH` in `~/.bashrc` or `~/.zshrc`.

## Usage

```bash
bash script.sh
```

Notes:

- Trivy is downloaded for your system (`uname -s` / `uname -m`).
- Dockle is downloaded as the **Linux 64-bit** build, version 0.4.15. On other systems, install it yourself.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md) and the [Abnd charter](https://github.com/abnd-corp/gouvernance/blob/main/CHARTE.md) (in French).

## Licence

AGPL-3.0-or-later: see [LICENSE](LICENSE).

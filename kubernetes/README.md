# Kubernetes helper scripts

This folder contains helper scripts and notes for installing Kubernetes tooling locally on macOS (Apple Silicon). The main helper script is `installK8s.sh` which installs Homebrew (if missing), required packages for Minikube, and Minikube itself.

## Purpose

The README explains how to safely run `installK8s.sh`, including the script's integrity checks and environment variables you can set to control behavior.

## Files

- `installK8s.sh` — macOS (Apple Silicon) installer script for Homebrew (optional), curl, kubectl, hyperkit (optional), and Minikube.

## Security and integrity

The script intentionally avoids piping the Homebrew installer directly into `bash` from the network. Instead it:

- Downloads the Homebrew installer to a temporary file.
- Requires an expected SHA256 checksum be provided via the `HOMEBREW_INSTALLER_SHA256` environment variable for automated installs.
- Refuses to run the installer automatically if the checksum is missing or does not match.
- Provides a skip flag (`SKIP_HOMEBREW_INSTALL=1`) to avoid unattended automated installs and prints manual, audited instructions instead.

This helps prevent executing tampered installers in unattended runs.

## Environment variables

- `HOMEBREW_INSTALLER_SHA256` (recommended for automated installs): set this to the expected SHA256 checksum of the Homebrew installer script before running `installK8s.sh`. The script will verify the downloaded installer matches this checksum and exit if it doesn't.

- `SKIP_HOMEBREW_INSTALL=1`: if set, the script will skip automated Homebrew installation and print manual instructions to audit and run the Homebrew installer yourself.

## Usage examples

1) Automated run with checksum verification (recommended):

```bash
# Get or set the expected checksum first (replace with the known-good value)
export HOMEBREW_INSTALLER_SHA256="<expected-sha256-value>"

# Run the installer script
bash kubernetes/installK8s.sh
```

2) Skip automated Homebrew install (manual, audited install):

```bash
export SKIP_HOMEBREW_INSTALL=1
bash kubernetes/installK8s.sh
# The script will exit and provide instructions for manually auditing and running the installer.
```

## How to compute/verify the checksum locally

If you want to compute the checksum yourself before running the script (recommended when pinning a trusted release):

```bash
# Download the installer locally (do not run it yet):
curl -fsSL -o /tmp/homebrew-install.sh https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh

# Compute SHA256
shasum -a 256 /tmp/homebrew-install.sh
# or, if you prefer openssl
openssl dgst -sha256 /tmp/homebrew-install.sh

# Copy the resulting hex string and set the environment variable:
export HOMEBREW_INSTALLER_SHA256="<hex-string-from-above>"

# Now run the installer script which will verify the checksum before executing
bash kubernetes/installK8s.sh
```

Important: always audit the installer script content before running it (review it manually or with a trusted reviewer) and confirm the checksum you pin comes from a trusted source.

## What the script installs

- Homebrew (only if missing and only after successful checksum verification)
- curl (essential)
- kubectl (essential)
- hyperkit (optional driver for Minikube; script continues if installation fails)
- minikube

Failures when installing essential components (curl or kubectl) will abort the script. Hyperkit is optional and its install is tolerant — the script will continue if it can't be installed.

## Troubleshooting

- If the script prints a checksum mismatch, do not proceed. Either obtain the correct, trusted checksum or fetch and inspect the installer manually.
- If `brew install curl` or `brew install kubectl` fails, inspect the brew output and re-run after resolving the issue — the script intentionally fails on these errors so you can fix underlying problems.

## Notes and follow-ups

- This README focuses on safety and reproducibility for unattended runs. If you'd like, we can add an optional CLI flag to the script (for example `--auto-approve`) to streamline automation in CI once you've pinned an approved checksum in the repository or CI environment.

---

If you want any additional sections (e.g., example output, links to upstream Homebrew documentation, or a pinned checksum for a specific known installer snapshot), tell me which and I will add them.
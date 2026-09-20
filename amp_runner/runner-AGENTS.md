# Live Home Assistant Configuration

This directory is the live configuration of a production Home Assistant installation. File writes take effect immediately; they are not an isolated checkout or preview.

## Safety

- Read the relevant configuration and its includes before editing.
- Never read, print, copy, or commit `secrets.yaml`, `.storage/`, databases, logs, authentication data, or tokens unless the user explicitly requests that exact access.
- Do not modify or rely on Git metadata found in this directory unless the user confirms it is authoritative.
- Avoid heavyweight builds, test suites, and long-running processes because this runner shares resources with Home Assistant.
- Do not restart Home Assistant unless the user explicitly requests it.

## Validation

- Run `ha-check` after YAML or integration changes. A successful command proves Supervisor accepted the configuration.
- `ha-info` reports the current Home Assistant Core state.
- `ha-restart` refuses by default. After an explicit restart request and a successful `ha-check`, run `ha-restart --confirm`.
- Dashboard-only YAML changes normally need a browser hard refresh rather than a restart.

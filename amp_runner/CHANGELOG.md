# Changelog

## 0.1.3

- Enable Home Assistant API access so the runner can read entity state instead of receiving 401 responses.
- Use the `manager` Supervisor role so the runner can create backups, which the `homeassistant` role forbids.

## 0.1.2

- Scrub credentials at the shell executable boundary after confirming Amp injects profile authentication after shell startup.

## 0.1.1

- Remove the Amp token from agent shell environments when newer Amp CLI versions load authentication from the persistent profile.

## 0.1.0

- Initial public release.
- Support Home Assistant OS on amd64 and aarch64.
- Provide guarded configuration validation, system information, and restart helpers.
- Keep Amp and Supervisor credentials out of agent command environments.

# Amp Runner

Amp Runner runs the Amp CLI on Home Assistant OS and registers it as a remote runner with `/config` as its working directory.

## Configuration

- `amp_api_key`: An Amp access token from [Amp security settings](https://ampcode.com/settings/security).
- `runner_id`: The runner name shown in Amp. Defaults to `homeassistant`.
- `remote_control_terminal`: Exposes terminal access through Amp remote control. Disabled by default.
- `screenshot_token`: Optional. A Home Assistant long-lived access token that `ha-screenshot` uses to open the frontend. Create it for a dedicated non-administrator user, because the token can do anything that user can do in Home Assistant.

## Security model

- The app makes outbound connections to Amp and exposes no inbound network ports.
- The Amp token is a password option. At startup it is written to Amp's private persistent profile rather than exported to the runner process.
- The container's Bash launcher removes Amp and Supervisor credentials before agent shell commands execute.
- The runner remains a trusted root process inside the app container, not a security sandbox. It can access its own options and private profile.
- `/config` is mounted read/write. Startup verifies access with a temporary file before registering the runner.
- The app installs conservative agent guidance as `/config/AGENTS.md` only when that file does not already exist.
- The `manager` Supervisor role supports `ha-check`, `ha-info`, and guarded `ha-restart --confirm` commands, and lets the runner create backups. It also allows managing other apps, the host, and the app store, so treat the runner as an administrator of the Home Assistant installation.
- Home Assistant API access lets the runner read entity state and call services through `http://supervisor/core/api/` with the token in `/run/amp-runner/supervisor-token`.

## Operation

Use `ha-check` after configuration changes. Do not restart Home Assistant unless necessary and explicitly intended. The restart helper refuses to run without `--confirm`.

`ha-screenshot <path> <output.png>` renders a frontend page, such as `/lovelace/0`, with headless Chromium and writes a PNG, so agents can review dashboards after changing them. Chromium starts for one capture and exits afterwards; it is controlled over a pipe and opens no network port. By default the capture is 1280 pixels wide and as tall as the page; run `ha-screenshot --help` for options. JavaScript errors from the page are printed to standard error.

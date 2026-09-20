# Amp Runner for Home Assistant

Run an [Amp](https://ampcode.com) runner directly on Home Assistant OS with controlled read/write access to the live Home Assistant configuration.

## Installation

1. In Home Assistant, open **Settings → Apps → App store**.
2. Add `https://github.com/lox/home-assistant-amp-runner` as a repository.
3. Install **Amp Runner**.
4. Add an Amp access token from [Amp security settings](https://ampcode.com/settings/security) to the app configuration.
5. Start the app and select its runner ID when creating an Amp thread.

See [the app documentation](amp_runner/DOCS.md) for the security model and operating guidance.

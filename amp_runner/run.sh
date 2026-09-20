#!/usr/bin/env bash
set -euo pipefail

readonly options_file=/data/options.json
readonly credentials_dir=/run/amp-runner
export HOME=/data
export AMP_HOME=/data/.amp
readonly amp_data_dir="${HOME}/.local/share/amp"
readonly amp_secrets_file="${amp_data_dir}/secrets.json"

: "${SUPERVISOR_TOKEN:?SUPERVISOR_TOKEN is unavailable}"
install -d -m 0700 "${credentials_dir}"
printf '%s' "${SUPERVISOR_TOKEN}" > "${credentials_dir}/supervisor-token"
chmod 0600 "${credentials_dir}/supervisor-token"
unset AMP_API_KEY SUPERVISOR_TOKEN HASSIO_TOKEN

echo "Amp Runner: checking read/write Home Assistant access"
test -r /config/configuration.yaml
readonly write_test=/config/.amp-runner-write-test
printf 'Amp Runner write test\n' > "${write_test}"
rm -f "${write_test}"

if [[ ! -e /config/AGENTS.md ]]; then
	cp /etc/amp-runner/AGENTS.md /config/AGENTS.md
fi

echo "Amp Runner: checking Supervisor access and Home Assistant configuration"
ha-info >/dev/null
ha-check >/dev/null

amp_api_key="$(jq -er '.amp_api_key | select(type == "string" and length > 0)' "${options_file}")" || {
	echo "Amp Runner: configure amp_api_key before starting the app" >&2
	exit 1
}

runner_id="$(jq -er '.runner_id | select(type == "string" and test("^[a-zA-Z0-9][a-zA-Z0-9.-]*$"))' "${options_file}")"
remote_control_terminal="$(jq -er '.remote_control_terminal | select(type == "boolean")' "${options_file}")"

if [[ ! -x "${AMP_HOME}/bin/amp" ]]; then
	echo "Amp Runner: installing Amp CLI"
	curl -fsSL https://ampcode.com/install.sh | bash
fi

# Persist authentication in Amp's private profile instead of exporting it to
# the runner and every command the runner starts.
install -d -m 0700 "${amp_data_dir}"
umask 077
printf '%s' "${amp_api_key}" \
	| jq -Rs '{"apiKey@https://ampcode.com/": .}' > "${amp_secrets_file}.tmp"
mv "${amp_secrets_file}.tmp" "${amp_secrets_file}"
unset amp_api_key

args=(
	--no-tui
	--runner-id "${runner_id}"
	--dir /config
)

if [[ "${remote_control_terminal}" == true ]]; then
	args+=(--remote-control-terminal)
fi

echo "Amp Runner: starting ${runner_id} with read/write Home Assistant configuration"
export BASH_ENV=/etc/amp-runner/sanitize-env
exec "${AMP_HOME}/bin/amp" "${args[@]}"

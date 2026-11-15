#!/usr/bin/env bash
set -euo pipefail

app_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for file in config.yaml Dockerfile run.sh bash-wrapper runner-AGENTS.md DOCS.md CHANGELOG.md rootfs/usr/local/bin/ha-check rootfs/usr/local/bin/ha-info rootfs/usr/local/bin/ha-restart rootfs/usr/local/bin/ha-screenshot; do
	test -f "${app_dir}/${file}" || {
		echo "missing ${file}" >&2
		exit 1
	}
done

ruby -e '
require "yaml"
config = YAML.safe_load(File.read(ARGV.fetch(0)))
abort "wrong slug" unless config["slug"] == "amp_runner"
abort "amd64 and aarch64 support are required" unless config.fetch("arch").sort == %w[aarch64 amd64]
abort "Supervisor API must be enabled" unless config["hassio_api"] == true
abort "runner needs the manager Supervisor role for Core and backups" unless config["hassio_role"] == "manager"
abort "Home Assistant API must be enabled" unless config["homeassistant_api"] == true
abort "published image is required" unless config["image"] == "ghcr.io/lox/home-assistant-amp-runner"
mapping = config.fetch("map").find { |entry| entry["type"] == "homeassistant_config" }
abort "missing Home Assistant config mapping" unless mapping
abort "config mapping must be read/write" unless mapping["read_only"] == false
abort "API key must use the password schema" unless config.dig("schema", "amp_api_key") == "password"
abort "screenshot token must use the optional password schema" unless config.dig("schema", "screenshot_token") == "password?"
' "${app_dir}/config.yaml"

scripts=(
	"${app_dir}/run.sh"
	"${app_dir}/rootfs/usr/local/bin/ha-check"
	"${app_dir}/rootfs/usr/local/bin/ha-info"
	"${app_dir}/rootfs/usr/local/bin/ha-restart"
)

bash -n "${scripts[@]}"
shellcheck "${scripts[@]}"
python3 -c 'import ast, sys; ast.parse(open(sys.argv[1]).read())' "${app_dir}/rootfs/usr/local/bin/ha-screenshot"

grep -Fq -- '--no-tui' "${app_dir}/run.sh"
grep -Fq 'production Home Assistant' "${app_dir}/runner-AGENTS.md"
grep -Fq 'apiKey@https://ampcode.com/' "${app_dir}/run.sh"
grep -Fq 'unset AMP_API_KEY SUPERVISOR_TOKEN HASSIO_TOKEN' "${app_dir}/run.sh"
grep -Fq 'unset AMP_API_KEY SUPERVISOR_TOKEN HASSIO_TOKEN BASH_ENV ENV' "${app_dir}/bash-wrapper"
grep -Fq 'ENTRYPOINT ["/usr/bin/bash.real", "/usr/local/bin/amp-runner"]' "${app_dir}/Dockerfile"
if grep -Fq 'export AMP_API_KEY' "${app_dir}/run.sh"; then
	echo "Amp API key must not be exported to the runner environment" >&2
	exit 1
fi

echo "Amp Runner checks passed"

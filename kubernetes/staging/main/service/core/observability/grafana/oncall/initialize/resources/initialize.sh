#!/usr/bin/env sh

set -e

if [ "${GRAFANA_ADMIN_USERNAME-}" = "" ]; then
    echo "Environment variable 'GRAFANA_ADMIN_USERNAME' is not set"
    exit 1
fi

if [ "${GRAFANA_ADMIN_PASSWORD-}" = "" ]; then
    echo "Environment variable 'GRAFANA_ADMIN_PASSWORD' is not set"
    exit 1
fi

if [ "${GRAFANA_HOST-}" = "" ]; then
    echo "Environment variable 'GRAFANA_HOST' is not set"
    exit 1
fi

if [ "${GRAFANA_PORT-}" = "" ]; then
    echo "Environment variable 'GRAFANA_PORT' is not set"
    exit 1
fi

if [ "${GRAFANA_ONCALL_HOST-}" = "" ]; then
    echo "Environment variable 'GRAFANA_ONCALL_HOST' is not set"
    exit 1
fi

if [ "${GRAFANA_ONCALL_PORT-}" = "" ]; then
    echo "Environment variable 'GRAFANA_ONCALL_PORT' is not set"
    exit 1
fi

url_base="http://${GRAFANA_HOST}:${GRAFANA_PORT}/api/plugins/grafana-oncall-app"
url="${url_base}/settings"
data="{\"enabled\":true, \"jsonData\":{\"stackId\":5, \"orgId\":100, \"onCallApiUrl\":\"http://${GRAFANA_ONCALL_HOST}:${GRAFANA_ONCALL_PORT}/\", \"grafanaUrl\":\"http://${GRAFANA_HOST}:${GRAFANA_PORT}/\"}}"
echo "Configuring Grafana Oncall app settings..."
echo "==> curl -sS --user \"${GRAFANA_ADMIN_USERNAME}:***********\" \"${url}\" --json \"${data}\""
if ! curl -sS --user "${GRAFANA_ADMIN_USERNAME}:${GRAFANA_ADMIN_PASSWORD}" "${url}" --json "${data}"; then
    echo "Failed to configure Grafana Oncall app settings"
    exit 1
fi
echo ""
echo ""

url="${url_base}/resources/plugin/install"
echo "Installing Grafana Oncall app..."
echo "==> curl -sS --user \"${GRAFANA_ADMIN_USERNAME}:***********\" -X POST \"${url}\""
result=""
if ! result="$(curl -sS --user "${GRAFANA_ADMIN_USERNAME}:${GRAFANA_ADMIN_PASSWORD}" -X POST "${url}")"; then
    echo "Failed to install Grafana Oncall app"
    exit 1
fi
case "$result" in
  *onCallError*)
    echo "Failed to install Grafana Oncall app"
    echo "  $result"
    exit 1
  ;;
esac
exit 0

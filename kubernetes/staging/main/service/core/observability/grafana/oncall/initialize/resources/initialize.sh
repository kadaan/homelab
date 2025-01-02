#!/usr/bin/env sh

set -e

curl -X POST "https://admin:${GRAFANA_ADMIN_PASSWORD:?}@${GRAFANA_HOST:?}:${GRAFANA_PORT:?}/api/plugins/grafana-oncall-app/settings" -H "Content-Type: application/json" -d "{\"enabled\":true, \"jsonData\":{\"stackId\":5, \"orgId\":100, \"onCallApiUrl\":\"http://${GRAFANA_ONCALL_HOST:?}:${GRAFANA_ONCALL_PORT:?}/\", \"grafanaUrl\":\"https://${GRAFANA_HOST:?}:${GRAFANA_PORT:?}/\"}}"
curl -X POST "https://admin:${GRAFANA_ADMIN_PASSWORD:?}@${GRAFANA_HOST:?}:${GRAFANA_PORT:?}/api/plugins/grafana-oncall-app/resources/plugin/install"

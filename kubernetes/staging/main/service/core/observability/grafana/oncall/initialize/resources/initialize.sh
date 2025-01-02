#!/usr/bin/env sh

set -e

echo "Calling: curl -v \"https://${GRAFANA_ADMIN_USERNAME:?}:***********${GRAFANA_HOST:?}:${GRAFANA_PORT:?}/api/plugins/grafana-oncall-app/settings\" -H \"Content-Type: application/json\" -d \"{\\\"enabled\\\":true, \\\"jsonData\\\":{\\\"stackId\\\":5, \\\"orgId\\\":100, \\\"onCallApiUrl\\\":\\\"http://${GRAFANA_ONCALL_HOST:?}:${GRAFANA_ONCALL_PORT:?}/\\\", \\\"grafanaUrl\\\":\\\"https://${GRAFANA_HOST:?}:${GRAFANA_PORT:?}/\\\"}}\""
curl -v "https://${GRAFANA_ADMIN_USERNAME:?}:${GRAFANA_ADMIN_PASSWORD:?}@${GRAFANA_HOST:?}:${GRAFANA_PORT:?}/api/plugins/grafana-oncall-app/settings" -H "Content-Type: application/json" -d "{\"enabled\":true, \"jsonData\":{\"stackId\":5, \"orgId\":100, \"onCallApiUrl\":\"http://${GRAFANA_ONCALL_HOST:?}:${GRAFANA_ONCALL_PORT:?}/\", \"grafanaUrl\":\"https://${GRAFANA_HOST:?}:${GRAFANA_PORT:?}/\"}}"

echo "Calling: curl -v -X POST \"https://${GRAFANA_ADMIN_USERNAME:?}::?}:***********@${GRAFANA_HOST:?}:${GRAFANA_PORT:?}/api/plugins/grafana-oncall-app/resources/plugin/install\""
curl -v -X POST "https://${GRAFANA_ADMIN_USERNAME:?}:${GRAFANA_ADMIN_PASSWORD:?}@${GRAFANA_HOST:?}:${GRAFANA_PORT:?}/api/plugins/grafana-oncall-app/resources/plugin/install"

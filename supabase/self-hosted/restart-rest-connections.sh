#!/usr/bin/env bash
# Recovery for the observed Entre Huellas Dokploy installation.
# Run on the server. Restart only its PostgREST container, resetting its DB pool.
# Pending API work may be interrupted; uncommitted DB transactions roll back.
set -euo pipefail

task_project='entrehuellas-supabase-bmcwgm'
mapfile -t task_rest_ids < <(docker ps -q \
  --filter "label=com.docker.compose.project=$task_project" \
  --filter 'label=com.docker.compose.service=rest')

if [[ ${#task_rest_ids[@]} -ne 1 ]]; then
  printf 'Expected one running rest container for %s; found %s. No restart performed.\n' \
    "$task_project" "${#task_rest_ids[@]}" >&2
  docker ps --filter 'label=com.docker.compose.service=rest' \
    --format '{{.Names}} {{.Image}}'
  exit 1
fi

task_rest_id=${task_rest_ids[0]}
task_rest_image=$(docker inspect --format '{{.Config.Image}}' "$task_rest_id")
case "$task_rest_image" in
  postgrest/postgrest:*) ;;
  *) printf 'Unexpected rest image. No restart performed.\n' >&2; exit 1 ;;
esac

docker restart "$task_rest_id"
docker inspect --format '{{.Name}} {{.State.Status}}' "$task_rest_id"

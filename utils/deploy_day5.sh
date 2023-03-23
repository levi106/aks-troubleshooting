#!/bin/bash

if [ $# -ne 3 ]; then
  echo ./deploy_day5.sh "SQL Admin password" "Location" "Num of users"
  exit 1
fi

DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
LAYER=day5

${DIR}/update_node_count.sh 1
${DIR}/simulate_node_failure.sh
${DIR}/deploy_web_app.sh ${1} ${LAYER}
${DIR}/update_webtest_target_ips.sh ${2} ${3} ${LAYER}
${DIR}/enable_all_webtests.sh

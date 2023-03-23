#!/bin/bash

if [ $# -ne 4 ]; then
  echo ./deploy_day5.sh "SQL Admin password" "Location" "Num of users" "Layer name"
  exit 1
fi

DIR="$( dirname -- $( realpath -- "${BASH_SOURCE[0]}" ) )"

${DIR}/update_node_count.sh 1
${DIR}/deploy_web_app.sh ${1} ${4}
${DIR}/update_webtest_target_ips.sh ${2} ${3} ${4}
${DIR}/simulate_node_failure.sh
#!/bin/bash

DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
LAYER=day5

${DIR}/recover_from_node_failure.sh
${DIR}/delete_web_app.sh ${LAYER}
${DIR}/update_node_count.sh 2

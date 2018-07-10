#!/bin/bash

set -e

cd ../sciencebeam

python -m sciencebeam.pipeline_runners.beam_pipeline_runner \
  --data-path=$DATA_URL \
  --source-file-list=$FILE_LIST \
  --source-file-column=source_url \
  --output-suffix=$OUTPUT_FILE_SUFFIX \
  --limit=$LIMIT \
  ${SCIENCEBEAM_ARGS[@]}

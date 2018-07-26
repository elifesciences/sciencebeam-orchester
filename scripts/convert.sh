#!/bin/bash

set -e

cd ../sciencebeam

echo "NUM_WORKERS=$NUM_WORKERS"

python -m sciencebeam.pipeline_runners.beam_pipeline_runner \
  --data-path=$DATA_URL \
  --source-file-list=$FILE_LIST \
  --source-file-column=source_url \
  --output-suffix=$OUTPUT_FILE_SUFFIX \
  --num_workers=$NUM_WORKERS \
  --limit=$LIMIT \
  ${SCIENCEBEAM_ARGS[@]}

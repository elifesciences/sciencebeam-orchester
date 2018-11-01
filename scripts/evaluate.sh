#!/bin/bash

set -e

cd ../sciencebeam-judge

echo "NUM_WORKERS=$NUM_WORKERS"

python -m sciencebeam_judge.evaluation_pipeline \
  --target-file-list $DATA_URL/$FILE_LIST \
  --target-file-column=xml_url \
  --prediction-file-list $RESULTS_URL/$OUTPUT_FILE_LIST \
  --output-path $RESULTS_URL/evaluation-results/$CONVERSION_TOOL$DATA_SUFFIX \
  --num_workers=$NUM_WORKERS \
  --limit=$LIMIT \
  --skip-errors

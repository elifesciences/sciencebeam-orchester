#!/bin/bash

set -e

cd ../sciencebeam-judge

echo "NUM_WORKERS=$NUM_WORKERS"
echo "LIMIT=$LIMIT"

if [ -z "$TARGET_FILE_LIST_URL" ]; then
  TARGET_FILE_LIST_URL="$DATA_URL/$FILE_LIST"
fi

EVAL_DATA_SUFFIX="${EVAL_DATA_SUFFIX:-$DATA_SUFFIX}"
EVAL_DIR_NAME="$CONVERSION_TOOL${EVAL_DATA_SUFFIX}"

python -m sciencebeam_judge.evaluation_pipeline \
  --target-file-list "$TARGET_FILE_LIST_URL" \
  --target-file-column=xml_url \
  --prediction-file-list $RESULTS_URL/$OUTPUT_FILE_LIST \
  --output-path $RESULTS_URL/evaluation-results/$EVAL_DIR_NAME \
  --num_workers=$NUM_WORKERS \
  --limit=$LIMIT \
  --skip-errors \
  ${SCIENCEBEAM_JUDGE_ARGS}

#!/bin/bash

set -e

cd ../sciencebeam

python -m sciencebeam_gym.preprocess.get_output_files \
  --source-base-path=$DATA_URL \
  --source-file-list=$DATA_URL/$FILE_LIST \
  --source-file-column=source_url \
  --output-file-list=$RESULTS_URL/$OUTPUT_FILE_LIST \
  --output-file-suffix=$OUTPUT_FILE_SUFFIX \
  --output-base-path=$RESULTS_URL \
  --use-relative-path \
  --limit=$LIMIT \
  --check

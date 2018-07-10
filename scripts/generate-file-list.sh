#!/bin/bash

set -e

cd ../sciencebeam

python -m sciencebeam_gym.preprocess.find_file_pairs \
  --data-path=$DATA_URL \
  --source-pattern=$SOURCE_PATTERN \
  --xml-pattern=$XML_PATTERN \
  --out=$DATA_URL/$FILE_LIST \
  --use-relative-path

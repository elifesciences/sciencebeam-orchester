#!/bin/bash

set -e

cd ../sciencebeam-judge/notebooks

kernel_name=$(jupyter kernelspec list --json | jq --raw-output 'first(.kernelspecs | to_entries[] | .key)')
echo "kernel_name: $kernel_name"

cat conversion-results-tools.ipynb | jq ".metadata.kernelspec.name = \"$kernel_name\"" \
  > .conversion-results-tools-with-updated-kernel.ipynb

ALL_TOOLS_CSV=$(echo $ALL_TOOLS | tr ' ' ',')
echo "ALL_TOOLS_CSV=$ALL_TOOLS_CSV"

papermill .conversion-results-tools-with-updated-kernel.ipynb \
  .conversion-results-tools-with-updated-params.ipynb \
  -p data_path "$(dirname $DATA_URL)" \
  -p dataset_relative_paths "$(basename $DATA_URL)" \
  -p tool_names "$ALL_TOOLS_CSV"

REPORT_URL=$RESULTS_URL/evaluation-results/report$DATA_SUFFIX/report.html
echo "REPORT_URL=$REPORT_URL"

jupyter nbconvert \
  --ExecutePreprocessor.allow_errors=True \
  --ExecutePreprocessor.timeout=-1 \
  --FilesWriter.build_directory=/tmp/ \
  --TemplateExporter.exclude_input=True \
  --execute .conversion-results-tools-with-updated-params.ipynb

mkdir -p "$(dirname $REPORT_URL)"
cp -a /tmp/.conversion-results-tools-with-updated-params.html $REPORT_URL

#!/bin/bash

set -e

cd ../sciencebeam-judge/notebooks

PYTHON_SCRIPT_PREFIX=""
echo "PY3_VENV=$PY3_VENV"
if [ ! -z "$PY3_VENV" ]; then
  echo "activating $PY3_VENV"
  source "$PY3_VENV/bin/activate"
  python --version
  PYTHON_SCRIPT_PREFIX="$PY3_VENV/bin/"
fi

echo "PYTHON_SCRIPT_PREFIX=$PYTHON_SCRIPT_PREFIX"

ALL_TOOLS_CSV=$(echo $ALL_TOOLS | tr ' ' ',')
echo "ALL_TOOLS_CSV=$ALL_TOOLS_CSV"

REPORT_URL=$RESULTS_URL/evaluation-results/report$DATA_SUFFIX/report.html
echo "REPORT_URL=$REPORT_URL"

if [[ $REPORT_URL =~ ^gs.* ]]; then
  echo "report url is gs"
  cp_cmd="gsutil cp -P"
else
  echo "report url is not gs"
  mkdir -p "$(dirname $REPORT_URL)"
  cp_cmd="cp -a"
fi

kernel_name=$(${PYTHON_SCRIPT_PREFIX}jupyter kernelspec list --json | jq --raw-output 'first(.kernelspecs | to_entries[] | .key)')
echo "kernel_name: $kernel_name"

papermill conversion-results-tools.ipynb \
  /tmp/.conversion-results-tools-with-updated-params.ipynb \
  --kernel=$kernel_name \
  -p data_path "$(dirname $DATA_URL)" \
  -p dataset_relative_paths "$(basename $DATA_URL)" \
  -p tool_names "$ALL_TOOLS_CSV"
  # --prepare-only \

jupyter nbconvert \
  --ExecutePreprocessor.allow_errors=True \
  --ExecutePreprocessor.timeout=-1 \
  --FilesWriter.build_directory=/tmp/ \
  --TemplateExporter.exclude_input=True \
  --ExecutePreprocessor.kernel_name=$kernel_name \
  --execute /tmp/.conversion-results-tools-with-updated-params.ipynb

$cp_cmd /tmp/.conversion-results-tools-with-updated-params.html $REPORT_URL

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

EVAL_DATA_SUFFIX="${EVAL_DATA_SUFFIX:-$DATA_SUFFIX}"

echo "IS_PDF=$IS_PDF"
echo "EVAL_DATA_SUFFIX=$EVAL_DATA_SUFFIX"

CONFIG_DIR="/srv/sciencebeam-orchester/config"

echo "ALL_TOOLS (original)=$ALL_TOOLS"

if [ "$IS_PDF" == true ]; then
  ALL_TOOLS_SUPPORTING_PDF=()
  echo "filtering tools that support PDF..."
  for tool_name in $(echo $ALL_TOOLS | tr ',' ' '); do
    TOOL_SUPPORTS_PDF=$(
      SUPPORTS_PDF=true bash -c \
      "source '$CONFIG_DIR/tools/$tool_name.sh' && echo \$SUPPORTS_PDF"
    )
    echo "tool: $tool_name, TOOL_SUPPORTS_PDF=$TOOL_SUPPORTS_PDF"
    if [ "$TOOL_SUPPORTS_PDF" == true ]; then
      ALL_TOOLS_SUPPORTING_PDF+=("$tool_name")
    fi
  done
  echo "ALL_TOOLS_SUPPORTING_PDF=${ALL_TOOLS_SUPPORTING_PDF[@]}"
  ALL_TOOLS=${ALL_TOOLS_SUPPORTING_PDF[@]}
fi

if [ ! -z "$EVAL_DATA_SUFFIX" ]; then
  ALL_TOOLS_WITH_SUFFIX=()
  echo "adding data suffix ($EVAL_DATA_SUFFIX)..."
  for tool_name in $(echo $ALL_TOOLS | tr ',' ' '); do
    ALL_TOOLS_WITH_SUFFIX+=("$tool_name$EVAL_DATA_SUFFIX")
  done
  ALL_TOOLS=${ALL_TOOLS_WITH_SUFFIX[@]}
fi

ALL_TOOLS_CSV=$(echo $ALL_TOOLS | tr ' ' ',')
echo "ALL_TOOLS_CSV=$ALL_TOOLS_CSV"

BASE_REPORT_URL=$RESULTS_URL/evaluation-results/report$EVAL_DATA_SUFFIX
echo "BASE_REPORT_URL=$BASE_REPORT_URL"

gsutil_cp() {
  source="$1"
  target="$2"
  gsutil cp -P "$source" "$target"
  gsutil -m acl set -a public-read "$target"
}

if [[ $BASE_REPORT_URL =~ ^gs.* ]]; then
  echo "report url is gs"
  cp_cmd="gsutil_cp "
else
  echo "report url is not gs"
  mkdir -p "$BASE_REPORT_URL"
  cp_cmd="cp -a"
fi

kernel_name=$(jupyter kernelspec list --json | jq --raw-output '.kernelspecs | to_entries[] | .key' | sort -n | tail -1)
echo "kernel_name: $kernel_name"

convert_and_upload() {
  notebook_filename=$1
  report_name=$2
  title=$3

  temp_notebook_filename="/tmp/$title.ipynb"
  temp_html_filename="/tmp/$title.html"

  report_url="$BASE_REPORT_URL/$report_name"

  ls -l

  papermill "$notebook_filename" \
    "$temp_notebook_filename" \
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
    --execute "$temp_notebook_filename"

  echo "copying report html to $report_url"
  $cp_cmd "$temp_html_filename" "$report_url"
}

convert_and_upload \
  conversion-results-summary.ipynb \
  summary.html \
  "Conversion Summary - $(basename $DATA_URL)"

convert_and_upload \
  conversion-results-details.ipynb \
  details.html \
  "Conversion Details - $(basename $DATA_URL)"

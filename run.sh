#!/bin/bash

set -e

LIMIT=1000
RESUME=false
CASCADE=false
NUM_WORKERS=1

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"

  case $key in
    -d|--dataset)
      DATASET_NAME="$2"
      shift # past argument
      shift # past value
      ;;
    -t|--tool)
      CONVERSION_TOOL="$2"
      shift # past argument
      shift # past value
      ;;
    -l|--limit)
      LIMIT="$2"
      shift # past argument
      shift # past value
      ;;
    -w|--workers)
      NUM_WORKERS="$2"
      shift # past argument
      shift # past value
      ;;
    -r|--resume)
      RESUME=true
      shift # past argument
      ;;
    -c|--cascade)
      CASCADE=true
      shift # past argument
      ;;
    *)    # unknown option
      POSITIONAL+=("$1") # save it in an array for later
      shift # past argument
      ;;
  esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# echo DATASET_NAME = "${DATASET_NAME}"
# echo CONVERSION_TOOL = "${CONVERSION_TOOL}"
# echo POSITIONAL = "$@"

if [ -z "$DATASET_NAME" ]; then
  echo "dataset name required"
  exit 1
fi
if [ -z "$CONVERSION_TOOL" ]; then
  echo "conversion tool required"
  exit 1
fi


_setup_vars() {
  IS_PDF=true
  SUPPORTS_PDF=true
  SOURCE_FILE_COLUMN=source_url
  source "./config/datasets/$DATASET_NAME.sh"
  if [ "$CONVERSION_TOOL" != "all" ]; then
    source "./config/tools/$CONVERSION_TOOL.sh"
  fi
  source "./config/.config.sh"

  RESULTS_URL=$DATA_URL-results
  OUTPUT_FILE_LIST=file-list-$CONVERSION_TOOL.lst
}

evaluate() {
  _setup_vars
  if [ "$IS_PDF" == true ] && [ "$SUPPORTS_PDF" == false ]; then
    echo "tool does not support PDFs, exiting"
    exit 0
  fi
  (. ./scripts/evaluate.sh)
}

evaluation_report() {
  _setup_vars
  (. ./scripts/evaluation-report.sh)
}

get_output_file_list() {
  _setup_vars
  if [ "$IS_PDF" == true ] && [ "$SUPPORTS_PDF" == false ]; then
    echo "tool does not support PDFs, exiting"
    exit 0
  fi
  (. ./scripts/get-output-file-list.sh)
}

generate_file_list() {
  _setup_vars
  (. ./scripts/generate-file-list.sh)
}

convert() {
  _setup_vars
  if [ "$IS_PDF" == true ] && [ "$SUPPORTS_PDF" == false ]; then
    echo "tool does not support PDFs, exiting"
    exit 0
  fi
  echo "IS_PDF=$IS_PDF, SUPPORTS_PDF=$SUPPORTS_PDF"
  if [ "$RESUME" == true ]; then
    SCIENCEBEAM_ARGS="--resume $SCIENCEBEAM_ARGS"
  fi
  echo "pwd: $(pwd)"
  (. ./scripts/convert.sh)
  get_output_file_list
  if [ "$CASCADE" == true ]; then
    evaluate
  fi
}

case "$1" in 
    convert) convert ;;
    generate-file-list) generate_file_list ;;
    get-output-file-list) get_output_file_list ;;
    evaluate) evaluate ;;
    evaluation-report) evaluation_report ;;
    *) echo "usage: $0 convert|generate-file-list|get-output-file-list|evaluate|evaluation-report" >&2
       exit 1
       ;;
esac

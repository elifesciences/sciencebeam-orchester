#!/bin/bash

set -e

DATASETS=$(ls ./config/datasets | sort)
ALL_TOOLS=$(ls ./config/tools | sort)
FORCE=false
START_STOP_TOOL=true

DATASETS=$(for x in $DATASETS; do echo $(basename $x .sh); done)
ALL_TOOLS=$(for x in $ALL_TOOLS; do echo $(basename $x .sh); done)

TOOLS="$ALL_TOOLS"

RESUME=false
NUM_WORKERS=1

source "./config/.config.sh"

POSITIONAL=()
while [[ $# -gt 0 ]]; do
  key="$1"
  case $key in
    -d|--dataset)
      DATASETS="$2"
      shift # past argument
      shift # past value
      ;;
    -t|--tool)
      TOOLS="$2"
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
    -f|--force)
      FORCE=true
      shift # past argument
      ;;
    *)    # unknown option
      POSITIONAL+=("$1") # save it in an array for later
      shift # past argument
      ;;
  esac
done

set -- "${POSITIONAL[@]}" # restore positional parameters

echo "DATASETS: $(echo $DATASETS | tr '\n' ' ')"
echo "TOOLS: $(echo $TOOLS | tr '\n' ' ')"
echo "LIMIT: $LIMIT"
echo "NUM_WORKERS: $NUM_WORKERS"

mkdir -p logs
mkdir -p state

RUN_ARGS=""

if [ ! -z "$LIMIT" ]; then
  RUN_ARGS="--limit $LIMIT $RUN_ARGS"
fi

if [ "$RESUME" == true ]; then
  RUN_ARGS="--resume $RUN_ARGS"
fi

if [ ! -z "$NUM_WORKERS" ]; then
  RUN_ARGS="--workers $NUM_WORKERS $RUN_ARGS"
fi

task=$1

if [ -z "$1" ]; then
  task=convert
fi

if [ "$task" == "generate-file-list" ] || [ "$task" == "evaluation-report" ]; then
  export ALL_TOOLS
  TOOLS=all
fi

if [ "$task" != "convert" ]; then
  START_STOP_TOOL=false
fi

for dataset_name in $DATASETS; do
  for tool_name in $TOOLS; do
    done_filename=./state/$task-$dataset_name-$tool_name.done
    if [ "$FORCE" == false ] && [ -f $done_filename ]; then
      echo "already done (skipping): $dataset_name $tool_name"
    else
      log_file=logs/$task-$dataset_name-$tool_name.log
      echo "executing $task (dataset: $dataset_name, tool: $tool_name)"

      onerr() {
        echo ""
        echo "Tail of log file $log_file:"
        tail -20 $log_file
        echo ""
        echo "error executing $task (dataset: $dataset_name, tool: $tool_name) (see previous log files above)"
        exit -2
      }
      trap onerr ERR

      echo '' > $log_file

      _stop_tool() {
        ./start-stop-tool.sh stop $tool_name >> $log_file 2>&1
      }

      if [ "$START_STOP_TOOL" == true ]; then
        ./start-stop-tool.sh start $tool_name >> $log_file 2>&1

        trap _stop_tool EXIT
      fi

      ./run.sh --dataset $dataset_name --tool $tool_name $RUN_ARGS $task >> $log_file 2>&1

      if [ "$START_STOP_TOOL" == true ]; then
        _stop_tool
        trap - EXIT
      fi

      set -e

      touch $done_filename
    fi
  done
done

echo "done"

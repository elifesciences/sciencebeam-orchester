# ScienceBeam Orchester

## Configuration

An example configuration is provided in the _example-config_ directory. Please copy it to _config_.

### Datasets

Datasets describe where the data to be converted is coming from. In general it is describing a set of files.

Datasets are configured in: _./config/datasets_, each _.sh_ file describing one dataset.

### Tools

Tools are used to convert files. Currently they configure the ScienceBeam pipeline.

Tools are configured in: _./config/tools_, each _.sh_ file describing one tool.

## Run All

By default the corresponding container is started and stopped from within the _sciencebeam-orchester_ container.

```bash
docker-compose run --rm sciencebeam-orchester ./run-all.sh convert
```

For an invidual dataset and conversion tool:

```bash
docker-compose run --rm sciencebeam-orchester ./run-all.sh --dataset pmc-1943-cc-by-sample --tool grobid-tei --force convert
```

```bash
docker-compose run --rm sciencebeam-orchester ./run-all.sh evaluation-report
```

## Running individual containers

Build containers:

```bash
docker-compose up --no-start
```

Start:

```bash
docker-compose start sciencebeam-orchester
```

```bash
docker-compose start scienceparse-v2
```

```bash
docker-compose run --rm sciencebeam-orchester ./run.sh\
  --dataset pmc-1943 --tool scienceparse-v2 convert
```

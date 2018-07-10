ARG SCIENCEBEAM_TAG=latest

FROM elifesciences/sciencebeam:${SCIENCEBEAM_TAG}

WORKDIR /srv

RUN apt-get install unzip

ARG SCIENCEBEAM_JUDGE_TAG=develop
RUN echo "SCIENCEBEAM_JUDGE_TAG: $SCIENCEBEAM_JUDGE_TAG" && wget \
  --output-document sciencebeam-judge.zip \
  https://github.com/elifesciences/sciencebeam-judge/archive/${SCIENCEBEAM_JUDGE_TAG}.zip && \
  unzip sciencebeam-judge.zip -d . && \
  mv sciencebeam-judge-* sciencebeam-judge && \
  rm sciencebeam-judge.zip && \
  ls -l

WORKDIR /srv/sciencebeam-judge

RUN pip install -r requirements.txt
RUN pip install papermill
RUN pip install ipykernel && python -m ipykernel install --user
RUN apt-get install jq -y

RUN curl -sSL https://get.docker.com/ | sh && \
  pip install docker-compose

WORKDIR /srv/sciencebeam-orchester

COPY ./scripts ./scripts
COPY *.sh ./
RUN ls -l scripts/

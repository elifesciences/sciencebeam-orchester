ARG SCIENCEBEAM_COMMIT=latest

FROM elifesciences/sciencebeam:${SCIENCEBEAM_COMMIT}

WORKDIR /srv

RUN uname -a && \
  apt-get install -y lsb-release && \
  bash -c 'export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)"; \
    echo "CLOUD_SDK_REPO=$CLOUD_SDK_REPO"; \
    echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" | \
    tee -a /etc/apt/sources.list.d/google-cloud-sdk.list' && \
  curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
  apt-get update && \
  apt-get install -y unzip jq && \
  PYTHONUSERBASE="" \
  PATH=/usr/local/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
  apt-get install -y google-cloud-sdk && \
  curl -sSL https://get.docker.com/ | sh


ARG SCIENCEBEAM_JUDGE_COMMIT=develop
RUN echo "SCIENCEBEAM_JUDGE_COMMIT: $SCIENCEBEAM_JUDGE_COMMIT" && wget \
  --output-document sciencebeam-judge.zip \
  https://github.com/elifesciences/sciencebeam-judge/archive/${SCIENCEBEAM_JUDGE_COMMIT}.zip && \
  unzip sciencebeam-judge.zip -d . && \
  mv sciencebeam-judge-* sciencebeam-judge && \
  rm sciencebeam-judge.zip && \
  ls -l

WORKDIR /srv/sciencebeam-judge

RUN pip install -r requirements.txt

WORKDIR /srv/sciencebeam-orchester

COPY requirements.txt ./
RUN pip install -r requirements.txt
RUN pip install ipykernel==4.8.2 && python -m ipykernel install --user

COPY ./scripts ./scripts
COPY *.sh ./
RUN ls -l scripts/

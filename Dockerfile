FROM openjdk:11-jre-slim

ARG PRESTO_VERSION="364"
ARG MIRROR="https://repo1.maven.org/maven2/io/trino"
ARG PRESTO_BIN="${MIRROR}/trino-server/${PRESTO_VERSION}/trino-server-${PRESTO_VERSION}.tar.gz"
ARG PRESTO_CLI_BIN="${MIRROR}/trino-cli/${PRESTO_VERSION}/trino-cli-${PRESTO_VERSION}-executable.jar"

USER root

RUN apt-get update \
 && apt-get install -y --allow-unauthenticated \
      curl \
      wget \
      less \
      vim \
      python3 \
      python3-pip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/* \
 && ln -s /usr/bin/python3 /usr/bin/python \
 && pip3 install \
      jinja2

ENV PRESTO_HOME /presto
ENV PRESTO_USER presto
ENV PRESTO_DATA_DIR ${PRESTO_HOME}/data
ENV PRESTO_CONFIGS_DIR ${PRESTO_HOME}/etc/conf
ENV PRESTO_CATALOG_DIR ${PRESTO_HOME}/etc/catalog
ENV TEMPLATE_DIR ${PRESTO_HOME}/templates
ENV TEMPLATE_DEFAULT_DIR ${TEMPLATE_DIR}/default_conf
ENV TEMPLATE_CUSTOM_DIR ${TEMPLATE_DIR}/custom_conf
ENV TEMPLATE_CATALOG_DIR ${TEMPLATE_DIR}/catalog
ENV PATH $PATH:$PRESTO_HOME/bin

RUN useradd \
     --create-home \
     --home-dir ${PRESTO_HOME} \
     --shell /bin/bash \
     $PRESTO_USER \
 && mkdir -p $PRESTO_HOME \
 && wget  $PRESTO_BIN \
 && tar xzf trino-server-${PRESTO_VERSION}.tar.gz \
 && rm -rf trino-server-${PRESTO_VERSION}.tar.gz \
 && mv trino-server-${PRESTO_VERSION}/* $PRESTO_HOME \
 && rm -rf trino-server-${PRESTO_VERSION} \
 && mkdir -p ${PRESTO_CONFIGS_DIR} \
 && mkdir -p ${PRESTO_CATALOG_DIR} \
 && mkdir -p ${TEMPLATE_DIR} \
 && mkdir -p ${TEMPLATE_DEFAULT_DIR} \
 && mkdir -p ${TEMPLATE_CUSTOM_DIR} \
 && mkdir -p ${TEMPLATE_CATALOG_DIR} \
 && mkdir -p ${PRESTO_DATA_DIR} \
 && cd ${PRESTO_HOME}/bin \
 && wget  ${PRESTO_CLI_BIN} \
 && mv trino-cli-${PRESTO_VERSION}-executable.jar presto \
 && chmod +x presto \
 && chown -R ${PRESTO_USER}:${PRESTO_USER} ${PRESTO_HOME}

COPY template_configs ${TEMPLATE_DEFAULT_DIR}
COPY presto-entrypoint.py ${PRESTO_HOME}/presto-entrypoint.py

RUN chmod -R 755 ${TEMPLATE_DIR}

USER ${PRESTO_USER}
WORKDIR ${PRESTO_HOME}

EXPOSE 8080

CMD ["python3", "presto-entrypoint.py"]

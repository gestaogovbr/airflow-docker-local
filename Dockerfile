# VERSION 1.10.10
# DESCRIPTION: Basic Airflow container
# BUILD: docker build --rm -t docker-airflow-cginf-celery .
# SOURCE: https://github.com/puckel/docker-airflow

FROM python:3.7.7-slim-buster
LABEL maintainer="Puckel_"

# Never prompt the user for choices on installation/configuration of packages
ENV DEBIAN_FRONTEND noninteractive
ENV TERM linux

# Airflow
ARG AIRFLOW_VERSION=1.10.11
ARG AIRFLOW_USER_HOME=/usr/local/airflow
ARG AIRFLOW_DEPS=""
ARG PYTHON_DEPS=" \
    ctds==1.12.0 \
    tqdm==4.46.0 \
    ijson==3.0.4 \
    pysmb==1.2.6 \
    pyodbc==4.0.30 \
    xlrd==1.2.0 \
    docker==4.2.1 \
    pygsheets==2.0.3.1 \
    python-slugify==3.0.3 \
    lxml==4.5.1 \
    beautifulsoup4==4.9.1 \
    ipdb==0.13.3 \
    py-trello==0.17.1 \
    PyPDF2==1.26.0 \
    frictionless==4.2.1 \
    SQLAlchemy==1.3.23  \
    Flask-SQLAlchemy==2.4.4 \
    "

ENV AIRFLOW_HOME=${AIRFLOW_USER_HOME}

# Define pt_BR.
ENV LANGUAGE en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8
ENV LC_CTYPE en_US.UTF-8
ENV LC_MESSAGES en_US.UTF-8

# Disable noisy "Handling signal" log messages:
# ENV GUNICORN_CMD_ARGS --log-level WARNING

RUN set -ex \
    && buildDeps=' \
    libkrb5-dev \
    libsasl2-dev \
    libssl-dev \
    libffi-dev \
    libpq-dev \
    unzip \
    ' \
    && apt-get update -yqq \
    && apt-get upgrade -yqq \
    && apt-get install -yqq --no-install-recommends \
    $buildDeps \
    freetds-dev \
    unixodbc-dev \
    freetds-bin \
    build-essential \
    default-libmysqlclient-dev \
    apt-utils \
    curl \
    rsync \
    netcat \
    locales \
    vim \
    git \
    gnupg \
    apt-transport-https \
    && sed -i 's/^# en_US.UTF-8 UTF-8$/en_US.UTF-8 UTF-8/g' /etc/locale.gen \
    && sed -i 's/^# pt_BR.UTF-8 UTF-8$/pt_BR.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen en_US.UTF-8 pt_BR.UTF-8 \
    && update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8 \
    && useradd -ms /bin/bash -d ${AIRFLOW_USER_HOME} airflow \
    && pip install -U pip setuptools wheel \
    && pip install pytz \
    && pip install pyOpenSSL \
    && pip install ndg-httpsclient \
    && pip install pyasn1 \
    && pip install apache-airflow[crypto,celery,postgres,ssh,jdbc,mysql,mssql,samba,slack,google_auth${AIRFLOW_DEPS:+,}${AIRFLOW_DEPS}]==${AIRFLOW_VERSION} \
    # && pip install 'redis==3.2' \
    # && pip install 'Flask-AppBuilder==2.3.2' \
    && if [ -n "${PYTHON_DEPS}" ]; then pip install ${PYTHON_DEPS}; fi \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update -yqq \
    && ACCEPT_EULA=Y apt-get install -yqq msodbcsql17 \
    && sed -i 's,^\(MinProtocol[ ]*=\).*,\1'TLSv1.0',g' /etc/ssl/openssl.cnf \
    && sed -i 's,^\(CipherString[ ]*=\).*,\1'DEFAULT@SECLEVEL=1',g' /etc/ssl/openssl.cnf \
    && curl -O http://acraiz.icpbrasil.gov.br/credenciadas/CertificadosAC-ICP-Brasil/ACcompactado.zip \
    && unzip ACcompactado.zip -d /usr/local/share/ca-certificates/ \
    && update-ca-certificates \
    && apt-get purge --auto-remove -yqq $buildDeps \
    && apt-get autoremove -yqq --purge \
    && apt-get clean \
    && rm -rf \
    /var/lib/apt/lists/* \
    /tmp/* \
    /var/tmp/* \
    /usr/share/man \
    /usr/share/doc \
    /usr/share/doc-base

COPY script/entrypoint.sh /entrypoint.sh
COPY config/airflow.cfg ${AIRFLOW_USER_HOME}/airflow.cfg

# Instala dependências
COPY ./requirements.txt /requirements.txt
RUN pip install -r /requirements.txt

RUN chown -R airflow: ${AIRFLOW_USER_HOME}

EXPOSE 8080 5555 8793

USER airflow
WORKDIR ${AIRFLOW_USER_HOME}

ENTRYPOINT ["/entrypoint.sh"]
CMD ["webserver"]

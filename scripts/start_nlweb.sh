#!/bin/bash
set -e
set -x

DATABASE=deepnlp
POSTGRES_ROLE=deepnlp
DATABASE_URL="postgresql://${POSTGRES_ROLE}@localhost:5432/${DATABASE}"

SOLR_COLLECTION=deepnlp
SOLR_HOST=localhost
SOLR_PORT=8983
SOLR_URL=${SOLR_HOST}:${SOLR_PORT}
ZK_HOSTSTRING=localhost:9983

NLWEB_PORT=8080
NLWEB_URL=localhost:${NLWEB_PORT}
PDF_SERVER_PORT=8889
PDF_SERVER_HOST=localhost
TRANSFORM_JARS=/opt/sparkcognition/nlsak/ansible/jars/nltransform.jar,/opt/sparkcognition/nlsak/ansible/jars/gcs-connector-latest-hadoop2.jar
DATE_QUERY_CONFIG=/opt/sparkcognition/nlsak/nlweb/conf/date_query_config.txt

PYTHONPATH=/opt/sparkcognition/nlsak/dplugins

function export_nlweb_env_vars() {
    export APP_SETTINGS=${TEST_APP_SETTINGS:-"nlweb.config.DevelopmentConfig"}
    export SOLR_COLLECTION
    export SOLR_HOST
    export ZK_HOSTSTRING
    export PDF_SERVER_PORT
    export PDF_SERVER_HOST
    export DATABASE_URL
    export TRANSFORM_JARS
    export DATE_QUERY_CONFIG
    export ROUTES_PLUGIN_MODULES=aclass.routes,nlwordembeddings.routes
    export PYSPARK_GATEWAY_SECRET
    export SLOGGER_CONF=/opt/sparkcognition/logging.conf
    export PYTHONPATH
}

source /opt/sparkcognition/venv/bin/activate
#/opt/sparkcognition/nlsak/nlweb/bin/run_local -p ${NLWEB_PORT}
gunicorn --bind :${NLWEB_PORT} --threads 8 nlweb:app 
#!/bin/bash
set -e
set -x

DEEPNLP_FOLDER=/opt/sparkcognition/nlsak
ANSIBLE_FOLDER=${DEEPNLP_FOLDER}/ansible
ANSIBLE_MANIFEST=${ANSIBLE_FOLDER}/local_inventory.yml
ARTIFACTS_FOLDER=/opt/sparkcognition/artifacts
BASE_ARTIFACTS_FOLDER=/build
VIRTUAL_ENV_ACTIVATE=/opt/sparkcognition/venv/bin/activate

#---------------------------------------------------------------

function build_components() {
  local ofuscate_jars=$1
  echo "building components..."
  pushd ${DEEPNLP_FOLDER}
  source ${VIRTUAL_ENV_ACTIVATE}
  DEEP_OBFUSCATE=${ofuscate_jars} DEEP_BUILD_ARTIFACTS="no" ./build.sh
  # include ui tar if one is found in artifacts
  for file in `ls -t ${ARTIFACTS_FOLDER}/deepnlp_ui-dist*tar.gz 2> /dev/null` ; do
    local filename=$(basename ${file})
    echo "including ui file ${filename} in ansible tar..."
    cp ${file} ${ANSIBLE_FOLDER}/tarballs/.
    sed -i "s@\(\s*ui_dist_tarball\s*:\s*\).*@\1 \"${filename}\"@" ${ANSIBLE_MANIFEST}
    break
  done
  popd
}

function generate_ansible_artifact() {
  local prod_flag=$1
  echo "generating ansible artifact..."
  pushd ${DEEPNLP_FOLDER}
  #local timestamp=$(date +%Y-%m-%d)
  local git_sha=$(git rev-parse --short HEAD)
  local git_branch=$(git symbolic-ref HEAD | sed -e "s/^refs\/heads\///")
  git_branch=${git_branch// /_}
  git_branch=${git_branch//[^a-zA-Z0-9_]/}
  local tar_file=${ARTIFACTS_FOLDER}/deepnlp-ansible${prod_flag}-${git_branch}-${git_sha}.tar.gz
  tar -cvzf ${tar_file} ansible
  popd
  echo "ansible tar generated! ${tar_file}"
}

function copy_base_artifacts() {
  cp ${BASE_ARTIFACTS_FOLDER}/jq-1.5-1.el7.centos.x86_64.rpm ${ANSIBLE_FOLDER}/rpms/jq-1.5-1.el7.centos.x86_64.rpm
  cp ${BASE_ARTIFACTS_FOLDER}/zookeeper-3.4.10-1.x86_64.rpm ${ANSIBLE_FOLDER}/rpms/zookeeper-3.4.10-1.x86_64.rpm
  cp ${BASE_ARTIFACTS_FOLDER}/spark-2.3.1-bin-hadoop2.7.tgz ${ANSIBLE_FOLDER}/tarballs/spark-2.3.1-bin-hadoop2.7.tgz
  cp ${BASE_ARTIFACTS_FOLDER}/service-key.p12 ${ANSIBLE_FOLDER}/templates/etc/deepnlp/service-key.p12
  cp ${BASE_ARTIFACTS_FOLDER}/gcs-connector-latest-hadoop2.jar ${ANSIBLE_FOLDER}/jars/gcs-connector-latest-hadoop2.jar
  cp ${BASE_ARTIFACTS_FOLDER}/spark-solr-3.5.5-shaded.jar ${ANSIBLE_FOLDER}/jars/spark-solr-3.5.5-shaded.jar
  cp ${BASE_ARTIFACTS_FOLDER}/solr-7.4.0.tgz ${ANSIBLE_FOLDER}/tarballs/solr-7.4.0.tgz
  cp ${BASE_ARTIFACTS_FOLDER}/hdf5-1.10.4.tar.gz ${ANSIBLE_FOLDER}/tarballs/hdf5-1.10.4.tar.gz
  cp ${BASE_ARTIFACTS_FOLDER}/pytextrank-1.1.0-py3.6.egg ${ANSIBLE_FOLDER}/tarballs/pytextrank-1.1.0-py3.6.egg
}

function update_proguard_config() {
  pushd ${DEEPNLP_FOLDER}/conf
  local rt="-libraryjars /usr/lib/jvm/jre-1.8.0/lib/rt.jar"
  local jce="-libraryjars /usr/lib/jvm/jre-1.8.0/lib/jce.jar"
  local bad_avro='/.ivy2/cache/org.apache.avro/avro/jars/avro-1.8.0.jar'
  local good_avro='/.ivy2/cache/org.apache.avro/avro/bundles/avro-1.8.0.jar'
  local bad_tika='/.ivy2/cache/org.apache.tika/tika-core/jars/tika-core-1.14.jar'
  local good_tika='/.ivy2/cache/org.apache.tika/tika-core/bundles/tika-core-1.14.jar'

  sed -i "s@${bad_avro}@${good_avro}@g" options.pro
  sed -i "s@${bad_tika}@${good_tika}@g" options.pro

  for file in nlpdf.pro options.pro; do
    sed -i "s@-libraryjars .*rt.jar@${rt}@g" ${file}
    sed -i "s@-libraryjars .*jce.jar@${jce}@g" ${file}
    sed -i "s@/Users/jbronson@/root@g" ${file}
    sed -i "s@/Users/sparkdemo@/root@g" ${file}
  done
  popd
}

function clean() {
  echo "cleaning up ansible artifacts"
  for folder in eggs rpms tarballs jars; do
    rm -rf ${ANSIBLE_FOLDER}/${folder}
    mkdir -p ${ANSIBLE_FOLDER}/${folder}
  done
}

#---------------------------------------------------------------

if [ ! -d ${DEEPNLP_FOLDER} ] ; then
	echo "ERROR: could not find deepnlp source folder"
	exit 1
fi

case "$1" in
  "ansible")
    clean
    copy_base_artifacts
    build_components "no"
    generate_ansible_artifact ""
    ;;
  "ansible-prod")
    clean
    copy_base_artifacts
    update_proguard_config
    build_components "yes"
    generate_ansible_artifact "-prod"
    ;;
  *)
    echo "Unknown option <$1>. Please tell me what to do :/"
    exit 1
    ;;
esac

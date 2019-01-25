#!/bin/bash
set -e
set -x

DEEPNLP_UI_FOLDER=/opt/sparkcognition/deepnlp-ui/
ARTIFACTS_FOLDER=/opt/sparkcognition/artifacts
EVER_BUILT_MAKER_FILE=${ARTIFACTS_FOLDER}/.deepnlp_ui_built

#---------------------------------------------------------------

function clean() {
	pushd ${DEEPNLP_UI_FOLDER}
	rm -rf node_modules package-lock.json yarn.lock
	rm -rf dist/* ${EVER_BUILT_MAKER_FILE}
	popd
}

function build() {
	echo "building deepnlp-ui artifacts..."
	clean
	pushd ${DEEPNLP_UI_FOLDER}
	yarn install || exit 1
	yarn build || exit 1
	touch ${EVER_BUILT_MAKER_FILE}
	popd
}

function generate_artifact() {
	pushd ${DEEPNLP_UI_FOLDER}
	local git_sha=$(git rev-parse --short HEAD)
	local git_branch=$(git symbolic-ref HEAD | sed -e "s/^refs\/heads\///")
	local tar_file=${ARTIFACTS_FOLDER}/deepnlp_ui-dist-${git_branch}-${git_sha}.tar.gz
	tar -cvzf ${tar_file} dist
	popd
}

function run() {
	pushd ${DEEPNLP_UI_FOLDER}
	if [ ! -f ${EVER_BUILT_MAKER_FILE} ]; then
		build
	fi
	echo "starting deepnlp-ui..."
	/usr/bin/yarn serve
	popd
}


function node_env() {
	NVM_DIR="$HOME/.nvm"
	[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
}


#---------------------------------------------------------------


if [ ! -d ${DEEPNLP_UI_FOLDER} ] || [ ! -d ${DEEPNLP_UI_FOLDER}/src ] ; then
	echo "ERROR: could not find deepnlp-ui source folder"
	exit 1
fi

case "$1" in
  "build")
	node_env
    build
    generate_artifact
    ;;
  "run")
	node_env
	run
    ;;
  "clean")
	clean
    ;;
  *)
    echo "Unknown option <$1>. Please tell me what to do :/"
    exit 1
    ;;
esac


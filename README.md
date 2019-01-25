# DeepNLP Harness Tool

The purpose of this tool is to simplify the process of running and building artifacts for the DeepNLP User Interface. In a near future, it will allow to build and hopefully run the DeepNLP backend as well.


## Requirements
* docker-compose
* make

## Installation
- Clone this repo
- Clone the `deepnlp-ui` repo in the `deepnlp-harness/src` folder. Check-out the branch you would like to work on
- Go back to the `deepnlp-harness` top folder and run any of the following options:
	- `make build` builds a clean docker image and generates a `dist` artifact that can be deployed on `nginx`. The `dist` artifact is tar'ed in the `artifacts` folder as `deepnlp_ui-dist-${git_branch}-${git_sha}.tar.gz`
	- `make run` runs the DeepNLP UI in docker-compose. If `make build` has not been previously run, it will call it
	- `make clean` removes the following files from your source folder:
		- deepnlp-ui/dist
		- node_modules
		- package-lock.json
		- yarn.lock
		After a `make clean`, `make build` will need to be run in order to re-generate the above files

## Running DeepNLP UI
- Setup the address of the backend the UI is going to talk to. To do so, edit `src/deepnlp-ui/src/environments/environment.ts` as usual. Bear in mind that the UI is running inside docker, so `localhost` will refer to the container itself. In most cases the ip will be the ip docker is running on.
- Run `make run` 
- The UI should become available on port `5001`

## Port-forwarding to GCP VMs
To get your UI to talk to a VM in GCP:
	- Add your local machine's ip (*not `localhost`*) in `src/deepnlp-ui/src/environments/environment.ts`
	- Include your local machine's ip in the `gcloud ssh command`
		Example: `--ssh-flag="-L YOUR_MACHINE'S_IP:8080:localhost:8080"`

- Setup the address of the backend the UI is going to talk to. To do so, edit 

## Notes:
- During the build/clean process, the following files will be removed/updated from your source folder:
	- deepnlp-ui/dist
	- node_modules
	- package-lock.json
	- yarn.lock
	Once the build succeeds, new versions of the above files will be available
- The harness mounts your `src/deepnlp-ui` folder in the container. Any changes made locally or in the container will be reflected in your source (ie. node_modules, yarn.lock etc)
- `make build` only needs to be run the first time and then whenever `packages.json` or the version of `yarn` or `node` changes. changes



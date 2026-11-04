# CI/CD Final Project: Counter Service

This project automates linting, testing, image building, and deployment for a
Python Flask counter API. It is based on the
[IBM Skills Network starter project](https://github.com/ibm-developer-skills-network/vselh-ci-cd-final-project-template)
for the Coursera Continuous Integration and Continuous Delivery final project.

## Application

The API provides a health endpoint and routes to create, list, read, increment,
and delete named counters. The Flask application lives in `service/`; the nine
supplied unit tests live in `tests/`.

## Continuous integration

`.github/workflows/workflow.yml` runs on pushes and pull requests to `main`.
It installs the Python 3.9 dependencies, checks the code with flake8, and runs
the unit tests with nose. Each step must pass for the job to succeed.

## OpenShift pipeline

`.tekton/tasks.yml` defines cleanup, flake8 lint, and nose test tasks.
`.tekton/pipeline.yml` connects those tasks to the cluster's `git-clone`,
`buildah`, and `openshift-client` tasks. `.tekton/pvc.yml` defines the shared
workspace used by the pipeline. The lab's OpenShift cluster is needed to apply
and run these resources.

The pipeline accepts a Git repository URL and an image destination as
parameters. This repository is public so the lab's `git-clone` task can fetch it.
No credentials are stored in the repository.

After cloning the repository in the course Cloud IDE, run:

```bash
bash bin/run-lab-pipeline.sh
```

The script applies the Task, PVC, and Pipeline resources, runs the pipeline,
checks the deployment and route, and prints the application's logs. Its output
and the OpenShift console provide the evidence requested by the assignment.

## Run locally or in the lab IDE

Use Python 3.9, then install dependencies and run the same checks as CI:

```bash
python3.9 -m venv .venv
source .venv/bin/activate
python -m pip install -r requirements.txt
flake8 service tests
nosetests -v
```

In the course lab, `bash bin/setup.sh` installs its Python environment. The
OpenShift pipeline must be run in that lab to collect the PVC, pipeline, run,
and application-log evidence requested by the assignment.

## License

The starter application is licensed under Apache 2.0. See [LICENSE](LICENSE).

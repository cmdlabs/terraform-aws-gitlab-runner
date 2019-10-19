# Examples

## Create a CI/CD runner in GitLab

### Obtain a Registration Token for a test project

See the GitLab docs [here](https://docs.gitlab.com/ee/ci/runners/#registering-a-specific-runner-with-a-project-registration-token):

- Go to the project in GitLab e.g. https://gitlab.com/alexharv074/test
- On the left hand side select Settings > CI/CD
- Under Runners Expand

The registration token can be found from here.

Put it in a tfvars file or set an environment variable:

```text
▶ export TF_VAR_registration_token=XXXXXXXXX
```

### Add a .gitlab-ci.yml to the project

Create a simple `.gitlab-ci.yml` file e.g.

```yaml
---
image: busybox:latest

build1:
  stage: build
  script:
    - echo "hello world"
```

## Launch the CI Runner

```text
▶ cd ./runner_default
▶ terraform init
▶ terraform apply
```

## Run the job in GitLab

A spot instance will be created to run the job.

## Tear down the CI Runner

Tear down:

```text
▶ terraform destroy
```

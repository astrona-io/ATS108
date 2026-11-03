# Authenticating The Pipeline

A Perses server in production does not accept anonymous changes. A pipeline that applies dashboards must prove who it is, and it must do so without a password written into the script or the repository. This part reads how the pipeline logs in today, lists the two ways `percli` authenticates, and shows how a Kubernetes Secret gives the credentials to the Job.

## How the pipeline logs in today

The pipeline script runs `percli login` once, right after the clone. Print the line:

<!-- astrona:playground:renew -->

```sh
kubectl -n dac get configmap dashboards-pipeline -o jsonpath='{.data.pipeline\.sh}' | grep -n "login"
```

The command is `percli login "$PERSES_URL"`, with only the address. When the server has authentication off, this command only stores the address in the `percli` configuration file, `~/.perses/config.json`, so that later commands know which server to talk to.

## Two ways to authenticate

When authentication is on, `percli login` takes credentials. With `--username` and `--password`, it logs in as a user with a password and stores the token the server returns. With `--token`, it uses an access token that you already have. A pipeline normally uses a dedicated user or a service token, never a person's account, so that the account has only the permissions a pipeline needs and can be removed on its own.

Check the options in the runner:

```sh
dac() { kubectl -n dac exec -i deploy/dac-runner -- dac-run "$@"; }
dac percli login --help
```

The help text lists the flags, including the username, the password and the token.

## Give the credentials to the Job

A password in `pipeline.sh` would be readable by everyone who can read the ConfigMap, and it would be in the review history. A Kubernetes Secret keeps it separate, and the Job reads it into environment variables. Create a Secret as a stand-in:

```sh
kubectl -n dac create secret generic perses-login --from-literal=username=pipeline --from-literal=password=not-used-here
kubectl -n dac get secret perses-login -o jsonpath='{.data.username}' | base64 -d
```

The second command prints the user name. In the CronJob, each variable is declared with `valueFrom.secretKeyRef`, naming the Secret and the key. The script then logs in with `percli login "$PERSES_URL" --username "$PERSES_USER" --password "$PERSES_PASSWORD"`. This lab server has authentication off, so the playground pipeline does not use the Secret, and you can leave the Secret in place.

The log of the run must never print the password. The `set -x` option of the shell prints every command with its values, so a pipeline that handles credentials does not use it.

You now know how a pipeline authenticates and where its credentials come from. The open question is how the same pipeline can check a commit without applying it.

## Common pitfalls

> [!WARNING]
> - **Writing the password in the script or the repository.** Use a Secret.
> - **Logging in with a person's account.** Use a dedicated user or token.
> - **Using `set -x` in a script that handles a password.** It prints the values to the log.

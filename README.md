# Canister Monitoring with Prometheus

This is an example project to show how to monitor a canister written in Motoko using Prometheus.
The canister exposes a `/metrics` HTTP endpoint that encodes important metrics in a text based format Prometheus understands.
You can customize the metrics in the metrics function.

The Prometheus configuration can be adapted by changing the configuration files in the `prometheus` folder.
In particular you can change the [alert.yml](./prometheus/alert.yml) to create customized alerts.

## Requirements

- [Docker](https://docs.docker.com/get-docker/) 

## Usage

```bash
docker compose up
```

The Prometheus user interface will be available at `https://localhost:9000`.

If you make changes run `docker compose build` before `docker compose up`.

### Authorization
This example uses an API key to control access to the metrics endpoint. 

## Troubleshooting

If you're running this on a M1 Mac you might need to run `DOCKER_DEFAULT_PLATFORM=linux/amd64 docker-compose up`.

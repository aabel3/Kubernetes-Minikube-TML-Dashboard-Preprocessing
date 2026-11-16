# ✅ Verification

Each check below lists the command, the expected output (taken from the project screenshots) and the matching screenshot. The captures are from 8 July 2025.

---

## Preprocess types in the code

`preprocesslogic='MIN,MAX,COUNT,VARIANCE,OUTLIERS,ANOMPROB'` is set in `iotsolution-scripts-data/preprocess-iot-monitor-customdata.py` in the GitHub repository.

Screenshot: [GitHub file view](../screenshots/01-preprocess-types-in-github.png)

---

## Docker Hub

The repository `<dockerhub-username>/seneca-iot-tml-kafka-amd64_modification` shows a `latest` tag for `linux/amd64`, about 4.15 GB, with the pull command `docker pull <dockerhub-username>/seneca-iot-tml-kafka-amd64_modification:latest`.

Screenshot: [Docker Hub tags](../screenshots/07-docker-hub-modification-repository.png)

---

## Docker run and inspection

```bash
docker run -p 9005:9005 <dockerhub-username>/seneca-iot-tml-kafka-amd64_modification
```

```
Stopping MariaDB database server: mariadbd.
Starting MariaDB database server: mariadbd.
```

`docker ps` shows the container `Up` with `0.0.0.0:9005->9005/tcp, :::9005->9005/tcp`.

Screenshots: [docker run](../screenshots/09-docker-run-modified-image.png) · [docker ps](../screenshots/10-docker-ps.png)

Inside the container, `ls` shows `Hpde`, `IotSolution`, `Kafka`, `Viper-preprocess`, `Viper-preprocess2`, `Viper-produce`, `Viperviz` and the usual system folders, and `tmux ls` lists nine sessions:

```
kafka, preprocess-data-python-8001, preprocess-data-viper-8001,
preprocess2-data-python-8002, preprocess2-data-viper-8002,
produce-iot-data-python-8000, produce-iot-data-viper-8000,
visualization-viperviz-9005, zookeeper
```

Screenshot: [exec, ls and tmux ls](../screenshots/11-docker-exec-ls-tmux-ls.png)

---

## Kubernetes

### Folder and YAML

The `kubernetes` folder holds `kubectl`, `minikube`, `minikube-linux-amd64` and `senecaiot.yml`. The YAML sets `name: seneca-iot-deployment`, `replicas: 1`, `hostNetwork: true`, the modified image and `containerPort`/`hostPort` 9005.

Screenshots: [Folder](../screenshots/03-kubernetes-folder-contents.png) · [senecaiot.yml](../screenshots/02-senecaiot-yml-deployment.png)

### minikube

```bash
minikube start --driver=docker
```

```
😄  minikube v1.36.0 on Ubuntu 25.04
✨  Using the docker driver based on existing profile
🏄  Done! kubectl is now configured to use "minikube" cluster and "default" namespace by default
```

A warning that `kubectl` is version 1.31.0 against Kubernetes 1.33.1 is expected here and does not stop the cluster.

Screenshot: [minikube start](../screenshots/04-minikube-start.png)

### Deployment and pod

```bash
kubectl apply -f senecaiot.yml
kubectl get pods
```

```
deployment.apps/seneca-iot-deployment unchanged
NAME                                     READY   STATUS    RESTARTS   AGE
seneca-iot-deployment-844444b687-c5dlz   1/1     Running   ...
```

Screenshots: [kubectl apply](../screenshots/05-kubectl-apply.png) · [get pods and port-forward](../screenshots/06-kubectl-get-pods-port-forward.png)

### Port forward

```bash
kubectl port-forward seneca-iot-deployment-844444b687-c5dlz 9005:9005
```

```
Forwarding from 127.0.0.1:9005 -> 9005
Forwarding from [::1]:9005 -> 9005
Handling connection for 9005
```

Screenshot: [get pods and port-forward](../screenshots/06-kubectl-get-pods-port-forward.png)

---

## Dashboard

Browse to the dashboard URL and press **START STREAMING**. The table lists each stream with its **Process Type**, current value, total messages and Kafka key. The capture shows the Process Type column outlined in red.

Screenshot: [Dashboard table](../screenshots/08-dashboard-process-type-table.png)

---

## tmux

```bash
tmux a -t visualization-viperviz-9005
```

The window shows the Viperviz banner, the Kafka connection messages and the line `VIPERviz is running (HTTP) on Linux (amd64) and Listening on 0.0.0.0 port 9005`.

Press `Ctrl+b`, then `d`:

```
[detached (from session visualization-viperviz-9005)]
```

Then `exit` returns to the VM prompt.

Screenshots: [Viperviz session](../screenshots/12-tmux-attach-viperviz-9005.png) · [Detach and exit](../screenshots/13-tmux-detach-and-exit-container.png)

# ⚙️ Setup Guide

Step-by-step instructions to rebuild the Kubernetes TML dashboard lab.

> Components and ports are in [architecture.md](architecture.md). Every step has a matching helper in [`scripts/`](../scripts/).

---

## 1. Before you start

- An Ubuntu VM with Docker installed and your user able to run it:

  ```bash
  sudo apt-get install docker.io
  sudo chmod 666 /var/run/docker.sock
  ```

- A Docker Hub account (`<dockerhub-username>` below).
- The `raspberrypi` repository imported into your GitHub account:
  1. Create an empty repository called `raspberrypi` (do not add a README).
  2. Use **Import code from another repository** with `https://github.com/smaurice101/raspberrypi.git`, then press **Begin Import**.

---

## 2. Modify the preprocess types

1. In your `raspberrypi` repository open `iotsolution-scripts-data/preprocess-iot-monitor-customdata.py`.
2. Find the `preprocesslogic` line (line 205 in the upstream file) and change it to:

   ```python
   preprocesslogic='MIN,MAX,COUNT,VARIANCE,OUTLIERS,ANOMPROB'
   ```

3. Commit the change. See [`configs/preprocess-types.snippet`](../configs/preprocess-types.snippet) and [screenshot 1](../screenshots/01-preprocess-types-in-github.png).

---

## 3. Build and push the modified container

Helper: [`scripts/build-container.bash`](../scripts/build-container.bash)

1. Copy the [Dockerfile](https://github.com/smaurice101/raspberrypi/blob/main/docker/Dockerfile) into an empty folder on the VM.
2. Build with `_modification` added to the container name (about 20 minutes, from scratch):

   ```bash
   docker build -t <dockerhub-username>/seneca-iot-tml-kafka-amd64_modification \
     --build-arg CHIP=AMD64 --no-cache --network=host .
   ```

3. Log in and push:

   ```bash
   docker login
   docker push <dockerhub-username>/seneca-iot-tml-kafka-amd64_modification
   ```

4. Check the repository on Docker Hub. It shows the `latest` tag and the pull command `docker pull <dockerhub-username>/seneca-iot-tml-kafka-amd64_modification:latest`.

---

## 4. Run the modified container with Docker

```bash
docker run -p 9005:9005 <dockerhub-username>/seneca-iot-tml-kafka-amd64_modification
```

`-p 9005:9005` forwards host port 9005 to container port 9005, and MariaDB starts first. Open the dashboard and press **START STREAMING**:

```
http://localhost:9005/iot-failure-seneca.html?topic=iot-preprocess2,iot-preprocess&offset=-1&groupid=&rollbackoffset=500&topictype=prediction&append=0&secure=1
```

Wait a few minutes for data to populate, and look at the **Process Type** column of the table. Stop the container with `Ctrl+C` before using Kubernetes, because both want port 9005.

---

## 5. Install minikube and kubectl

Helper: [`scripts/install-kubernetes-tools.bash`](../scripts/install-kubernetes-tools.bash)

1. Create the working folder:

   ```bash
   mkdir kubernetes
   cd kubernetes
   ```

2. Install minikube, a one-node Kubernetes cluster with the same functionality as a production cluster:

   ```bash
   wget https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64
   sudo install minikube-linux-amd64 /usr/local/bin/minikube
   ```

3. Install kubectl:

   ```bash
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   sudo chmod +x kubectl
   sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
   ```

4. Download the upstream [`kubernetes/yaml`](https://github.com/smaurice101/raspberrypi/blob/main/kubernetes/yaml) file into the folder as `senecaiot.yml`, or copy [`configs/senecaiot.yml`](../configs/senecaiot.yml). Set line 18 to your image:

   ```yaml
   image: <dockerhub-username>/seneca-iot-tml-kafka-amd64_modification
   ```

5. The folder now holds `kubectl`, `minikube-linux-amd64` and `senecaiot.yml` ([screenshot 3](../screenshots/03-kubernetes-folder-contents.png)).

---

## 5a. Note on the kubectl download

The report and the assignment sheet use the older `storage.googleapis.com/kubernetes-release` address for kubectl. This repo uses the official `dl.k8s.io` address, which always returns the current stable release.

---

## 6. Start the cluster and create the pod

Helper: [`scripts/deploy-to-kubernetes.bash`](../scripts/deploy-to-kubernetes.bash)

```bash
minikube start --driver=docker
kubectl apply -f senecaiot.yml
kubectl get pods
```

If Docker permission errors appear, run `sudo chmod 666 /var/run/docker.sock` and start minikube again. The pod is ready when `READY` shows `1/1` and `STATUS` shows `Running`.

---

## 7. Forward port 9005

```bash
kubectl port-forward <pod-name> 9005:9005
```

Use the pod name from `kubectl get pods`, for example `seneca-iot-deployment-844444b687-c5dlz`. The command prints:

```
Forwarding from 127.0.0.1:9005 -> 9005
Forwarding from [::1]:9005 -> 9005
```

Leave it running, open the dashboard URL from step 4 and press **START STREAMING**. The terminal prints `Handling connection for 9005` as the page loads.

---

## 8. Inspect the running container

Open a new terminal.

```bash
kubectl exec -it <pod-name> -- bash     # or: docker exec -it <container-id> bash
ls
tmux ls
tmux a -t visualization-viperviz-9005
```

Detach with `Ctrl+b`, then `d`, and leave the container with `exit`.

---

## 9. Verify

[`scripts/verify-kubernetes.bash`](../scripts/verify-kubernetes.bash) checks the cluster, the pod, the forwarded port and the tmux sessions. Expected output for every check is in [verification.md](verification.md).

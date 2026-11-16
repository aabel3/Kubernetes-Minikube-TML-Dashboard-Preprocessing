# 📝 Submission Summary

## Overview

This project extends the Docker TML dashboard lab. The preprocessing script is modified to apply six preprocess types, the container is rebuilt and pushed to Docker Hub as a `_modification` image, and it is deployed on a minikube Kubernetes cluster with the dashboard reached through `kubectl port-forward`.

## Expectations

- Change `preprocesslogic` to `MIN,MAX,COUNT,VARIANCE,OUTLIERS,ANOMPROB` and commit it
- Build a container with `_modification` in its name and push it to Docker Hub
- Show the Docker pull command and the Docker Hub repository
- Show the dashboard with the Process Type column in the table
- Install minikube and kubectl and run the container in Kubernetes with `senecaiot.yml`
- Forward port 9005 to the pod and open the dashboard
- Go inside the container, list the tmux sessions, attach to the visualization session, then detach and exit
- Explain what the preprocess types do and why preprocessing matters

## Approach

1. Edit and commit the preprocessing script.
2. Build and push the modified image.
3. Run it with Docker and check the dashboard.
4. Install minikube and kubectl, set the image in `senecaiot.yml`, start the cluster and apply the Deployment.
5. Forward port 9005 and view the dashboard.
6. Inspect the container with `exec`, `tmux ls`, `tmux a` and `exit`.

## Deliverables

| Deliverable | Location |
|-------------|----------|
| Preprocess type change | [`configs/preprocess-types.snippet`](../configs/preprocess-types.snippet), [`screenshots/01`](../screenshots/01-preprocess-types-in-github.png) |
| Docker pull command and Docker Hub repository | [`docs/setup.md`](setup.md), [`screenshots/07`](../screenshots/07-docker-hub-modification-repository.png) |
| Kubernetes Deployment | [`configs/senecaiot.yml`](../configs/senecaiot.yml), [`screenshots/02`](../screenshots/02-senecaiot-yml-deployment.png) |
| minikube, apply, pods, port-forward | [`screenshots/03`](../screenshots/03-kubernetes-folder-contents.png) – [`screenshots/06`](../screenshots/06-kubectl-get-pods-port-forward.png) |
| Dashboard with the Process Type column | [`screenshots/08`](../screenshots/08-dashboard-process-type-table.png) |
| `docker run`, `docker ps`, `docker exec`, `tmux ls` | [`screenshots/09`](../screenshots/09-docker-run-modified-image.png) – [`screenshots/11`](../screenshots/11-docker-exec-ls-tmux-ls.png) |
| Viperviz session, detach and exit | [`screenshots/12`](../screenshots/12-tmux-attach-viperviz-9005.png), [`screenshots/13`](../screenshots/13-tmux-detach-and-exit-container.png) |
| Preprocessing explanation | [`docs/preprocessing.md`](preprocessing.md) |

## Conclusion

The TML solution was modified to apply six preprocess types, rebuilt and published to Docker Hub, and deployed on a minikube cluster. Port 9005 was forwarded to the pod so the dashboard ran in the browser, and the container's tmux sessions were inspected from the inside. The project gave hands-on practice with Kubernetes Deployments and pods, minikube, kubectl, port forwarding and Docker Hub.

## References

- [Docker Hub](https://hub.docker.com/)
- [smaurice101/raspberrypi – docker folder](https://github.com/smaurice101/raspberrypi/tree/main/docker)
- [smaurice101/raspberrypi – repository](https://github.com/smaurice101/raspberrypi)
- [smaurice101/raspberrypi – Dockerfile](https://github.com/smaurice101/raspberrypi/blob/main/docker/Dockerfile)
- [minikube documentation](https://minikube.sigs.k8s.io/docs/)
- [Install and set up kubectl on Linux](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)

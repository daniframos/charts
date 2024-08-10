versao

helm package .\grafana\ --version 0.0.1
helm package .\nexus\ --version 0.0.1
helm package .\openshift-proxmox-csi-plugin\ --version 0.0.1
helm package .\prometheus\ --version 0.0.1

helm repo index --merge index.yaml .
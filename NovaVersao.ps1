function Nova-Versao([string]$versao) {
    Invoke-Expression -Command "helm package .\grafana\ --version $versao"
    Invoke-Expression -Command "helm package .\nexus\ --version $versao"
    Invoke-Expression -Command "helm package .\openshift-proxmox-csi-plugin\ --version $versao"
    Invoke-Expression -Command "helm package .\prometheus\ --version $versao"
    Invoke-Expression -Command "helm repo index --merge index.yaml ."
}
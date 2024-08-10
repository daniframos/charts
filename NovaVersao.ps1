# Chama a função automaticamente se o script for executado com o parâmetro versao
param (
    [string]$versao
)

if ($versao) {
    Nova-Versao -versao $versao
}

function Nova-Versao([string]$versao) {
    helm package .\grafana\ --version $versao
    helm package .\nexus\ --version $versao
    helm package .\openshift-proxmox-csi-plugin\ --version $versao
    helm package .\prometheus\ --version $versao
    helm repo index --merge index.yaml .
}

# Charts Helm

Repositório com charts Helm usados para publicar aplicações e componentes de infraestrutura em ambiente OpenShift com integração de storage no Proxmox.

## Estrutura

Este repositório mantém:

- os diretórios-fonte dos charts Helm;
- os pacotes `.tgz` já gerados;
- o arquivo [`index.yaml`](/C:/GT/charts/index.yaml), usado como índice de repositório Helm;
- o script [`NovaVersao.ps1`](/C:/GT/charts/NovaVersao.ps1), usado para empacotar novas versões.

## Charts disponíveis

| Chart | Descrição | Versão atual | Objetivo |
| --- | --- | --- | --- |
| `grafana` | Chart para Grafana | `0.0.1` | Deploy do Grafana com PVC e Route no OpenShift |
| `prometheus` | Chart básico para Prometheus | `0.0.1` | Deploy do Prometheus com PVC e Route no OpenShift |
| `nexus` | Chart para Nexus com storage no Proxmox | `0.0.1` | Deploy do Nexus com persistência e rotas para gestão e Docker |
| `openshift-proxmox-csi-plugin` | CSI plugin para Proxmox + OpenShift | `0.0.1` | Provisionamento de volumes via Proxmox CSI |

## Pré-requisitos

- Helm 3 instalado
- Acesso a um cluster Kubernetes/OpenShift
- Permissão para criar recursos como `Deployment`, `Service`, `PVC`, `Route`, `Secret`, `StorageClass` e RBAC

Para o chart `openshift-proxmox-csi-plugin`, também é necessário:

- acesso ao ambiente Proxmox;
- credenciais válidas para API do Proxmox;
- configuração correta de `StorageClass` e segredo com a configuração do cluster.

## Instalação

### Instalar a partir do repositório local

Adicione o repositório Helm apontando para a pasta publicada:

```powershell
helm repo add local-charts <URL_DO_REPOSITORIO>
helm repo update
```

Instale um chart:

```powershell
helm install meu-grafana local-charts/grafana
helm install meu-prometheus local-charts/prometheus
helm install meu-nexus local-charts/nexus
helm install proxmox-csi local-charts/openshift-proxmox-csi-plugin
```

### Instalar a partir do código-fonte

```powershell
helm install meu-grafana .\grafana\
helm install meu-prometheus .\prometheus\
helm install meu-nexus .\nexus\
helm install proxmox-csi .\openshift-proxmox-csi-plugin\
```

## Configurações principais

### `grafana`

Principais valores em [`grafana/values.yaml`](/C:/GT/charts/grafana/values.yaml):

- imagem: `grafana/grafana:11.1.1`
- porta: `3000`
- armazenamento: `10Gi`
- `storageClass`: `proxmox-data-xfs`
- domínio OpenShift: `apps.ocp.dani.framos.nom.br`

Exemplo:

```powershell
helm install meu-grafana .\grafana\ `
  --set storage.size=20Gi `
  --set storage.storageClass=minha-storage-class `
  --set openshift.dominio=apps.exemplo.com
```

### `prometheus`

Principais valores em [`prometheus/values.yaml`](/C:/GT/charts/prometheus/values.yaml):

- imagem: `prom/prometheus:v2.43.0`
- porta: `9090`
- armazenamento: `10Gi`
- `storageClass`: `proxmox-data-xfs`
- domínio OpenShift: `apps.ocp.dani.framos.nom.br`

Exemplo:

```powershell
helm install meu-prometheus .\prometheus\ `
  --set storage.size=50Gi `
  --set openshift.dominio=apps.exemplo.com
```

### `nexus`

Principais valores em [`nexus/values.yaml`](/C:/GT/charts/nexus/values.yaml):

- imagem: `sonatype/nexus3:3.71.0-ubi`
- porta da aplicação: `8081`
- porta Docker: `8082`
- armazenamento: `10Gi`
- `storageClass`: `proxmox-data-xfs`
- domínio OpenShift: `apps.ocp.dani.framos.nom.br`

Exemplo:

```powershell
helm install meu-nexus .\nexus\ `
  --set storage.size=100Gi `
  --set openshift.dominio=apps.exemplo.com
```

### `openshift-proxmox-csi-plugin`

Principais valores em [`openshift-proxmox-csi-plugin/values.yaml`](/C:/GT/charts/openshift-proxmox-csi-plugin/values.yaml):

- `createNamespace`
- `existingConfigSecret`
- `existingConfigSecretKey`
- `config.clusters`
- `storageClass`
- imagens dos componentes controller e node

Exemplo mínimo usando segredo já existente:

```powershell
helm install proxmox-csi .\openshift-proxmox-csi-plugin\ `
  --set existingConfigSecret=proxmox-csi-secret `
  --set createNamespace=true
```

Se for usar `config.clusters` e `storageClass`, o ideal é fornecer um arquivo de valores separado:

```powershell
helm install proxmox-csi .\openshift-proxmox-csi-plugin\ -f .\meus-valores-csi.yaml
```

## Atualização de versões

O script [`NovaVersao.ps1`](/C:/GT/charts/NovaVersao.ps1) empacota todos os charts e atualiza o índice do repositório.

Uso:

```powershell
.\NovaVersao.ps1 -versao 0.0.2
```

Esse comando executa:

```powershell
helm package .\grafana\ --version 0.0.2
helm package .\nexus\ --version 0.0.2
helm package .\openshift-proxmox-csi-plugin\ --version 0.0.2
helm package .\prometheus\ --version 0.0.2
helm repo index --merge index.yaml .
```

## Publicação

Depois de gerar uma nova versão:

1. valide os arquivos `.tgz` criados;
2. confirme a atualização do [`index.yaml`](/C:/GT/charts/index.yaml);
3. publique os artefatos no repositório Git ou no endpoint estático usado como Helm repo;
4. execute `helm repo update` nos ambientes consumidores.

## Observações

- Os charts `grafana`, `prometheus` e `nexus` assumem uso de `Route`, portanto são voltados para OpenShift.
- O `storageClass` padrão dos charts de aplicação está configurado como `proxmox-data-xfs`.
- O chart `openshift-proxmox-csi-plugin` exige ajuste cuidadoso de credenciais, classes de armazenamento e permissões de cluster.

# Airflow de desenvolvimento da CGINF - Coordenação-Geral de Gestão de Informações

Neste repositório estão os arquivos e orientações da instalação e configuração do ambiente Airflow utilizado pelos desenvolvedores da CGINF/SEGES.

Este ambiente é similar ao de produção: utiliza a mesma versão do Airflow, instala os mesmo módulos extras do Airflow e as mesmas dependências python. Isso possibilita que o desenvolvimento seja realizado totalmente em ambiente local de forma compatível com o ambiente produção.

Este repositório foi adaptado a partir da solução do Puckel disponível em https://github.com/puckel/docker-airflow.

## Preparação e execução

1. Instalar Docker CE [aqui!](https://docs.docker.com/get-docker/)
2. Clonar o repositório [airflow-docker-local](https://git.economia.gov.br/seges-cginf/airflow-docker-local) na máquina
> ```$ git clone http://git.planejamento.gov.br/seges-cginf/airflow-docker-local.git```
3. Dentro da pasta clonada (na raiz do arquivo Dockerfile), executar o comando para gerar a imagem docker
> ```$ docker build -t airflow-local .```
4. Executar o comando para subir ambiente (na raiz do arquivo docker-compose.yml)
> ```$ docker-compose up -d```

> Se quiser acompanhar o log, ou iniciar o ambiente com o comando ```$ docker-compose up```, ou após iniciado com o comando acima executar o comando ```$ docker logs -f <<CONTAINER_ID>>```

5. Exportar variáveis do Airflow produção e importar no Airflow Local

No Airflow produção acesse a tela de cadastro de variáveis ([Admin >> Variables](http://etl-cginflab.mp.intra/variable/list/)), selecione todas as variáveis, e utilize a opção **Export** do menu Actions e faça download do arquivo:

![Tela para exportação das variáveis](/doc/img/exportacao-variaveis.png)

Em seguida acesse a mesma tela no Airflow instalado localmente [(Admin >> Variables)](http://localhost:8080/variable/list/) e utilize a opção **Import Variables**.

6. Criar as conexões no Airflow Local

Esta etapa é similar à anterior, porém, por motivos de segurança, não é possível realizar a exportação e importação das conexões. Dessa forma é necessário criar cada conexão na sua instalação do Airflow local. Todavia é possível listar e copiar todos os parâmetros de cada conexão com exceção do *password*. Para isso acesse no Airflow produção a tela de cadastro de conexões ([Admin >> Connectios](http://etl-cginflab.mp.intra/connection/list/)). Selecione e copie os parâmetros visíveis das conexões que você precisa utilizar, e solicite as devidas senhas aos colegas da equipe. Para visualizar os parâmetros clique no botão **Edit record**:

![](/doc/img/tela-listagem-conexoes.png)

## Clonando o repositório de DAGs

A partir deste diretório, execute:

```$ cd ..```

```$ git clone http://git.economia.gov.br/seges-cginf/airflow-dags.git```

Isso fará o clone do repositório onde estão todas as DAGs da CGINF em um diretório independente. Como o Airflow já está em execução, ele identificará as novas DAGs e automaticamente exibirá na tela principal. Este resultado pode demorar algum tempo (menos de 1 min).

## Volumes

* Os arquivos de banco ficam persistidos em ```./mnt/pgdata```
* As dags devem estar em um diretório paralelo a este chamado **airflow-dag**. Ou seja o Airflow está preparado para carregar as dags no diretório ```../airflow-dags```. Se você executou corretamente o passo anterior (Clonando o repositório de dags), este diretório já está devidamente criado.

## Instalação de bibliotecas Python

Novas bibliotecas python podem ser instaladas adicionando o nome e versão (opcional) no arquivo ```./requirements.txt```

## Para desligar o ambiente Airflow

> ```$ docker-compose down```

## Para atualizar a imagem docker

> ```$ docker build --rm -t airflow-local .```

---
**Have fun!**


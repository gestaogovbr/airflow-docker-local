# airflow-docker-local

Imagem docker para ambiente de desenvolvimento local do Airflow.

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

No Airflow produção acesse a tela de cadastro de variáveis [(Admin >> Variables)](http://etl-cginflab.mp.intra/variable/list/), selecione todas as variáveis, e utilize a opção **Export** do menu Actions e faça download do arquivo:

![Tela para exportação das variáveis](/doc/img/exportacao-variaveis.png)

Em seguida acesse a mesma tela no Airflow instalado localmente [(Admin >> Variables)](http://localhost:8080/variable/list/) e utilize a opção **Import Variables**.

6. Criar as conexões no Airflow Local

## Clonando o repositório de DAGs

A partir deste diretório, execute:

```$ cd ..```

```$ git clone http://git.economia.gov.br/seges-cginf/airflow-dags.git```

Isso fará o clone do repositório onde estão todas as DAGs da CGINF em um diretório independente. Como o Airflow já está em execução, ele identificará as novas DAGs e automaticamente exibirá na tela principal. Este resultado pode demorar algum tempo (menos de 1 min).

## Volumes

* Os arquivos de banco ficam persistidos em ```./mnt/pgdata```
* As dags devem estar em um diretório paralelo a este chamado **airflow-dag**. Ou seja o Airflow está preparado para carregar as dags no diretório ```../airflow-dags```. Se você executou corretamente o passo anterior (Clonando o repositório de dags), este diretório já está devidamente criado.

## Instalação de bibliotecas

Novas bibliotecas python podem ser instaladas adicionando o nome e versão (opcional) no arquivo ```./requirements.txt```

## Para baixar o ambiente

> ```$ docker-compose down```

## Para atualizar a imagem

> ```$ docker build --rm -t airflow-local .```

---
**Have fun!**


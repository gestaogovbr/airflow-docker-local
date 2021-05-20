# Airflow de desenvolvimento da CGINF - Coordenação-Geral de Gestão de Informações

Neste repositório estão os arquivos e orientações da instalação e
configuração do ambiente Airflow utilizado pelos desenvolvedores da
CGINF/SEGES.

Este ambiente é similar ao de produção: utiliza a mesma versão do
Airflow, instala os mesmo módulos extras do Airflow e as mesmas
dependências python. Isso possibilita que o desenvolvimento seja
realizado totalmente em ambiente local de forma compatível com o
ambiente produção.

Este repositório foi adaptado a partir da solução do Puckel disponível
em https://github.com/puckel/docker-airflow.

## Preparação e execução do Airflow

1. Instalar Docker CE [aqui!](https://docs.docker.com/get-docker/)
2. Clonar o repositório
   [airflow-docker-local](https://git.economia.gov.br/seges-cginf/airflow-docker-local)
   na máquina
> ```$ git clone http://git.planejamento.gov.br/seges-cginf/airflow-docker-local.git```

> ```$ cd airflow-docker-local```
3. Dentro da pasta clonada (na raiz do arquivo Dockerfile), executar o
   comando para gerar a imagem docker
> ```$ docker build --rm -t airflow-local .```

> Se o docker build retornar a mensagem ```error checking context: 'can't stat '/home/<user-linux>/.../airflow-docker-local/mnt/pgdata''.```, então executar:

> ```sudo chown -R <user-linux> mnt/pgdata```

> Para conferir se o build concluiu com sucesso:

> ```docker images```

> E verificar se a imagem 'airflow-local' latest foi gerada recentemente (CREATED).

Neste momento já é possível executar o Airflow. Porém ainda é necessário clonar mais outros repositórios, tanto os que contém **plugins** do Airflow assim como o repositório contendo as **DAGs** de fato.

## Importando Plugins e DAGs

As DAGs desenvolvidas na Seges utilizam 2 frameworks (plugins). O **FastETL**, que está aberto no github, e o **airflow_commons**.

### Importe o Framework FastETL

Este plugin é a parte mais organizada dos algoritmos e extensões do Airflow inventados pela equipe para realizar tarefas repetitivas dentro das DAGs, como a **carga incremental** de uma tabela entre BDs ou a **carga de uma planilha do google** em uma tabela no datalake.

A partir do diretório corrente, execute:

```$ cd ..```

```$ git clone https://github.com/economiagovbr/FastETL.git```

### Importe o Framework airflow_commons

Já este é o que podemos chamar de "versão *alpha* do FastETL" ou o "celeiro de novos plugins". Eventualmente você pode identificar um código repetido em várias DAGs. Caso aconteça, você deveria refatorar e criar um script no **airflow_commons**, e importá-lo nos diversos projetos. A evolução seria esta função ser levada oficialmente ao FastETL, para assim ser utilizada mais amplamente e melhor evoluída.

A partir do diretório corrente, execute:

```$ git clone http://git.planejamento.gov.br/seges-cginf/airflow_commons.git```
### Importe o repositório de DAGs do seu interesse

Atualmente a SEGES possui 3 repositórios onde estão organizadas as DAGs do DETRU, do DELOG e da CGINF e demais unidades:

* CGINF - https://git.economia.gov.br/seges-cginf/airflow-dags/
* DELOG - https://git.economia.gov.br/seges/airflow-dags-delog/
* DETRU - https://git.economia.gov.br/seges/airflow-dags-detru/

Para clonar o repositório da **CGINF**, execute:

```$ git clone http://git.economia.gov.br/seges-cginf/airflow-dags.git```

Para clonar o repositório do **DELOG**, execute:

```$ git clone http://git.economia.gov.br/seges/airflow-dags-delog.git```

Para clonar o repositório do **DETRU**, execute:

```$ git clone http://git.economia.gov.br/seges/airflow-dags-detru.git```

## Executar o Airflow

A execução é feita de forma isolada por repositório de DAGs. Acesse o repositório do ambiente local:

> ```$ cd airflow-docker-local```

Para subir o Airflow com as dags da CGINF, execute:

> ```$ docker-compose -f docker-compose-cginf.yml up -d```

Para subir o Airflow com as dags do DELOG, execute:

> ```$ docker-compose -f docker-compose-delog.yml up -d```

Para subir o Airflow com as dags do DETRU, execute:

> ```$ docker-compose -f docker-compose-detru.yml up -d```


Acesse o Airflow em http://localhost:8080/ o/

Neste momento a interface web do Airlfow provavelmente apresentará uma lista enorme de erros. São erros indicando que o Airflow não consegue encontrar as variáveis e conexões utilizadas na compilação das DAGs. Para resolver prossiga com os passos seguintes.

## Configurações finais

O Airflow possui módulos que possibilitam o isolamento de **variáveis**
e **conexões**, permitindo maior flexibilidade na configuração das DAGs
e a guarda segura (encriptada) das senhas utilizadas pelas DAGs para se
conectarem com os inúmeros serviços. As variáveis podem ser copiadas
facilmente do ambiente de produção, o que não é permitido com as
conexões, por motivos óbvios.

### Exportar variáveis do Airflow produção e importar no Airflow Local

No Airflow produção acesse a tela de cadastro de variáveis
([Admin >> Variables](http://airflow.seges.mp.intra/variable/list/)),
selecione todas as variáveis, e utilize a opção **Export** do menu
Actions e faça download do arquivo:

![Tela para exportação das variáveis](/doc/img/exportacao-variaveis.png)

Em seguida acesse a mesma tela no Airflow instalado localmente
[(Admin >> Variables)](http://localhost:8080/variable/list/) e utilize a
opção **Import Variables**.

### Criar as conexões no Airflow Local

Esta etapa é similar à anterior, porém, por motivos de segurança, não é
possível realizar a exportação e importação das conexões. Dessa forma é
necessário criar cada conexão na sua instalação do Airflow local.
Todavia é possível listar e copiar todos os parâmetros de cada conexão
com exceção do *password*. Para isso acesse no Airflow produção a tela
de cadastro de conexões
([Admin >> Connectios](http://airflow.seges.mp.intra/connection/list/)).
Selecione e copie os parâmetros visíveis das conexões que você precisa
utilizar, e solicite as devidas senhas aos colegas da equipe.

Se você seguiu todas as etapas até aqui, o Airflow ainda deve estar
apresentando uma lista enorme de erros. Como explicado no parágrafo
acima, daqui pra frente será necessário cadastrar as conexões no Airflow
uma a uma, o que levará muito tempo, além de ser desnecessário para o
desenvolvimento de uma nova DAG ou para dar manutenção em apenas uma DAG
existente. Para reduzir drasticamente a lista de erros basta criar uma
conexão do tipo **HTTP** com nome `slack`. Isso silenciará praticamente
todos os erros.

Uma rápida explicação é de que esta conexão chamada `slack` é utilizada
por praticamente todas as nossas DAGs para envio de notificação em caso
de falhas. Caso você execute localmente alguma DAG que implementa esta
configuração, o seu Airflow  não enviará notificações de fato já que a
conexão criada não possui nenhuma propriedade preenchida, com exceção do
nome.

Para visualizar os parâmetros de uma conexão registrada no Airflow
produção, clique no botão **Edit record**:

![](/doc/img/tela-listagem-conexoes.png)

## Volumes

* Os arquivos de banco ficam persistidos em ```./mnt/pgdata```
* As dags devem estar em um diretório paralelo a este chamado
  **airflow-dag**. Ou seja o Airflow está preparado para carregar as
  dags no diretório ```../airflow-dags```. Se você executou corretamente
  o passo anterior (Clonando o repositório de dags), este diretório já
  está devidamente criado.

## Instalação de bibliotecas Python

Novas bibliotecas python podem ser instaladas adicionando o nome e
versão (opcional) no arquivo ```./requirements.txt```

## Para desligar o ambiente Airflow

> ```$ docker-compose down```

## Para atualizar a imagem docker

> ```$ docker build --rm -t airflow-local .```

Após isso você já pode subir novamente os containers!

---
**Have fun!**


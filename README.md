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
4. Executar o comando para subir ambiente (na raiz do arquivo
   docker-compose.yml)
> ```$ docker-compose up -d```

> Se quiser acompanhar o log, ou iniciar o ambiente com o comando ```$
> docker-compose up```, ou após iniciado com o comando acima executar o
> comando ```$ docker logs -f <<CONTAINER_ID>>```

## Importando as DAGs da CGINF/SEGES

O segundo grande passo é configurar o Airflow para reconhecer todas as
DAGs que são mantidas pela CGINF. As DAGs são matindas em um
repositórios exclusivo que precisa ser clonado em um diretório ao lado
(no mesmo nível) deste repositório. A partir do diretório corrente,
execute:

```$ cd ..```

```$ git clone http://git.economia.gov.br/seges-cginf/airflow-dags.git```

Isso fará o clone do repositório onde estão todas as DAGs da CGINF em um
diretório independente. Como o Airflow já está em execução, ele
identificará as novas DAGs e automaticamente exibirá na tela principal.
Este resultado pode demorar algum tempo (menos de 1 min).

Neste momento a interface web do Airlfow provavelmente apresentará uma
lista enorme de erros. São erros indicando que o Airflow não consegue
encontrar os plugins, as variáveis e conexões utilizadas na compilação
das DAGs. Para resolver prossiga com os passos seguintes.

## Importando o Framework FastETL (plugins)

O
[FastETL é um pacote que contém diversos Plugins Airflow](https://github.com/economiagovbr/FastETL)
construídos por nós na CGINF. Praticamente todas as DAGs utilizam
componentes do FastETL. A configuração a seguir vai reduzir a quantidade
de inconsistência apresentadas na interface gráfica do Airflow.

A partir do diretório corrente, execute:

```$ git clone https://github.com/economiagovbr/FastETL.git```

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


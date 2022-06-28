# composicao-societaria
Scripts para geração de base de grafos em Neo4j dos dados públicos de Composição Societária da Receita Federal

## Pré-requisitos:
- Você deve ter o Neo4j Desktop instalado na sua máquina, porque este processo de carga utiliza a ferramenta de carga em lote (bulk) neo4j-admin
- Instalação do plugin APOC na sua instância Neo4j (exportação do resultado de queries Cypher em arquivos csv)

## O processo de geração da base consiste em 3 etapas (script popula-grafo.cql):
- Carga via neo4j-admin dos csv (empresas.csv.gz e socios.csv.gz) baixados do site da Receita Federal em uma base chamada **carga**, gerando uma base sem relacionamentos e com apenas dois tipos de nós rotulados: Empresa e Socio.
- Execução de queries sobre os dados na base **carga** para identificar e gerar as composições societárias de pessoas físicas, jurídicas e de estrangeiros, exportando-os como arquivos csv
- Carga dos novos csvs gerados na etapa anterior para uma nova base **receita**, dessa vez gerando uma base com relacionamentos e com nós separados para pessoa física, jurídica e estrangeiros

## Resultado esperado:
- 1 base **carga** sem relacionamentos e com os dados brutos da carga dos arquivos da Receita
- 1 base **receita** com relacionamentos e nós rotulados de Pessoas, Empresas e Estrangeiros carregados a partir dos csvs carregados das queries de tratamento de sócios

## Referências e idéias similares
- [aula2](https://colab.research.google.com/github/ormastroni/fundamentos-python/blob/main/aula2.ipynb)
- [aula3](https://colab.research.google.com/github/ormastroni/fundamentos-python/blob/main/aula3.ipynb)
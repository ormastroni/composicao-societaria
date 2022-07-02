# composicao-societaria
Scripts para geração de uma base de grafos no Neo4j dos dados públicos de Composição Societária da Receita Federal

## Pré-requisitos:
- Você deve ter o **Neo4j Desktop** instalado na sua máquina, porque este processo de carga utiliza a ferramenta de carga em lote (bulk) neo4j-admin
- Instalação do **plugin APOC** na sua instância Neo4j (exportação do resultado de queries Cypher em arquivos csv)
- Você deve manter os arquivos ***-header.csv** na mesma pasta onde os demais arquivos gz da Receita são carregados (pasta import do database ou pasta configurável)

## Restrições:
- Os scripts foram desenvolvidos para o formato de dados antigo da Receita e não foram testados para o formato da base atual

## Geração da base (script popula-grafo.cql) em 3 etapas :
- Carga via **neo4j-admin** dos csv (empresas.csv.gz e socios.csv.gz) baixados do site da Receita Federal em uma base chamada **carga**, gerando uma base sem relacionamentos e com apenas dois tipos de nós rotulados: Empresa e Socio.
- Execução de queries sobre os dados na base **carga** para identificar e gerar as composições societárias de pessoas físicas, jurídicas e de estrangeiros, exportando-os como arquivos csv
- Carga dos novos csvs gerados na etapa anterior, também via **neo4j-admin**, para uma nova base **receita**, dessa vez gerando uma base com relacionamentos e distinção dos sócios rotulados por pessoa física, jurídica e estrangeiros

## Resultado esperado:
- 1 base **carga** sem relacionamentos e com os dados brutos da carga dos arquivos da Receita
- 1 base **receita** com relacionamentos e nós rotulados de Pessoas, Empresas e Estrangeiros carregados a partir dos csvs gerados da base **carga**

## Referências e idéias similares
- [Dados abertos Receita Federal](https://www.gov.br/receitafederal/pt-br/assuntos/orientacao-tributaria/cadastros/consultas/dados-publicos-cnpj)
- [CNPJ-full](https://github.com/fabioserpa/CNPJ-full)
- [API pública cuducos](https://github.com/cuducos/minha-receita)
- [Rede CNPJ](https://github.com/rictom/rede-cnpj)

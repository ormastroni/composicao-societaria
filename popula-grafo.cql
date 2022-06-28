// Carga dos dados brutos da Receita para o database ** carga ** do Neo4j

neo4j-admin.bat import --database=carga --skip-bad-relationships --nodes=Empresa=import/empresas-header.csv,import/empresas.csv.gz --nodes=Socio=import/socios-header.csv,import/socios.csv.gz 

// Os dados brutos são então exportados em outros conjuntos CSVs mais refinados para o modelo de grafos.
// As queries a seguir devem ser executadas no database ** carga ** para gerar os csvs que vão de fato popular o grafo da rede da Receita.
// Optou-se por essa estratégia porque a geração de CSVs e posterior carga bulk pelo neo4j-admin é muito mais rápida do que o tratamento 
// dos dados por queries ad-hoc diretamente na base

// Criar índices para agilizar a geração do csv de Pessoas (Socio)
CREATE INDEX socio_cod_tipo_socio for (n:Socio) ON (n.codigo_tipo_socio)
CREATE INDEX socio_cpf_cnpj_socio for (n:Socio) ON (n.cpf_cnpj_socio)

WITH "MATCH (s:Socio) WHERE s.codigo_tipo_socio = '2' AND s.cpf_cnpj_socio IS NOT NULL RETURN DISTINCT substring(s.cpf_cnpj_socio,3,6) + s.nome_socio as chave, s.cpf_cnpj_socio as cpf, s.nome_socio as nome" as query
CALL apoc.export.csv.query(query, "pessoas.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;

WITH "MATCH (s:Socio) where s.codigo_tipo_socio = '2' RETURN DISTINCT substring(s.cpf_cnpj_socio,3,6) + s.nome_socio as socio, s.cnpj as cnpj, s.codigo_qualificacao_socio as cod_qualif, s.qualificacao_socio as qualificacao" as query
CALL apoc.export.csv.query(query, "socio_pessoas.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;

WITH "MATCH (s:Socio) where s.codigo_tipo_socio = '1' RETURN DISTINCT s.cpf_cnpj_socio as socio, s.cnpj as cnpj, s.codigo_qualificacao_socio as cod_qualif, s.qualificacao_socio as qualificacao" as query
CALL apoc.export.csv.query(query, "socio_empresas.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;

WITH "MATCH (s:Socio) where s.codigo_tipo_socio = '3' RETURN DISTINCT s.nome_socio as nome" as query
CALL apoc.export.csv.query(query, "estrangeiros.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;

WITH "MATCH (s:Socio) where s.codigo_tipo_socio = '3' RETURN DISTINCT s.nome_socio as chave, s.cnpj as cnpj, s.codigo_qualificacao_socio as cod_qualif, s.qualificacao_socio as qualificacao" as query
CALL apoc.export.csv.query(query, "socio_estrangeiros.csv", {})
YIELD file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data
RETURN file, source, format, nodes, relationships, properties, time, rows, batchSize, batches, done, data;

// Depois da geração dos CSVs pelas queries anteriores, gerar uma nova carga bulk dos novos CSVs em um novo database ** receita **
// Este database vai popular o modelo de grafo desejado: (Pessoa)-[SOCIO]->(Empresa)<-[SOCIO]-(Empresa)
//                                                                             ^
//                                                                             |
//                                                                          [SOCIO]
//                                                                             |
//                                                                        (Estrangeiro)
//

neo4j-admin.bat import --database=receita --skip-bad-relationships --nodes=Empresa=import/empresas-header.csv,import/empresas.csv.gz --nodes=Pessoa=import/pessoas-header.csv,import/pessoas.csv --nodes=Estrangeiro=import/estrangeiros-header.csv,import/estrangeiros.csv --relationships=SOCIO=import/socio_empresas-header.csv,import/socio_empresas.csv --relationships=SOCIO=import/socio_pessoas-header.csv,import/socio_pessoas.csv --relationships=SOCIO=import/socio_estrangeiros-header.csv,import/socio_estrangeiros.csv

// Separamos em dois labels diferentes parte dos dados da tabela Socios: nós de Pessoas e nós de Estrangeiros
// os nós de pessoas são os sócios pessoa física, e os nós de estrangeiros são aqueles residentes no exterior que não tem CNPJ
// Criação de índices para acelerar a busca

CREATE CONSTRAINT empresa_cnpj_pk ON (n:Empresa) ASSERT n.cnpj IS UNIQUE
CREATE CONSTRAINT pessoa_chave_pk ON (n:Pessoa) ASSERT n.chave IS UNIQUE
CREATE FULLTEXT INDEX nomes FOR (n:Empresa|Pessoa|Estrangeiro) ON EACH [n.razao_social, n.nome]

CALL db.index.fulltext.queryNodes("nomes", "GLOBAL") YIELD node, score
RETURN node.razao_social, node.nome, score
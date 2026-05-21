# SDD - Spec-Driven Development

## 1. Identificacao

### 1.1 Nome do projeto

`Desafio iOS`

### 1.2 Tipo de sistema

Aplicativo mobile iOS nativo desenvolvido em `SwiftUI`.

### 1.3 Objetivo do sistema

Permitir que o usuario:

- visualize uma lista de exchanges de criptoativos
- consulte detalhes de uma exchange especifica
- visualize os assets retornados para a exchange selecionada

### 1.4 Fonte da especificacao

Esta especificacao foi derivada do codigo atual do projeto, e nao de um documento funcional externo. Portanto, ela descreve:

- o comportamento implementado hoje
- os contratos observados na base
- as restricoes tecnicas reais do sistema
- os gaps identificados entre intencao arquitetural e comportamento atual

## 2. Visao de Produto

O produto e um app iOS de consulta de exchanges usando a API da CoinMarketCap. A experiencia principal e simples:

1. carregar lista de exchanges
2. ordenar e apresentar os itens
3. navegar para uma tela de detalhe
4. exibir metadados e assets da exchange

O sistema foi desenhado para ser:

- simples de testar
- facil de manter
- desacoplado entre UI, dominio e infraestrutura
- adaptavel a cenarios reais e cenarios stubados

## 3. Escopo

### 3.1 Escopo funcional atual

Inclui:

- listagem de exchanges
- atualizacao manual da lista
- navegacao para detalhe
- exibicao de estado de loading
- exibicao de estado vazio
- exibicao de estado de erro com retry
- carregamento de descricao, logo, website, fees, data de lancamento e assets
- suporte a cenarios de UI test por argumentos de inicializacao

### 3.2 Fora do escopo atual

Nao inclui:

- autenticacao de usuario
- persistencia local
- cache offline
- paginacao
- busca textual
- filtros de exchange
- favoritar exchanges
- analytics
- observabilidade estruturada
- feature flags

## 4. Stakeholders

### 4.1 Usuario final

Pessoa que deseja consultar exchanges e seus assets.

### 4.2 Desenvolvedor iOS

Responsavel por manter, evoluir e testar o app.

### 4.3 Avaliador tecnico ou equipe de produto

Interessado em:

- clareza arquitetural
- aderencia a boas praticas
- qualidade de codigo
- capacidade de evolucao

## 5. Metas de Engenharia

O sistema deve priorizar:

- separacao de responsabilidades
- testabilidade
- previsibilidade dos estados de tela
- baixo acoplamento com a API externa
- facilidade de substituir origem de dados

## 6. Requisitos Funcionais

### RF-01 - Carregar lista de exchanges

O sistema deve buscar exchanges na inicializacao da tela principal.

Criterios:

- o carregamento deve iniciar automaticamente ao abrir a lista
- a fonte de dados deve ser um `ExchangesRepository`
- quando houver sucesso com itens, a tela deve apresentar a lista

### RF-02 - Atualizar lista manualmente

O sistema deve permitir recarregar a lista via gesto de refresh.

Criterios:

- a tela deve usar mecanismo nativo de refresh
- o refresh deve executar o mesmo fluxo do carregamento inicial

### RF-03 - Exibir estado de carregamento da lista

Enquanto o carregamento estiver em andamento, a interface deve exibir indicador visual de progresso.

Criterios:

- a tela deve mostrar `ProgressView`
- a tela deve exibir placeholders visuais

### RF-04 - Exibir estado vazio da lista

Quando a consulta retornar zero exchanges, a interface deve mostrar estado vazio.

Criterios:

- deve haver mensagem explicativa
- deve haver acao de tentar novamente

### RF-05 - Exibir estado de erro da lista

Quando ocorrer erro ao buscar exchanges, a interface deve mostrar mensagem amigavel.

Criterios:

- a mensagem deve ser derivada do erro retornado
- a tela deve oferecer retry

### RF-06 - Navegar para detalhe da exchange

O sistema deve permitir abrir a tela de detalhe ao selecionar uma exchange.

Criterios:

- a navegacao deve partir de um item da lista
- o detalhe deve receber `exchangeID`

### RF-07 - Carregar detalhe da exchange

O sistema deve consultar informacoes detalhadas da exchange selecionada.

Criterios:

- o detalhe deve buscar metadata da exchange
- o detalhe deve buscar assets da exchange
- a orquestracao deve ocorrer via `ExchangesRepository`

### RF-08 - Exibir metadados da exchange

O detalhe deve apresentar:

- nome
- identificador
- descricao, quando existir
- data de lancamento, quando existir
- maker fee, quando existir
- taker fee, quando existir
- link do website, quando existir
- logo, quando existir

### RF-09 - Exibir lista de assets

O detalhe deve apresentar os assets da exchange.

Criterios:

- os assets devem ser listados com nome da moeda
- o preco em USD deve ser exibido quando existir
- se nao houver assets, a secao deve exibir estado vazio

### RF-10 - Suportar cenarios de execucao para testes

O sistema deve aceitar modos de inicializacao diferentes para suportar testes e previews.

Criterios:

- o app deve suportar cenario `live`
- o app deve suportar cenarios stubados para sucesso, erro, vazio e rate limit

## 7. Requisitos Nao Funcionais

### RNF-01 - Arquitetura em camadas

O sistema deve manter separacao entre:

- apresentacao
- dominio
- dados
- infraestrutura

### RNF-02 - Testabilidade

O sistema deve permitir testes unitarios e de interface sem dependencia obrigatoria da API real.

### RNF-03 - Tratamento consistente de erros

Erros tecnicos devem ser convertidos em mensagens apresentaveis ao usuario.

### RNF-04 - Manutenibilidade

As dependencias devem ser injetadas por composicao em vez de serem acopladas diretamente nas views.

### RNF-05 - Concorrencia moderna

O sistema deve usar `async/await` para chamadas assincronas.

### RNF-06 - Acessibilidade e automacao

Elementos chave da interface devem possuir `accessibilityIdentifier`.

### RNF-07 - Configurabilidade

Credenciais e configuracoes de ambiente nao devem ser hardcoded no fluxo principal da aplicacao.

## 8. Arquitetura Logica

### 8.1 Camadas

#### App

Responsavel por:

- bootstrap
- leitura de configuracao
- definicao de cenario de inicializacao
- injecao de dependencias

Principais componentes:

- `DesafioApp`
- `AppRootView`
- `AppContainer`
- `AppConfig`

#### Domain

Responsavel por:

- contratos de repositorio
- entidades de negocio

Principais componentes:

- `ExchangesRepository`
- `ExchangeSummary`
- `ExchangeDetail`
- `ExchangeAsset`

#### Data

Responsavel por:

- acesso a dados remotos
- mapeamento DTO -> dominio
- composicao de respostas vindas da API

Principais componentes:

- `CoinMarketCapExchangeService`
- `LiveExchangesRepository`
- `PreviewExchangesRepository`

#### Networking

Responsavel por:

- construcao de request
- execucao HTTP
- parse inicial de falha
- decodificacao de datas

Principais componentes:

- `HTTPClient`
- `URLSessionHTTPClient`
- `APIRequest`
- `NetworkError`
- `CMCDecoder`

#### Features

Responsavel por:

- comportamento de tela
- gerenciamento de estado de interface
- navegacao entre lista e detalhe

Principais componentes:

- `ExchangesListView`
- `ExchangesListViewModel`
- `ExchangeDetailView`
- `ExchangeDetailViewModel`

## 9. Modelo de Dominio

### 9.1 ExchangeSummary

Representa um item resumido da lista.

Campos:

- `id: Int`
- `name: String`
- `logoURL: URL?`
- `spotVolumeUSD: Decimal?`
- `dateLaunched: Date?`

### 9.2 ExchangeDetail

Representa o detalhe completo da exchange.

Campos:

- `id: Int`
- `name: String`
- `logoURL: URL?`
- `description: String?`
- `websiteURL: URL?`
- `makerFee: Decimal?`
- `takerFee: Decimal?`
- `dateLaunched: Date?`
- `assets: [ExchangeAsset]`

### 9.3 ExchangeAsset

Representa um asset retornado para uma exchange.

Campos:

- `id: String`
- `currencyName: String`
- `priceUSD: Decimal?`

## 10. Contratos Principais

### 10.1 Contrato de repositorio

`ExchangesRepository` deve fornecer:

- `fetchExchanges() async throws -> [ExchangeSummary]`
- `fetchExchangeDetail(exchangeID: Int) async throws -> ExchangeDetail`

### 10.2 Contrato de service

`ExchangeService` deve fornecer:

- `fetchListings(limit: Int) async throws -> [ExchangeListingDTO]`
- `fetchInfo(ids: [Int]) async throws -> [Int: ExchangeInfoDTO]`
- `fetchAssets(exchangeID: Int) async throws -> [ExchangeAssetDTO]`

### 10.3 Contrato HTTP

`HTTPClient` deve fornecer:

- `send(_ request: APIRequest, config: AppConfig) async throws -> Data`

## 11. Fluxos de Execucao

### 11.1 Fluxo principal da lista

1. A aplicacao inicializa `AppContainer`.
2. O `AppRootView` abre `ExchangesListView`.
3. A view dispara `viewModel.load()`.
4. O `ViewModel` seta estado `loading`.
5. O repositorio busca listagem e informacoes complementares.
6. O resultado e transformado em `[ExchangeSummary]`.
7. A view apresenta lista, vazio ou erro.

### 11.2 Fluxo principal do detalhe

1. O usuario toca em uma exchange.
2. A tela de detalhe e criada com `exchangeID`.
3. A view dispara `viewModel.load()`.
4. O `ViewModel` seta estado `loading`.
5. O repositorio consulta `info` e `assets` em paralelo.
6. O resultado e transformado em `ExchangeDetail`.
7. A view apresenta header e secao de assets.

### 11.3 Fluxo de erro

1. O service ou client lanca erro.
2. O `ViewModel` converte erro em mensagem.
3. A view exibe `ScreenStateView`.
4. O usuario pode disparar retry.

## 12. Regras de Negocio Observadas

### RB-01

A lista de exchanges deve ser ordenada por `spotVolumeUSD` em ordem decrescente.

### RB-02

Quando uma exchange nao tiver volume comparavel, o fallback de ordenacao deve ser por nome.

### RB-03

No detalhe, os assets devem ser ordenados alfabeticamente por `currencyName`.

### RB-04

Se `fetchInfo(ids:)` nao retornar a exchange solicitada no detalhe, a operacao deve falhar.

### RB-05

Na lista, `spotVolumeUSD` e `dateLaunched` vindos de `info` tem precedencia sobre os dados da listagem quando disponiveis.

### RB-06

Sem API key valida, requisicoes remotas nao devem ser executadas.

## 13. Integracao Externa

### 13.1 Sistema externo

`CoinMarketCap API`

### 13.2 Endpoints usados

- `/v1/exchange/listings/latest`
- `/v1/exchange/info`
- `/v1/exchange/assets`

### 13.3 Parametros principais observados

Na listagem:

- `start=1`
- `limit=30`
- `sort=volume_24h`
- `sort_dir=desc`
- `market_type=all`
- `category=spot`
- `convert=USD`
- `aux=date_launched`

No detalhe de info:

- `id=<lista de ids>`
- `aux=urls,logo,description,date_launched`

No detalhe de assets:

- `id=<exchangeID>`

## 14. Configuracao e Ambientes

### 14.1 Configuracao funcional

`AppConfig` deve carregar:

- `apiKey`
- `baseURL`
- `requestTimeout`

### 14.2 Origem da API key

Ordem de prioridade:

1. Variavel de ambiente `CMC_API_KEY`
2. Valor expandido no `Info.plist`

### 14.3 Ambiente atual encontrado

No estado atual do codigo:

- a `baseURL` padrao aponta para `https://sandbox-api.coinmarketcap.com`
- a URL de producao esta presente, mas comentada

### 14.4 Requisito desejado de seguranca

Chaves reais nao devem ser commitadas no repositorio.

## 15. Estados de Interface

### 15.1 Lista

Estados implementados:

- `idle`
- `loading`
- `loaded`
- `empty`
- `error`

### 15.2 Detalhe

Estados declarados:

- `idle`
- `loading`
- `loaded`
- `empty`
- `error`

Observacao:

- o estado `empty` do detalhe esta modelado, mas nao aparece como ramo funcional primario no fluxo atual

## 16. Tratamento de Erros

Os erros esperados do sistema incluem:

- URL invalida
- ausencia de API key
- offline
- timeout
- rate limit
- erro HTTP com status code
- falha de decodificacao
- erro inesperado

Mapeamentos obrigatorios observados:

- HTTP `429` -> `rateLimited`
- erro de conectividade -> `offline`
- timeout de rede -> `timeout`

## 17. Test Strategy

### 17.1 Testes unitarios existentes

Cobrem:

- configuracao
- parsing
- client HTTP
- repository live
- repository preview
- formatacao

### 17.2 Testes de UI existentes

Cobrem:

- fluxo feliz
- erro na lista
- estado vazio da lista

### 17.3 Gaps de teste identificados

Nao foram encontrados testes dedicados para:

- `ExchangesListViewModel`
- `ExchangeDetailViewModel`

## 18. Criterios de Aceitacao do Sistema

### CA-01

Ao abrir o app em modo `live`, a lista deve iniciar carregamento automaticamente.

### CA-02

Se a API retornar exchanges, a lista deve apresentar itens navegaveis.

### CA-03

Se a API retornar lista vazia, a tela deve exibir estado vazio com retry.

### CA-04

Se ocorrer falha de rede, a tela deve exibir mensagem amigavel e retry.

### CA-05

Ao tocar em um item da lista, o app deve abrir a tela de detalhe correspondente.

### CA-06

O detalhe deve exibir ao menos o nome e os assets quando os dados existirem.

### CA-07

Se o detalhe nao tiver assets, a secao deve informar ausencia de dados sem quebrar a navegacao.

### CA-08

O app deve suportar cenarios stubados via argumentos de inicializacao para testes de interface.

## 19. Riscos Tecnicos

### RT-01 - Segredo versionado

Existe indicio de credencial concreta em arquivo de configuracao. Isso representa risco de seguranca.

### RT-02 - Ambiente default em sandbox

Se o objetivo for operar em producao, a configuracao atual pode induzir comportamento diferente do esperado.

### RT-03 - Ambiguidade na regra de fee

O valor `0.02` e exibido como `0.02%`, o que pode divergir da interpretacao de negocio esperada.

### RT-04 - Estado inutilizado

O detalhe declara `empty`, mas o fluxo principal nao usa esse estado como transicao explicita.

### RT-05 - Dependencia de ambiente local para build

A validacao por `xcodebuild` depende de instalacao completa do Xcode, o que nao estava disponivel no ambiente analisado.

## 20. Backlog Tecnico Recomendado

### BT-01

Remover qualquer chave real do repositorio e adotar placeholder seguro.

### BT-02

Confirmar se a `baseURL` padrao deve ser sandbox ou producao.

### BT-03

Adicionar testes unitarios para os `ViewModels`.

### BT-04

Revisar a regra de exibicao de fees.

### BT-05

Decidir se o estado `empty` do detalhe deve ser removido ou efetivamente usado.

### BT-06

Avaliar paginacao da lista.

## 21. Evolucao orientada por Spec

Para manter o projeto aderente a `Spec-Driven Development`, toda evolucao futura deve seguir este fluxo:

1. definir comportamento esperado antes da implementacao
2. registrar impacto em requisitos funcionais e nao funcionais
3. atualizar contratos afetados
4. ajustar criterios de aceitacao
5. implementar
6. validar por testes unitarios e de interface
7. revisar a especificacao para mante-la sincronizada com o codigo

## 22. Definicao de Pronto

Uma alteracao sera considerada pronta quando:

- o comportamento estiver descrito na spec
- o contrato afetado estiver claro
- a implementacao respeitar a arquitetura em camadas
- os estados de erro estiverem tratados
- houver testes adequados para o risco da mudanca
- a documentacao estiver sincronizada com o comportamento real

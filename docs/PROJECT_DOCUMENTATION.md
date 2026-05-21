# Documentacao Detalhada do Projeto

## Visao Geral

O projeto `Desafio iOS` e um aplicativo iOS nativo em `SwiftUI` para listar exchanges de criptomoedas e exibir detalhes de cada exchange com dados vindos da `CoinMarketCap Pro API`.

O app foi estruturado com separacao clara de responsabilidades:

- `App`: bootstrap, configuracao e injecao de dependencias
- `Domain`: entidades de negocio e contratos
- `Data`: services, DTOs e repositories
- `Networking`: infraestrutura HTTP e tratamento de erros
- `Features`: telas e view models
- `UIComponents`: componentes e formatadores reutilizaveis
- `Tests`: testes unitarios e de interface

O fluxo principal consiste em:

1. O app sobe com um `AppContainer`.
2. O container escolhe qual `ExchangesRepository` sera usado.
3. A tela inicial carrega a lista de exchanges.
4. Ao abrir uma exchange, a tela de detalhe busca metadados e assets.

## Objetivo Funcional

O app entrega duas experiencias principais:

- Lista de exchanges ordenada por volume spot em USD
- Tela de detalhe da exchange com descricao, fees, data de lancamento, website e assets

Estados de interface tratados nas telas:

- `loading`
- `loaded`
- `empty`
- `error`

Isso torna a experiencia previsivel e simplifica testes de UI e manutencao.

## Estrutura de Pastas

```text
Desafio.iOS/
├── Desafio/
│   ├── App/
│   ├── Data/
│   │   ├── DTOs/
│   │   ├── Repositories/
│   │   └── Services/
│   ├── Domain/
│   │   ├── Entities/
│   │   └── Repositories/
│   ├── Features/
│   │   ├── ExchangeDetail/
│   │   └── ExchangesList/
│   ├── Networking/
│   └── UIComponents/
├── DesafioTests/
├── DesafioUITests/
├── ProjectConfig/
└── README.md
```

## Arquitetura

### Padrao adotado

O projeto segue uma composicao pratica de:

- `SwiftUI` para interface
- `MVVM` para estado e apresentacao
- `Repository` para isolamento da origem dos dados
- `Service` para integracao com endpoints externos

### Responsabilidade de cada camada

#### App

Responsavel por inicializacao, configuracao e montagem das dependencias.

Arquivos principais:

- `Desafio/App/DesafioApp.swift`
- `Desafio/App/AppRootView.swift`
- `Desafio/App/AppContainer.swift`
- `Desafio/App/AppConfig.swift`

Papel de cada um:

- `DesafioApp`: ponto de entrada do app
- `AppRootView`: cria o `NavigationStack` e injeta a tela inicial
- `AppContainer`: define qual repositorio sera usado em cada cenario
- `AppConfig`: carrega API key, `baseURL` e timeout

#### Domain

Define as estruturas de negocio independentes de UI e de infraestrutura.

Entidades:

- `ExchangeSummary`
- `ExchangeDetail`
- `ExchangeAsset`

Contrato principal:

- `ExchangesRepository`

Essa camada e importante porque protege a UI de detalhes de API, parsing e transporte.

#### Data

Implementa a integracao com a CoinMarketCap e faz o mapeamento entre DTOs e entidades de dominio.

Partes principais:

- `CoinMarketCapExchangeService`
- `LiveExchangesRepository`
- `PreviewExchangesRepository`
- DTOs de resposta da API

#### Networking

Camada reutilizavel e testavel para requests HTTP.

Elementos principais:

- `HTTPClient`
- `URLSessionHTTPClient`
- `APIRequest`
- `NetworkError`
- `CMCDecoder`

#### Features

Contem as telas e seus respectivos `ViewModels`.

- `Features/ExchangesList`
- `Features/ExchangeDetail`

Cada feature segue a mesma ideia:

- `View`: renderiza estado
- `ViewModel`: coordena carregamento e transforma erro em mensagem apresentavel

#### UIComponents

Concentra componentes compartilhados:

- `RemoteImageView`
- `ScreenStateView`
- `Formatters`

## Fluxo de Inicializacao

### Entry point

O app inicia em `DesafioApp`, cria um `AppContainer` padrao e injeta esse container no `AppRootView`.

### Container de dependencias

`AppContainer.makeDefault()` escolhe o repositorio conforme o cenario de execucao:

- `live`: usa API real
- `ui_success`: usa repositorio preview
- `ui_empty`: usa stub vazio
- `ui_error`: usa stub com erro offline
- `ui_rate_limit`: usa stub com erro de rate limit

Esses cenarios sao obtidos por `AppLaunchScenario.current()`, que le argumentos de inicializacao do processo. Isso foi feito principalmente para suportar testes de UI e previews mais controlados.

## Fluxo de Dados

### Lista de exchanges

Fluxo da lista:

1. `ExchangesListView` chama `await viewModel.load()`.
2. `ExchangesListViewModel` invoca `repository.fetchExchanges()`.
3. `LiveExchangesRepository` chama:
   - `service.fetchListings(limit: 30)`
   - `service.fetchInfo(ids: listings.map(\.id))`
4. O repository combina os dados de `listings` com `info`.
5. O resultado e convertido em `[ExchangeSummary]`.
6. A lista e ordenada por `spotVolumeUSD` de forma decrescente.
7. A view renderiza `loading`, `empty`, `error` ou `loaded`.

Detalhes relevantes:

- O endpoint de listagem fornece uma base de exchanges
- O endpoint de info complementa logo, descricao, fees e metadata adicional
- Caso `spotVolumeUSD` ou `dateLaunched` estejam disponiveis em `info`, eles tem prioridade sobre os dados de `listings`

### Detalhe da exchange

Fluxo do detalhe:

1. O usuario toca em uma exchange na lista.
2. `ExchangeDetailView` e aberta com um `ExchangeDetailViewModel(exchangeID:)`.
3. O `ViewModel` chama `repository.fetchExchangeDetail(exchangeID:)`.
4. `LiveExchangesRepository` executa em paralelo:
   - `service.fetchInfo(ids: [exchangeID])`
   - `service.fetchAssets(exchangeID: exchangeID)`
5. O repository monta `ExchangeDetail`.
6. Os assets sao convertidos em `[ExchangeAsset]` e ordenados alfabeticamente.

Essa busca paralela reduz o tempo total de espera do detalhe.

## Camada de UI

### ExchangesList

Arquivos:

- `ExchangesListView.swift`
- `ExchangesListViewModel.swift`
- `ExchangeRowView.swift`

Comportamentos principais:

- inicia carregamento com `.task`
- suporta `pull-to-refresh` com `.refreshable`
- apresenta skeleton simples durante loading
- usa `NavigationLink` para abrir o detalhe
- define `accessibilityIdentifier` para suportar UI tests

Estados do `ViewModel`:

- `idle`
- `loading`
- `loaded([ExchangeSummary])`
- `empty`
- `error(String)`

### ExchangeDetail

Arquivos:

- `ExchangeDetailView.swift`
- `ExchangeDetailViewModel.swift`
- `ExchangeDetailHeaderView.swift`
- `ExchangeAssetsSectionView.swift`

Comportamentos principais:

- carrega dados ao entrar na tela
- mostra erro com retry
- exibe metadados da exchange
- exibe lista de assets ou estado vazio

Observacao:

- O `State.empty` existe no `ExchangeDetailViewModel`, mas no fluxo atual ele nao e usado explicitamente; quando uma exchange nao tem assets, a tela continua em `loaded` e a secao de assets mostra um estado vazio interno.

## Integracao com API

### Service principal

`CoinMarketCapExchangeService` concentra os endpoints consumidos.

Endpoints utilizados:

- `/v1/exchange/listings/latest`
- `/v1/exchange/info`
- `/v1/exchange/assets`

### Request da listagem

Parametros usados:

- `start=1`
- `limit=30`
- `sort=volume_24h`
- `sort_dir=desc`
- `market_type=all`
- `category=spot`
- `convert=USD`
- `aux=date_launched`

### Request de info

Parametros usados:

- `id=<lista de ids>`
- `aux=urls,logo,description,date_launched`

### Request de assets

Parametros usados:

- `id=<exchangeID>`

## Configuracao

### AppConfig

`AppConfig.load()` carrega:

- `apiKey`
- `baseURL`
- `requestTimeout`

Prioridade da API key:

1. Variavel de ambiente `CMC_API_KEY`
2. Valor expandido do `Info.plist`

O carregamento ignora valores vazios e placeholders como `$(...)`.

### Base URL atual

No estado atual do codigo, a `baseURL` esta definida como:

- `https://sandbox-api.coinmarketcap.com`

A URL de producao existe no arquivo, mas esta comentada:

- `https://pro-api.coinmarketcap.com`

Isso significa que, no estado atual do projeto, a documentacao correta e que o app esta configurado para sandbox.

### Info.plist e xcconfig

O `ProjectConfig/Info.plist` injeta:

- `CMC_API_KEY = $(CMC_API_KEY)`

Ja `ProjectConfig/Config.xcconfig` e a fonte esperada para a chave local.

### Ponto de atencao importante

Durante a analise foi encontrado um valor concreto em `ProjectConfig/Config.xcconfig`. Em um repositorio real, a recomendacao e:

- nao versionar chaves reais
- mover a chave para configuracao local fora do repositorio
- manter apenas placeholder ou exemplo seguro

## Networking

### HTTPClient

`HTTPClient` define um contrato simples:

- enviar `APIRequest`
- receber `Data`
- depender de `AppConfig`

### URLSessionHTTPClient

Implementacao concreta com `URLSession`.

Responsabilidades:

- validar existencia da API key
- montar a URL com `baseURL` + `path` + query items
- configurar headers
- executar request assincrona
- mapear status codes para `NetworkError`

Headers padrao:

- `X-CMC_PRO_API_KEY`
- `Accept: application/json`

### Tratamento de erros

Erros previstos:

- `missingAPIKey`
- `invalidURL`
- `offline`
- `timeout`
- `rateLimited`
- `httpStatus`
- `decoding`
- `unexpected`

Mapeamentos importantes:

- `429` vira `rateLimited`
- `NSURLErrorNotConnectedToInternet` vira `offline`
- `NSURLErrorTimedOut` vira `timeout`

Quando possivel, a resposta de erro da CoinMarketCap e decodificada para extrair `error_message` ou `notice`.

## Parsing e DTOs

### Decoder customizado

`CMCDecoder.make()` usa `JSONDecoder` com estrategia customizada para datas ISO8601:

- com fractional seconds
- sem fractional seconds

Isso aumenta a resiliencia porque a API pode retornar datas em mais de um formato.

### DTOs principais

- `CMCResponseDTO<DataType>`
- `CMCStatusDTO`
- `ExchangeListingDTO`
- `ExchangeInfoDTO`
- `ExchangeAssetDTO`

### Mapeamentos relevantes

`ExchangeListingDTO`:

- expõe `spotVolumeUSD` a partir de `quote["USD"]?.volume24h`

`ExchangeAssetDTO`:

- monta `assetID` combinando `crypto_id` e `wallet_address`

## Repositories

### LiveExchangesRepository

Implementacao de producao.

Responsavel por:

- orquestrar multiplas chamadas de service
- combinar resultados
- mapear DTOs para entidades de dominio
- ordenar dados para a apresentacao

Regras de negocio importantes:

- na lista, ordenar por `spotVolumeUSD` decrescente
- na falta de volume, ordenar por nome
- no detalhe, ordenar assets por `currencyName`
- falhar com `NetworkError.unexpected` se `fetchInfo(ids:)` nao retornar a exchange esperada

### PreviewExchangesRepository

Implementacao local para preview e desenvolvimento.

Utilidades:

- acelerar desenvolvimento de UI
- permitir navegacao sem rede
- gerar uma base previsivel para previews

## Componentes Compartilhados

### Formatters

Centraliza formatacao de:

- datas da API
- moeda USD
- taxas percentuais
- datas de exibicao

Observacao:

- `formattedFeePercent` apenas adiciona `%` ao valor decimal formatado; ele nao converte `0.02` em `2%`, entao `0.02` aparece como `0.02%`

### RemoteImageView

Encapsula `AsyncImage` com:

- placeholder durante carregamento
- fallback com icone em caso de falha
- clipping e background padronizados

### ScreenStateView

Componente generico para estados vazios e de erro com CTA opcional.

## Testes

### Testes unitarios

Cobertura atual encontrada:

- `AppConfigTests`
- `URLSessionHTTPClientTests`
- `CMCDTOParsingTests`
- `LiveExchangesRepositoryTests`
- `PreviewExchangesRepositoryTests`
- `FormattingTests`

O que eles validam:

- prioridade e normalizacao da API key
- mapeamento de erros HTTP e de conectividade
- parsing dos DTOs principais
- ordenacao e mapeamento do repository
- consistencia do repositório preview
- comportamento basico de formatacao

### Testes de UI

Arquivo principal:

- `DesafioUITests/Flows/ExchangeFlowUITests.swift`

Cenarios cobertos:

- fluxo feliz abrindo detalhe e visualizando assets
- estado de erro com botao de retry
- estado vazio com botao de retry

Os testes de UI dependem de `launchArguments` para escolher cenarios stubados, sem dependencia da API real.

## Acessibilidade e testabilidade

O projeto foi preparado com varios `accessibilityIdentifier`, o que traz dois ganhos:

- UI tests mais estaveis
- interface mais facil de instrumentar e validar

Exemplos:

- `exchanges_list_root`
- `exchange_cell_<id>`
- `exchange_detail_title`
- `exchange_assets_list`
- `retry_button`

## Como executar

### Pelo Xcode

1. Abrir `Desafio.xcodeproj`
2. Configurar `CMC_API_KEY`
3. Rodar o scheme `Desafio`

### Pela linha de comando

Comandos previstos pelo projeto:

```bash
xcodebuild -scheme Desafio -destination 'generic/platform=iOS Simulator' build
xcodebuild -scheme Desafio -destination 'platform=iOS Simulator,name=iPhone 16' test
```

Observacao da analise:

- nesta maquina, `xcodebuild` nao estava disponivel via instalacao completa do Xcode no momento da verificacao; o ambiente ativo apontava para `CommandLineTools`, entao eu nao consegui validar build ou testes daqui.

## Decisoes tecnicas positivas

- Separacao de camadas simples e clara
- `HTTPClient` desacoplado e facil de testar
- Repositories com responsabilidade objetiva
- Uso de `async/await`
- Cenarios stubados para UI test
- `accessibilityIdentifier` bem distribuido
- Parsing de datas resiliente

## Pontos de atencao e melhorias futuras

### 1. API key versionada

Existe indicio de chave concreta em arquivo de configuracao local versionado. Isso deve ser removido para evitar vazamento de credenciais.

### 2. URL de sandbox como default

Se o objetivo for operar com dados reais, o projeto hoje esta configurado para `sandbox`. Vale confirmar se isso e intencional.

### 3. Estado `empty` no detalhe

O `ExchangeDetailViewModel` possui `empty`, mas o fluxo atual nao o utiliza. Isso nao quebra o app, mas pode gerar ambiguidade de manutencao.

### 4. Formatacao de fee

As fees sao exibidas como `0.02%` em vez de `2%`. Isso pode ou nao estar correto dependendo do contrato esperado com a API. Vale validar regra de negocio.

### 5. Cobertura de testes de ViewModel

Nao encontrei testes dedicados para:

- `ExchangesListViewModel`
- `ExchangeDetailViewModel`

Adicionar esses testes ajudaria a blindar transicoes de estado.

### 6. Paginacao

A listagem usa `limit=30` fixo e nao implementa paginacao. Se o produto crescer, esse pode ser um proximo passo.

## Resumo Executivo

O projeto esta bem organizado, com boa separacao entre UI, dominio, dados e infraestrutura. A implementacao atual atende bem a um desafio tecnico ou app de porte pequeno, com foco em clareza, testabilidade e manutencao.

Os pontos mais importantes identificados na analise foram:

- arquitetura coerente e facil de evoluir
- fluxo de dados simples e bem dividido
- testes cobrindo os principais contratos tecnicos
- configuracao atual apontando para sandbox
- presenca de possivel credencial real em arquivo versionado

Se a proxima etapa for evolucao do projeto, os melhores candidatos sao:

- higienizacao de segredos
- confirmacao de ambiente sandbox vs producao
- mais testes de `ViewModel`
- revisao da regra de exibicao de fees

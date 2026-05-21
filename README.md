# Bitcoin.iOS

Aplicativo iOS nativo em `SwiftUI` para listar exchanges e exibir o detalhe de cada uma usando a `CoinMarketCap API`.

## Resumo rapido

- Arquitetura baseada em `MVVM + Repository + Service`
- Lista de exchanges com `loading`, `empty`, `error` e `refresh`
- Tela de detalhe com metadata e assets
- Networking testavel com `HTTPClient`
- Testes unitarios e testes de UI com cenarios stubados

## Estrutura principal

- `Desafio/App`: inicializacao, configuracao e injecao de dependencias
- `Desafio/Domain`: entidades e contratos
- `Desafio/Data`: repositories, services e DTOs
- `Desafio/Networking`: cliente HTTP, requests, decoder e erros
- `Desafio/Features`: telas e view models
- `Desafio/UIComponents`: componentes reutilizaveis
- `DesafioTests`: testes unitarios
- `DesafioUITests`: testes de interface

## Configuracao da API key

Defina `CMC_API_KEY` por um destes caminhos:

1. Em `ProjectConfig/Config.xcconfig`
2. Nas variaveis de ambiente do Scheme

O app le o valor expandido no `Info.plist` e faz fallback para a variavel de ambiente do processo.

## Execucao

Abra `Desafio.xcodeproj` no Xcode e rode o scheme `Desafio`.

Comandos esperados:

```bash
xcodebuild -scheme Desafio -destination 'generic/platform=iOS Simulator' build
xcodebuild -scheme Desafio -destination 'platform=iOS Simulator,name=iPhone 16' test
```

## Documentacao detalhada

A analise detalhada do projeto, incluindo arquitetura, fluxo de dados, camadas, testes, configuracao e pontos de atencao, esta em:

- `docs/PROJECT_DOCUMENTATION.md`

## SDD

A especificacao de engenharia de software no formato `Spec-Driven Development` esta em:

- `docs/SDD_SPEC.md`

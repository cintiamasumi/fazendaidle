# Fazenda Idle

Arquitetura inicial de um projeto Godot 4 para um jogo de fazenda idle com vista isometrica, grid fixo, producao offline e foco em escalabilidade.

## Objetivo desta base

Esta estrutura define:

- organizacao de pastas
- fronteiras entre cenas, modelos, managers e systems
- entidades centrais do dominio
- fluxo de dados do jogo
- convencoes de nomenclatura

Esta base nao implementa:

- regras de negocio
- plantio
- interface de usuario funcional
- automacao jogavel

## Estrutura do projeto

```text
godot/
├── assets/
│   └── .gitkeep
├── resources/
│   └── .gitkeep
├── saves/
│   └── .gitkeep
├── scenes/
│   ├── farm/
│   │   └── FarmRoot.tscn
│   ├── main/
│   │   └── Main.tscn
│   ├── plot/
│   │   └── Plot.tscn
│   └── ui/
│       └── UIRoot.tscn
└── scripts/
    ├── managers/
    │   ├── game_manager.gd
    │   ├── offline_manager.gd
    │   ├── save_manager.gd
    │   └── time_manager.gd
    ├── models/
    │   ├── building_model.gd
    │   ├── crop_model.gd
    │   ├── farm_model.gd
    │   ├── inventory_model.gd
    │   ├── player_model.gd
    │   ├── plot_model.gd
    │   └── save_data.gd
    └── systems/
        ├── automation_system.gd
        ├── entity_factory.gd
        ├── expansion_system.gd
        ├── grid_system.gd
        └── production_system.gd
```

## Estrutura das cenas

### `Main.tscn`

Cena raiz da aplicacao.

Responsabilidades:

- iniciar o fluxo principal do jogo
- compor os blocos principais da aplicacao
- servir como ponto de entrada para bootstrap futuro

Composicao esperada:

- `GameManagerHost`
- `FarmRoot`
- `UIRoot`

### `FarmRoot.tscn`

Cena raiz do mapa da fazenda.

Responsabilidades:

- conter a representacao visual da fazenda
- integrar grid, plots e futuras camadas visuais
- receber dados do dominio sem concentrar regra de negocio

### `Plot.tscn`

Cena base de um tile/terreno do grid.

Responsabilidades:

- representar um lote individual no mapa
- desacoplar a visualizacao do `PlotModel`
- permitir expansao futura para estados visuais de terreno, construcao e cultivo

### `UIRoot.tscn`

Raiz da camada de UI.

Responsabilidades:

- centralizar HUD, paineis, modais e overlays no futuro
- manter a UI desacoplada da simulacao

## Camadas da arquitetura

### `scenes/`

Camada de composicao visual e hierarquia de nodes.

- nao deve concentrar regras de negocio
- deve reagir a dados e sinais

### `scripts/models/`

Camada de dados do dominio.

- representa entidades persistiveis
- concentra estrutura de estado, nao comportamento complexo
- ideal para `Resource` quando fizer sentido serializar/configurar no editor

### `scripts/managers/`

Camada de orquestracao de ciclo de vida.

- coordena inicializacao
- integra persistencia
- controla tempo global e processamento offline

### `scripts/systems/`

Camada de regras transversais do jogo.

- opera sobre models
- encapsula logicas de simulacao por responsabilidade
- evita espalhar regras entre cenas

## Responsabilidades dos scripts

### Managers

- `game_manager.gd`: ponto central de bootstrap, referencia de estado global e orquestracao entre managers e systems.
- `save_manager.gd`: leitura, escrita, versionamento e restauracao de `SaveData`.
- `time_manager.gd`: tempo de sessao, ticks, delta acumulado e abstracao de relogio do jogo.
- `offline_manager.gd`: calcula janela offline e delega simulacao retroativa aos systems adequados.

### Models

- `player_model.gd`: dados do jogador, progresso e referencias principais da conta.
- `farm_model.gd`: estado agregado da fazenda, plots desbloqueados e dados estruturais.
- `plot_model.gd`: estado de um lote individual do grid.
- `crop_model.gd`: definicao de cultivo ou instancia de estado de cultivo, conforme evolucao do projeto.
- `building_model.gd`: dados de construcoes e automacoes alocadas no mapa.
- `inventory_model.gd`: recursos, itens e moedas do jogador.
- `save_data.gd`: snapshot raiz persistido em disco, contendo os agregados necessarios para restaurar o jogo.

### Systems

- `grid_system.gd`: coordenadas, conversoes logicas do grid e suporte a vista isometrica.
- `production_system.gd`: ponto de extensao para simulacao de producao e processamento por tick.
- `expansion_system.gd`: regras de desbloqueio de area e evolucao do terreno.
- `automation_system.gd`: processamento de estruturas automatizadas e seus efeitos futuros.
- `entity_factory.gd`: criacao padronizada de models e instancias base do dominio.

## Fluxo de dados do jogo

```text
Boot da aplicacao
-> Main
-> GameManager
-> SaveManager carrega SaveData
-> GameManager distribui models para Systems
-> FarmRoot recebe estado projetado da Farm
-> Plot scenes representam PlotModel
-> TimeManager fornece ticks e delta de simulacao
-> Systems processam estado
-> Models sao atualizados
-> SaveManager persiste snapshots
```

### Diretriz de fluxo

- `Managers` orquestram.
- `Systems` processam.
- `Models` armazenam estado.
- `Scenes` exibem ou compoem nodes.

Evite:

- cena escrevendo direto em save
- system acessando node visual sem mediacao
- model conhecendo detalhes de UI

## Entidades sugeridas

### `Player`

- identidade do jogador
- progresso global
- referencia para `Inventory` e `Farm`

### `Farm`

- agregado principal do jogo
- conjunto de plots
- metadados de expansao

### `Plot`

- coordenada fixa no grid
- estado de desbloqueio
- ocupacao atual

### `Crop`

- definicao ou estado de cultivo
- metadados para crescimento e producao futura

### `Building`

- estruturas produtivas ou de suporte
- base para automacao futura

### `Inventory`

- itens, moedas e recursos acumulados

### `SaveData`

- snapshot raiz persistido
- inclui versao, timestamps e agregados restauraveis

## Convencoes de nomenclatura

### Arquivos

- cenas: `PascalCase.tscn`
- scripts: `snake_case.gd`
- recursos customizados: `snake_case.tres` ou `PascalCase.tres`, desde que o time mantenha um unico padrao por categoria

### Classes

- `class_name` em `PascalCase`

### Nodes

- nomes de nodes em `PascalCase`
- nodes estruturais terminando com papeis claros, como `FarmRoot`, `PlotContainer`, `GameManagerHost`

### Variaveis e funcoes

- `snake_case`

### Constantes

- `UPPER_SNAKE_CASE`

### Sinais

- nomeados por evento em `snake_case`
- exemplos: `save_requested`, `farm_loaded`, `tick_processed`

## Diretrizes de escalabilidade

- manter persistencia isolada em `SaveManager`
- concentrar simulacao offline em servicos dedicados
- impedir acoplamento direto entre UI e dominio
- tratar `Farm` como agregado principal do jogo
- introduzir `Resources` de configuracao para crops e buildings antes de expandir conteudo
- preparar export Web primeiro, mantendo caminhos de save e serializacao portaveis para mobile depois

## Proximos passos recomendados

1. Criar `project.godot` e registrar `Main.tscn` como cena inicial.
2. Definir autoloads apenas quando o fluxo estiver claro.
3. Escolher formato de persistencia inicial, como JSON ou `ResourceSaver`.
4. Separar dados configuraveis de estado salvo antes de implementar conteudo.

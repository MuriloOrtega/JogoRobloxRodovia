# Império da Rodovia — Tycoon v16

Primeira versão jogável criada em Luau. O mapa inteiro é montado por código ao iniciar.

## O que já funciona

- Estrada, praça de pedágio, cabines e veículos gerados automaticamente.
- Moedas concedidas sempre que um veículo passa pela praça.
- Melhoria do pedágio: cada nível aumenta a renda por veículo.
- Interface adaptável para computador e celular.
- Salvamento de moedas e nível com DataStore.
- Ranking nativo de moedas.
- Game Pass de moedas em dobro preparado.
- Developer Product de 1.000 moedas preparado.
- Validação de compras e melhorias no servidor.
- Carros, ônibus e caminhões com tarifas diferentes.
- Rodas, faróis, janelas, cobertura e iluminação aprimorada.
- Cancelas animadas que abrem e fecham para os veículos.
- Aviso na interface indicando veículo e tarifa recebida.
- Praça evolutiva pelo maior nível online: improvisada, regional, moderna e premium.
- Árvores, montanhas, placas e guarda-corpos no cenário.
- Retrovisores, spoiler, escapamento com fumaça e reboque.
- Novos veículos: moto e van.
- Prévia automática dos quatro estágios durante testes no Roblox Studio.
- Indicador permanente do estágio atual da praça.
- Iluminação cinematográfica, atmosfera, relevo suave e postes rodoviários.
- Carrocerias curvas e para-brisas inclinados.
- Correção das carrocerias com malhas elipsoidais, sem esferas gigantes.
- Placas físicas sem sobreposição de textos flutuantes.
- Árvores orgânicas e montanhas feitas apenas com terreno suave.
- Veículos low-poly redesenhados sem esferas ou cápsulas.
- Movimento do veículo como modelo único, mantendo rodas e detalhes unidos.
- Brilho da iluminação reduzido para evitar áreas estouradas.
- Cada jogador recebe um terreno e império próprios.
- Até quatro rodovias independentes por jogador.
- Compra progressiva de rodovias, tarifa e fluxo de veículos.
- Custos exponenciais para sustentar uma progressão longa.
- Migração automática de moedas e nível do sistema anterior.
- Torre de controle individual com visão panorâmica ativada pela interface.
- Limite expandido para cinco rodovias por jogador.
- Novas melhorias de qualidade operacional e automação.
- Interface compacta com escala automática para celulares.
- Torre movida para fora das pistas e terreno ampliado.
- Câmera panorâmica elevada para enquadrar as cinco rodovias.
- Veículos redimensionados para permanecer dentro das faixas.
- Sistema de incidentes em cabines, sensores e cancelas.
- Mini puzzle de protocolo de manutenção em três etapas.
- Qualidade reduz falhas e acelera a manutenção; automação melhora o fluxo da cobrança.
- Custos e multiplicadores revisados com funções claras para cada melhoria.
- Cancelas animadas em todas as rodovias, com sinal vermelho, verde e falha.
- Botões redesenhados com gradientes, contornos, animações e ícones.
- Valores abreviados em K, M e B e estado visual desativado.
- Painel de gestão recolhível com abertura e fechamento animados.
- Controle de visão panorâmica separado do painel de melhorias.
- Melhorias separadas: tráfego atrai mais veículos; automação agiliza a cobrança e esvazia filas mais rápido.
- Suporte a controle: Y abre a gestão, X alterna a visão panorâmica, A confirma e B volta; botões e minipuzzle possuem navegação e destaque de seleção.
- Central Administrativa com passes permanentes e produtos repetíveis; RB abre a loja no console.
- Placas dos jogadores corrigidas, com texto centralizado e legível nas duas faces largas.
- Missões diárias de veículos, arrecadação e manutenção.
- Evolução visual em quatro estágios conforme as melhorias.
- Decisões operacionais ativas: emergência, evasão e revisão manual.
- Quatro regiões e prestígio com bônus permanente de receita.
- Ambientação brasileira com placas BR-101, árvores, atmosfera e ciclo de dia/noite.

## Configurar a monetização

Crie os passes e produtos no Creator Dashboard em `Monetization`, copie cada `Asset ID` e substitua os zeros de `src/shared/Config.lua`. Ofertas com ID zero ficam desativadas e não causam erro.
- Cancelas posicionadas diante das cabines; falhas fecham a pista e criam filas de trânsito até o reparo.
- Cada rodovia possui duas faixas de aproximação que afunilam na cabine e se abrem novamente após a cobrança.

## Opção 1 — abrir com Rojo (recomendada)

1. Instale o Roblox Studio.
2. Instale o Rojo: https://rojo.space/docs/v7/getting-started/installation/
3. Instale o plugin Rojo no Roblox Studio.
4. Abra esta pasta no VS Code.
5. No terminal, execute `rojo serve`.
6. No Studio, crie um mapa Baseplate, abra o plugin Rojo e conecte em `localhost:34872`.
7. Clique em Play para testar.

## Opção 2 — copiar diretamente no Studio

Crie esta estrutura no Explorer:

- `ReplicatedStorage > Shared > ModuleScript` chamado `Config`.
- `ServerScriptService > Script` chamado `Main`.
- `StarterPlayer > StarterPlayerScripts > LocalScript` chamado `UI`.

Copie o conteúdo dos arquivos correspondentes da pasta `src` para cada script.

## Ativar o salvamento

1. Publique o jogo em `File > Publish to Roblox`.
2. Abra `Game Settings > Security`.
3. Ative `Enable Studio Access to API Services` apenas na cópia de teste.

O jogo publicado salva normalmente. Para evitar alterar dados reais durante testes, use uma experiência separada para desenvolvimento.

## Ativar monetização

No Creator Dashboard, abra sua experiência:

1. Crie um Game Pass chamado `Moedas em dobro`.
2. Crie um Developer Product chamado `Pacote de 1.000 moedas`.
3. Copie os IDs gerados.
4. Abra `src/shared/Config.lua`.
5. Substitua `DOUBLE_COINS_PASS_ID = 0` e `COINS_PRODUCT_ID = 0` pelos IDs.

Enquanto os IDs estiverem em zero, nenhuma compra real será exibida.

## Próximas melhorias sugeridas

- Cada jogador ter sua própria praça.
- Caminhões, ônibus e veículos raros.
- Funcionários e cabines automáticas.
- Missões diárias e recompensas por retorno.
- Sons, animações e efeitos.
- Tutorial inicial e sistema de renascimento/prestígio.

## Segurança

As compras de melhorias e o recebimento de produtos são processados no servidor. Nunca conceda moedas pagas apenas por um LocalScript.

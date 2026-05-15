# Mini Box Ferreira - Frontend

Este é o projeto frontend desenvolvido em Flutter para o **Mini Box Ferreira**, um mercadinho local situado no Jardim Redentor. O aplicativo foi concebido para fortalecer o comércio do bairro, oferecendo uma ponte digital entre o estabelecimento e os moradores.

## 🎯 Proposta do Projeto

A ideia central é permitir que as pessoas do bairro possam visualizar o estoque e fazer a **reserva de itens** existentes fisicamente na loja. Assim, o cliente garante a reserva dos seus produtos favoritos e pode realizar a compra efetiva de forma presencial no mercado, otimizando o seu tempo.

## 🚀 Como Iniciar

Siga os passos abaixo para configurar e executar o projeto em sua máquina local:

1. **Pré-requisitos**: Certifique-se de ter o [Flutter SDK](https://docs.flutter.dev/get-started/install) instalado e configurado (versão estável mais recente).
2. **Instalação de Dependências**: Na raiz do projeto, execute o comando para baixar os pacotes necessários:
   ```bash
   flutter pub get
   ```
3. **Configuração da API**: Verifique o arquivo `lib/core/api_constants.dart` para garantir que a URL base da API está apontando para o endereço correto (ex: `http://localhost:3003`).
4. **Execução**: Com um emulador ou dispositivo conectado, execute:
   ```bash
   flutter run
   ```

## 🛠 Tecnologias Utilizadas

O projeto utiliza tecnologias modernas do ecossistema Flutter:

- **Flutter & Dart**: Framework e linguagem base.
- **Provider**: Gerenciamento de estado reativa.
- **HTTP & Http Parser**: Comunicação com a API REST.
- **JWT Decoder**: Gerenciamento de tokens e sessões.
- **Shared Preferences**: Armazenamento local de dados.
- **Image Picker & Cached Network Image**: Tratamento e exibição de imagens.
- **Shimmer & Intl**: Melhorias de UX e formatação de dados brasileiros.

## 📋 Funcionalidades Principais

### 🔐 Acesso ao Cliente
- Login e cadastro personalizado para os moradores do Jardim Redentor.
- Visualização da marca **Mini Box Ferreira** já na tela de entrada.

### 📦 Catálogo de Reservas
- Listagem completa de produtos disponíveis no mercadinho.
- Detalhamento de preços e imagens dos itens.
- Sistema de carrinho para gerenciar a lista de reserva antes de confirmar.

### 🏬 Gestão Administrativa
- Painel para o dono do Mini Box Ferreira gerenciar produtos e estoques.
- Cadastro e edição de empresas parceiras (fornecedores).
- Acompanhamento das solicitações de reserva feitas pelos clientes.

### 🔔 Comunicação
- Notificações sobre confirmação de reservas ou novos itens disponíveis.

---
Desenvolvido como parte do projeto P-I 5º Semestre - Focado no desenvolvimento local e apoio ao comércio de bairro.

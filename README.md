# Meu Coração - Módulo de Adesão Medicamentosa

Aplicativo mobile desenvolvido em **Flutter** para acompanhamento pós-operatório e monitoramento de adesão medicamentosa de pacientes cardiopatas, com integração ao backend **Supabase**.

Este projeto dá continuidade à versão legada desenvolvida em React Native/Firebase, agora com arquitetura refatorada para atendimento aos critérios de conformidade da LGPD e evolução dos módulos de pesquisa clínica (FAPERGS).

---

## 🛠 Tecnologias Utilizadas

- **Linguagem:** Dart
- **Framework Mobile:** Flutter (Android & iOS)
- **Backend & Autenticação:** Supabase
- **Notificações:** Flutter Local Notifications / Firebase Cloud Messaging (Push)

---

## 📂 Estrutura do Projeto (`lib/`)

- `core/`: Configurações centrais, instâncias de serviços e temas globais.
- `models/`: Entidades de dados tipadas (Paciente, Medicamento, Registros).
- `routes/`: Definição de rotas, navegação e controle de acesso (Paciente x Profissional).
- `shared_widgets/`: Componentes visuais reutilizáveis em múltiplos módulos.
- `modules/`: Telas e lógicas de negócio particionadas por funcionalidade (Autenticação, Paciente e Profissional da Saúde).

---

## Como Executar o Projeto

### Pré-requisitos
- Flutter SDK (versão estável mais recente)
- Emulador Android / Dispositivo físico com depuração USB habilitada
- Conta/Projeto configurado no Supabase

### Instalação

1. Clone o repositório:
   ```bash
   git clone <URL_DO_REPOSITORIO>
   cd meu_coracao
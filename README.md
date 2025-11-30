# 💰 Sistema de Gestão Financeira Pessoal

Aplicação completa para controle financeiro pessoal, composta por:

- **Backend (API REST)** desenvolvido em **Delphi + Horse**
- **Banco de dados SQLite**
- **Frontend Web** em **HTML + CSS + JavaScript**
- Arquitetura simples, modular e ideal para estudos de APIs, integração e organização de projetos.

Este projeto faz parte de um **protótipo acadêmico**, mas com implementação prática e funcional.

---

## 📌 Funcionalidades Principais

### ✔ Cadastro de Contas  
### ✔ Cadastro de Categorias  
### ✔ Registro de Lançamentos  
### ✔ Dashboard Financeiro  
### ✔ API REST organizada por camadas  
### ✔ Conexão configurável via `config.ini`  
### ✔ Comunicação FrontEnd ↔ API via Fetch

---

## 📁 Estrutura do Projeto

```text
System_GestaoFinanceira/
├─ FrontEnd/
│  ├─ index.html
│  ├─ css/
│  │  └─ styles.css
│  └─ js/
│     ├─ api.js
│     └─ app.js
│
├─ src/
│  ├─ uServer.pas
│  ├─ uConfig.pas
│  ├─ uDB.pas
│  ├─ uAccountsController.pas
│  ├─ uCategoriesController.pas
│  ├─ uLancamentosController.pas
│  ├─ uHealthController.pas
│  ├─ uAccountRepo.pas
│  ├─ uCategoryRepo.pas
│  ├─ uLancamentoRepo.pas
│  └─ ...
│
├─ db/
│  └─ financeiro.db
│
├─ config.ini
├─ PI_Financas_API.dpr
└─ README.md
```

---

## 🧠 Arquitetura do Projeto

### 🔹 Backend (API Delphi + Horse)
A API segue uma arquitetura limpa com três camadas principais:

- **Controllers** → recebem requisições HTTP e retornam JSON  
- **Repositories** → acesso ao banco SQLite + regras de negócio  
- **DB Manager** → conexão centralizada usando FireDAC  
- **Config Manager** → leitura do arquivo `config.ini`

Tecnologias utilizadas:

- Delphi 12  
- Horse Framework  
- FireDAC  
- SQLite  

---

## 🌐 Rotas da API

### 🔹 Health Check
```
GET /api/health
```

---

### 🔹 Accounts
```
GET  /api/accounts
POST /api/accounts
```

**Exemplo de Body:**
```json
{
  "id_usuario": 1,
  "nome_conta": "Conta X",
  "saldo_inicial": 100.00
}
```

---

### 🔹 Categories
```
GET  /api/categories
POST /api/categories
```

**Body:**
```json
{
  "id_usuario": 1,
  "descricao": "Salário",
  "tipo": "R"
}
```

---

### 🔹 Lancamentos
```
GET /api/lancamentos?conta=ID&data_inicio=AAAAMMDD&data_fim=AAAAMMDD
POST /api/lancamentos
```

**Body:**
```json
{
  "id_conta": 1,
  "id_categoria": 3,
  "tipo": "D",
  "valor": 200.00,
  "data_lancamento": "2025-01-15",
  "descricao": "Supermercado"
}
```

---

## 🖥 FrontEnd

O cliente web utiliza:

- HTML5  
- Bootstrap  
- JavaScript puro  
- Consumo da API via `fetch()`  
- SPA simples com seções alternáveis

### Principais arquivos

#### `index.html`
Interface completa com navbar + seções de:
- Dashboard
- Contas
- Categorias
- Lançamentos

#### `api.js`
- Funções GET/POST usando `fetch()`
- Métodos específicos da API:
  - getAccounts()
  - getCategories()
  - getLancamentos()
  - createAccount()
  - createCategory()
  - createLancamento()

#### `app.js`
- Navegação entre seções
- Preenchimento das tabelas
- Validação de formulários
- Atualização do dashboard

---

## ⚙️ Configuração do Servidor

O servidor é configurado externamente pelo arquivo `config.ini`:

```ini
[server]
port=9000

[database]
path=C:\...\db\financeiro.db
```

---

## ▶️ Como Executar o Projeto

### 🔹 1. Iniciar o Backend (API Delphi)
Abra o projeto:

```
PI_Financas_API.dpr
```

E execute (F9).

---

### 🔹 2. Iniciar o FrontEnd
Basta abrir:

```
FrontEnd/index.html
```

ou usar Live Server do VSCode.

---

## 🧪 Testes Básicos

- Criar conta  
- Criar categoria  
- Registrar lançamento  
- Usar filtros no dashboard  
- Validar totais de receitas e despesas  

---

## 🚀 Roadmap – Melhorias Futuras

- [ ] Autenticação (JWT ou API-Key)  
- [ ] Edição de registros  
- [ ] Exclusão de registros  
- [ ] Relatórios (PDF/Excel)  
- [ ] Dashboard com gráficos  
- [ ] Modo escuro (Dark Mode)  
- [ ] Multiusuário completo  

---

## 📄 Licença
Projeto acadêmico. Uso livre para estudos.

---

### ✨ Desenvolvido por **José Ziliotto**

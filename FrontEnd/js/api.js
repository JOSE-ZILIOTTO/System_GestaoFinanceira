
const API_BASE_URL = "http://localhost:9000/api";


const USER_ID = 1;

async function apiGet(path) {
  const resp = await fetch(`${API_BASE_URL}${path}`);
  if (!resp.ok) {
    throw new Error(`Erro na API (GET ${path}): ${resp.status}`);
  }
  return resp.json();
}

async function apiPost(path, body) {
  const resp = await fetch(`${API_BASE_URL}${path}`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
    },
    body: JSON.stringify(body),
  });

  
  const text = await resp.text();
  let data = null;
  try {
    data = JSON.parse(text);
  } catch {
    data = { raw: text };
  }

  if (!resp.ok) {
    const msg = data.message || text || `Erro na API (POST ${path})`;
    throw new Error(msg);
  }

  return data;
}

// Contas
async function getAccounts() {
  return apiGet("/accounts");
}

async function createAccount(nome, saldoInicial) {
  return apiPost("/accounts", {
    id_usuario: USER_ID,
    nome_conta: nome,
    saldo_inicial: saldoInicial,
  });
}

// Categorias
async function getCategories() {
  return apiGet("/categories");
}

async function createCategory(descricao, tipo) {
  return apiPost("/categories", {
    id_usuario: USER_ID,
    descricao: descricao,
    tipo: tipo, // 'R' ou 'D'
  });
}

// Lançamentos
async function getLancamentos(contaId, dataInicio, dataFim) {
  const params = new URLSearchParams();
  if (contaId) params.append("conta", contaId);
  if (dataInicio) params.append("data_inicio", dataInicio);
  if (dataFim) params.append("data_fim", dataFim);

  const qs = params.toString();
  const path = qs ? `/lancamentos?${qs}` : "/lancamentos";
  return apiGet(path);
}

async function createLancamento(lan) {
  return apiPost("/lancamentos", lan);
}



let contasCache = [];
let categoriasCache = [];

document.addEventListener("DOMContentLoaded", () => {
  configurarNavegacao();
  carregarDadosIniciais();
  configurarFormContas();
  configurarFormCategorias();
  configurarFormLancamentos();
  configurarDashboard();
});


function configurarNavegacao() {
  const links = document.querySelectorAll(".nav-link-section");
  links.forEach((link) => {
    link.addEventListener("click", (e) => {
      e.preventDefault();
      const targetId = link.getAttribute("data-target");
      mostrarSecao(targetId);

      links.forEach((l) => l.classList.remove("active"));
      link.classList.add("active");
    });
  });
}

function mostrarSecao(idSecao) {
  document.querySelectorAll("section").forEach((sec) => {
    sec.classList.remove("section-visible");
    sec.classList.add("section-hidden");
  });

  const sec = document.getElementById(idSecao);
  if (sec) {
    sec.classList.remove("section-hidden");
    sec.classList.add("section-visible");
  }
}


async function carregarDadosIniciais() {
  try {
    await Promise.all([atualizarListaContas(), atualizarListaCategorias()]);
    await atualizarLancamentosTabela();
    preencherCombosLancamento();
    preencherComboDashboard();
  } catch (err) {
    console.error(err);
    alert("Erro ao carregar dados iniciais: " + err.message);
  }
}


function configurarFormContas() {
  const form = document.getElementById("formConta");
  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    const nome = document.getElementById("contaNome").value.trim();
    const saldoStr = document.getElementById("contaSaldoInicial").value;
    const saldo = parseFloat(saldoStr.replace(",", ".")) || 0;

    if (!nome) {
      alert("Informe o nome da conta.");
      return;
    }

    try {
      await createAccount(nome, saldo);
      form.reset();
      await atualizarListaContas();
      preencherCombosLancamento();
      preencherComboDashboard();
      alert("Conta criada com sucesso!");
    } catch (err) {
      alert("Erro ao criar conta: " + err.message);
    }
  });
}

async function atualizarListaContas() {
  contasCache = await getAccounts();
  const tbody = document.getElementById("tblContasBody");
  tbody.innerHTML = "";

  contasCache.forEach((c) => {
    const tr = document.createElement("tr");
    tr.innerHTML = `
      <td>${c.id_conta}</td>
      <td>${c.nome_conta}</td>
      <td>R$ ${c.saldo_inicial.toFixed(2).replace(".", ",")}</td>
    `;
    tbody.appendChild(tr);
  });
}


function configurarFormCategorias() {
  const form = document.getElementById("formCategoria");
  form.addEventListener("submit", async (e) => {
    e.preventDefault();
    const desc = document.getElementById("catDescricao").value.trim();
    const tipo = document.getElementById("catTipo").value;

    if (!desc || !tipo) {
      alert("Preencha a descrição e o tipo da categoria.");
      return;
    }

    try {
      await createCategory(desc, tipo);
      form.reset();
      await atualizarListaCategorias();
      preencherCombosLancamento();
      alert("Categoria criada com sucesso!");
    } catch (err) {
      alert("Erro ao criar categoria: " + err.message);
    }
  });
}

async function atualizarListaCategorias() {
  categoriasCache = await getCategories();
  const tbody = document.getElementById("tblCategoriasBody");
  tbody.innerHTML = "";

  categoriasCache.forEach((cat) => {
    const tipoLabel = cat.tipo === "R" ? "Receita" : "Despesa";
    const tr = document.createElement("tr");
    tr.innerHTML = `
      <td>${cat.id_categoria}</td>
      <td>${cat.descricao}</td>
      <td>${tipoLabel}</td>
    `;
    tbody.appendChild(tr);
  });
}


function configurarFormLancamentos() {
  const form = document.getElementById("formLancamento");
  form.addEventListener("submit", async (e) => {
    e.preventDefault();

    const idConta = parseInt(document.getElementById("lanConta").value);
    const idCategoria = parseInt(
      document.getElementById("lanCategoria").value
    );
    const tipo = document.getElementById("lanTipo").value;
    const valorStr = document.getElementById("lanValor").value;
    const valor = parseFloat(valorStr.replace(",", "."));
    const data = document.getElementById("lanData").value;
    const descricao = document.getElementById("lanDescricao").value.trim();

    if (!idConta || !idCategoria || !tipo || !data || !valor || valor <= 0) {
      alert("Preencha todos os campos obrigatórios com valores válidos.");
      return;
    }

    const payload = {
      id_conta: idConta,
      id_categoria: idCategoria,
      tipo: tipo,
      descricao: descricao,
      valor: valor,
      data_lancamento: data,
    };

    try {
      await createLancamento(payload);
      form.reset();
      await atualizarLancamentosTabela();
      alert("Lançamento criado com sucesso!");
    } catch (err) {
      alert("Erro ao criar lançamento: " + err.message);
    }
  });
}

async function atualizarLancamentosTabela() {
  const lancamentos = await getLancamentos(null, "", "");

  const tbody = document.getElementById("tblLancamentosBody");
  tbody.innerHTML = "";

  lancamentos.forEach((l) => {
    const conta = contasCache.find((c) => c.id_conta === l.id_conta);
    const cat = categoriasCache.find(
      (c) => c.id_categoria === l.id_categoria
    );

    const contaNome = conta ? conta.nome_conta : l.id_conta;
    const catNome = cat ? cat.descricao : l.id_categoria;
    const tipoLabel = l.tipo === "R" ? "Receita" : "Despesa";

    const tr = document.createElement("tr");
    tr.innerHTML = `
      <td>${l.data_lancamento}</td>
      <td>${contaNome}</td>
      <td>${catNome}</td>
      <td>${tipoLabel}</td>
      <td>${l.descricao || ""}</td>
      <td>R$ ${l.valor.toFixed(2).replace(".", ",")}</td>
    `;
    tbody.appendChild(tr);
  });
}

function preencherCombosLancamento() {
  const selConta = document.getElementById("lanConta");
  const selCategoria = document.getElementById("lanCategoria");

  selConta.innerHTML = '<option value="">Selecione...</option>';
  contasCache.forEach((c) => {
    const opt = document.createElement("option");
    opt.value = c.id_conta;
    opt.textContent = c.nome_conta;
    selConta.appendChild(opt);
  });

  selCategoria.innerHTML = '<option value="">Selecione...</option>';
  categoriasCache.forEach((cat) => {
    const opt = document.createElement("option");
    opt.value = cat.id_categoria;
    opt.textContent = `${cat.descricao} (${cat.tipo})`;
    selCategoria.appendChild(opt);
  });
}


function configurarDashboard() {
  document
    .getElementById("btnFiltrarDashboard")
    .addEventListener("click", async () => {
      const contaId = parseInt(
        document.getElementById("dashConta").value || "0"
      );
      const dataInicio = document.getElementById("dashDataInicio").value;
      const dataFim = document.getElementById("dashDataFim").value;

      try {
        const lancs = await getLancamentos(
          contaId || null,
          dataInicio || "",
          dataFim || ""
        );
        atualizarDashboardValores(contaId, lancs);
      } catch (err) {
        alert("Erro ao buscar lançamentos para o dashboard: " + err.message);
      }
    });
}

function preencherComboDashboard() {
  const sel = document.getElementById("dashConta");
  sel.innerHTML = '<option value="">Todas as contas</option>';
  contasCache.forEach((c) => {
    const opt = document.createElement("option");
    opt.value = c.id_conta;
    opt.textContent = c.nome_conta;
    sel.appendChild(opt);
  });
}

function atualizarDashboardValores(contaId, lancs) {
  let totalR = 0;
  let totalD = 0;

  lancs.forEach((l) => {
    if (l.tipo === "R") totalR += l.valor;
    if (l.tipo === "D") totalD += l.valor;
  });

  const saldoPeriodo = totalR - totalD;

  document.getElementById(
    "dashTotalReceitas"
  ).textContent = `R$ ${totalR.toFixed(2).replace(".", ",")}`;
  document.getElementById(
    "dashTotalDespesas"
  ).textContent = `R$ ${totalD.toFixed(2).replace(".", ",")}`;
  document.getElementById(
    "dashSaldoPeriodo"
  ).textContent = `R$ ${saldoPeriodo.toFixed(2).replace(".", ",")}`;
}

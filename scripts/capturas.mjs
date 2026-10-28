// Gera as capturas de ecrã do manual (docs/img) com o Chrome sem janela, pelo protocolo DevTools.
// Uso (Tomcat a correr):  node scripts/capturas.mjs docs/img
// ATENÇÃO: repõe os dados de demonstração e cria dados de exemplo.
// Percorre o AgroGest num Chrome headless (protocolo DevTools) e guarda capturas.
// Uso: node capturas.mjs <pasta-saida>
import { spawn } from 'node:child_process';
import { mkdirSync, writeFileSync, mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';

const SAIDA = process.argv[2];
const B = 'http://localhost:8081/agrogest';
const CHROME = 'C:/Program Files/Google/Chrome/Application/chrome.exe';
const PORTA = 9333;
mkdirSync(SAIDA, { recursive: true });

const perfil = mkdtempSync(join(tmpdir(), 'agrogest-chrome-'));
const chrome = spawn(CHROME, ['--headless=new', `--remote-debugging-port=${PORTA}`, `--user-data-dir=${perfil}`,
  '--no-first-run', '--no-default-browser-check', '--hide-scrollbars', '--lang=pt-PT', 'about:blank'], { stdio: 'ignore' });

const esperar = ms => new Promise(r => setTimeout(r, ms));
let ws, seq = 0;
const pendentes = new Map();
const eventos = [];

async function ligar() {
  for (let i = 0; i < 50; i++) {
    try {
      const alvos = await (await fetch(`http://127.0.0.1:${PORTA}/json`)).json();
      const pagina = alvos.find(t => t.type === 'page');
      if (pagina) return pagina.webSocketDebuggerUrl;
    } catch { /* ainda a arrancar */ }
    await esperar(200);
  }
  throw new Error('Chrome não arrancou');
}

function cmd(method, params = {}) {
  const id = ++seq;
  ws.send(JSON.stringify({ id, method, params }));
  return new Promise((res, rej) => pendentes.set(id, { res, rej }));
}

function esperarEvento(nome, ms = 15000) {
  return new Promise((res, rej) => {
    const t = setTimeout(() => rej(new Error('timeout ' + nome)), ms);
    eventos.push({ nome, cb: p => { clearTimeout(t); res(p); } });
  });
}

async function ir(url) {
  const carregado = esperarEvento('Page.loadEventFired');
  await cmd('Page.navigate', { url: url.startsWith('http') ? url : B + url });
  await carregado;
  await esperar(250);
}

async function js(expr) {
  const r = await cmd('Runtime.evaluate', { expression: expr, awaitPromise: true, returnByValue: true });
  if (r.exceptionDetails) throw new Error(JSON.stringify(r.exceptionDetails));
  return r.result.value;
}

/** Preenche campos {seletor: valor} e submete o formulário do seletor indicado. */
async function preencher(campos, submeter) {
  const expr = `(() => {
    const c = ${JSON.stringify(campos)};
    for (const [s, v] of Object.entries(c)) {
      const e = document.querySelector(s);
      if (!e) throw new Error('não encontrei ' + s);
      e.value = v;
    }
  })()`;
  await js(expr);
  if (submeter) {
    const carregado = esperarEvento('Page.loadEventFired');
    await js(`document.querySelector(${JSON.stringify(submeter)}).click()`);
    await carregado;
    await esperar(250);
  }
}

async function clicar(seletor) {
  const carregado = esperarEvento('Page.loadEventFired');
  await js(`document.querySelector(${JSON.stringify(seletor)}).click()`);
  await carregado;
  await esperar(250);
}

async function largura(w, h = 900, mobile = false) {
  await cmd('Emulation.setDeviceMetricsOverride', { width: w, height: h, deviceScaleFactor: 1, mobile });
}

async function captura(nome, { inteira = true } = {}) {
  const m = await cmd('Page.getLayoutMetrics');
  const altura = Math.min(Math.ceil(m.cssContentSize.height), 4000);
  const params = { format: 'png' };
  if (inteira) {
    params.captureBeyondViewport = true;
    params.clip = { x: 0, y: 0, width: Math.ceil(m.cssLayoutViewport.clientWidth), height: altura, scale: 1 };
  }
  const r = await cmd('Page.captureScreenshot', params);
  writeFileSync(join(SAIDA, nome + '.png'), Buffer.from(r.data, 'base64'));
  const erros = await js(`[...document.querySelectorAll('.alert--error')].map(e => e.textContent.trim()).join(' | ')`);
  console.log(`captura ${nome}.png${erros ? '  [aviso: ' + erros + ']' : ''}`);
}

async function sair() {
  await js(`document.querySelector('form[action$="/logout"]')?.submit()`);
  await esperar(600);
}

async function main() {
  ws = new WebSocket(await ligar());
  await new Promise(r => ws.addEventListener('open', r));
  ws.addEventListener('message', m => {
    const d = JSON.parse(m.data);
    if (d.id && pendentes.has(d.id)) {
      const p = pendentes.get(d.id); pendentes.delete(d.id);
      d.error ? p.rej(new Error(d.error.message)) : p.res(d.result);
    } else if (d.method) {
      for (let i = eventos.length - 1; i >= 0; i--) {
        if (eventos[i].nome === d.method) { eventos.splice(i, 1)[0].cb(d.params); }
      }
    }
  });
  await cmd('Page.enable');
  await cmd('Runtime.enable');
  await largura(1280);
  // Capturas do manual em modo claro, independentemente do tema do Windows
  await cmd('Emulation.setEmulatedMedia', { features: [{ name: 'prefers-color-scheme', value: 'light' }] });

  // ---------------------------------------------------------- administrador
  await ir('/login');
  await captura('01-login');
  await preencher({ 'input[name=email]': 'admin@agro.mz', 'input[name=password]': 'admin234' }, 'button[type=submit]');

  // Repor os dados de demonstração para as capturas baterem com o enunciado
  await ir('/admin/persistencia');
  await js(`document.querySelectorAll('details.confirm')[1].open = true`);
  await clicar('form input[value=repor] ~ button');

  await ir('/admin/dashboard');
  await captura('02-admin-painel');

  await ir('/admin/fornecedores');
  await preencher({ 'input[name=nome]': 'Sementes do Sul, Lda', 'select[name=tipo]': 'SEMENTES',
    'input[name=contacto]': '845551234', 'input[name=provincia]': 'Maputo' }, 'form button.btn--primary');
  await captura('03-admin-fornecedores');

  const validade = new Date(); validade.setMonth(validade.getMonth() + 8);
  await ir('/admin/produtos');
  const fid = await js(`[...document.querySelectorAll('select[name=fornecedorId] option')].find(o => o.textContent.includes('Sementes do Sul')).value`);
  await preencher({ 'input[name=nome]': 'Semente Feijão nhemba', 'select[name=categoria]': 'SEMENTE',
    'select[name=fornecedorId]': fid, 'input[name=preco]': '320', 'input[name=quantidade]': '400',
    'input[name=unidade]': 'kg', 'input[name=validade]': validade.toISOString().slice(0, 10),
    'input[name=fotoUrl]': 'img/produtos/feijao.svg',
    'textarea[name=descricao]': 'Feijão nhemba de ciclo curto, tolerante à seca.' });
  await captura('04-admin-produto-formulario', { inteira: false });
  await clicar('form button.btn--primary');
  await captura('05-admin-produtos');

  await ir('/admin/campanhas');
  await preencher({ 'input[name=nome]': 'Campanha 2026/2027', 'input[name=inicio]': '2026-10-01',
    'input[name=fim]': '2027-06-30' }, 'form button.btn--primary');
  await captura('06-admin-campanhas');

  await ir('/admin/cultivos');
  const cid = await js(`[...document.querySelectorAll('select[name=campanhaId] option')].find(o => o.textContent.includes('2026/2027')).value`);
  await preencher({ 'select[name=campanhaId]': cid, 'input[name=cultura]': 'Feijão nhemba', 'input[name=variedade]': 'Macia',
    'input[name=hectares]': '8', 'input[name=plantio]': '2026-11-15' }, 'form button.btn--primary');
  await captura('07-admin-cultivos');

  await ir('/admin/colheitas');
  const cvid = await js(`[...document.querySelectorAll('select[name=cultivoId] option')].find(o => o.textContent.includes('Macia')).value`);
  await preencher({ 'select[name=cultivoId]': cvid, 'input[name=data]': '2027-03-20', 'input[name=kg]': '3200',
    'input[name=precoKg]': '22' }, 'form button.btn--primary');
  await captura('08-admin-colheitas');

  // Regra: campanha com cultivos não se remove
  await ir('/admin/campanhas');
  await js(`[...document.querySelectorAll('tbody tr')].find(r => r.textContent.includes('2026/2027')).querySelector('details').open = true`);
  await clicar(`tbody tr:first-child details form button`);
  await captura('09-admin-regra-campanha', { inteira: false });

  await ir('/admin/listagens?tipo=produtos&ordem=preco&dir=desc');
  await captura('10-admin-listagem-produtos');
  await ir('/admin/listagens?tipo=armazem&ordem=valor&dir=desc');
  await captura('11-admin-listagem-armazem');
  await ir('/admin/listagens?tipo=clientes&ordem=valor&dir=desc');
  await captura('12-admin-listagem-clientes');
  await ir('/admin/relatorios');
  await captura('13-admin-relatorios');
  await ir('/admin/persistencia');
  await clicar('form input[value=gravar] ~ button');
  await captura('14-admin-persistencia');
  await sair();

  // ---------------------------------------------------------------- cliente
  await ir('/registo');
  await preencher({ 'input[name=nome]': 'João Silva', 'input[name=email]': 'joao@teste.mz',
    'input[name=password]': '1234', 'input[name=confirmacao]': '1234',
    'input[name=telefone]': '847654321', 'input[name=endereco]': 'Av. Eduardo Mondlane, Nampula' });
  await captura('20-cliente-registo');
  // Validação do servidor: desligar a do browser e enviar um telefone inválido
  await js(`document.querySelector('form.form').noValidate = true`);
  await preencher({ 'input[name=telefone]': '881234567', 'input[name=password]': '1234', 'input[name=confirmacao]': '1234' },
    'form button[type=submit]');
  await captura('20b-cliente-registo-erro');
  await preencher({ 'input[name=telefone]': '847654321', 'input[name=password]': '1234', 'input[name=confirmacao]': '1234' });
  await clicar('form button[type=submit]');
  await captura('21-cliente-catalogo');
  await ir('/catalogo?categoria=SEMENTE');
  await captura('22-cliente-catalogo-filtro');

  const idDe = nome => js(`[...document.querySelectorAll('article.product-card')].find(a => a.textContent.includes(${JSON.stringify(nome)})).querySelector('input[name=produtoId]').value`);
  await ir('/catalogo');
  const milho = await idDe('Milho');
  const adubo = await idDe('Adubo');
  await preencher({ [`#qtd-${milho}`]: '3' }, `#qtd-${milho} ~ button`);
  await preencher({ [`#qtd-${adubo}`]: '1' }, `#qtd-${adubo} ~ button`);
  await captura('23-cliente-adicionado', { inteira: false });

  await ir('/carrinho');
  await captura('24-cliente-carrinho');
  // Pedir mais do que o stock: aviso de indisponibilidade
  await preencher({ [`form input[name=produtoId][value="${adubo}"] ~ input[name=quantidade]`]: '5000' },
    `form input[name=produtoId][value="${adubo}"] ~ button`);
  await captura('25-cliente-stock-insuficiente', { inteira: false });

  await ir('/compra');
  await captura('26-cliente-confirmar');
  await clicar('form[action$="/compra"] button');
  await captura('27-cliente-factura');
  const url = await js('location.href');
  await ir(url + '&imprimir=1');
  await captura('28-cliente-factura-imprimir');
  await ir('/minhas-compras');
  await captura('29-cliente-minhas-compras');
  await ir('/admin/dashboard');
  await captura('30-cliente-403', { inteira: false });

  // --------------------------------------------------------------- telemóvel
  await largura(390, 844, true);
  await ir('/catalogo');
  await captura('31-telemovel-catalogo', { inteira: false });
  await js(`document.querySelector('#menu-abrir').checked = true`);
  await esperar(150);
  await captura('32-telemovel-menu', { inteira: false });
  await ir('/carrinho');
  await captura('33-telemovel-carrinho', { inteira: false });

  // ------------------------------------------------------------- modo escuro
  await largura(1280);
  await cmd('Emulation.setEmulatedMedia', { features: [{ name: 'prefers-color-scheme', value: 'dark' }] });
  await ir('/catalogo');
  await captura('40-escuro-catalogo', { inteira: false });
  await ir(url);
  await captura('41-escuro-factura', { inteira: false });
  await sair();
  await ir('/login');
  await preencher({ 'input[name=email]': 'admin@agro.mz', 'input[name=password]': 'admin234' }, 'button[type=submit]');
  await captura('42-escuro-admin-painel', { inteira: false });
  await ir('/admin/produtos');
  await captura('43-escuro-admin-produtos', { inteira: false });
  await largura(390, 844, true);
  await ir('/admin/dashboard');
  await captura('44-telemovel-admin', { inteira: false });

  // ---------------------------------------- defensive CSS: dados extremos
  await largura(1280);
  await cmd('Emulation.setEmulatedMedia', { features: [{ name: 'prefers-color-scheme', value: 'light' }] });
  await ir('/admin/produtos');
  const fid1 = await js(`document.querySelector('select[name=fornecedorId] option:nth-child(2)').value`);
  await preencher({ 'input[name=nome]': 'Fertilizante' + 'Super'.repeat(10) + 'Concentrado', 'select[name=categoria]': 'FERTILIZANTE',
    'select[name=fornecedorId]': fid1, 'input[name=preco]': '99999.99', 'input[name=quantidade]': '3',
    'input[name=unidade]': 'litro',
    'textarea[name=descricao]': 'Descrição muito longa para testar o corte em três linhas. '.repeat(8) }, 'form button.btn--primary');
  await ir('/catalogo?categoria=FERTILIZANTE');
  await captura('45-defensivo-catalogo', { inteira: false });
  await ir('/admin/listagens?tipo=produtos');
  await captura('46-defensivo-tabela', { inteira: false });

  ws.close();
}

main().then(() => { chrome.kill(); process.exit(0); })
      .catch(e => { console.error('ERRO', e); chrome.kill(); process.exit(1); });

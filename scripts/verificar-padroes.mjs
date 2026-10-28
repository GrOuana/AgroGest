// Confirma que os atributos pattern das JSP compilam como no browser (flag v) e dão o resultado esperado.
// Uso: node scripts/verificar-padroes.mjs
// Os padrões exactamente como ficam no atributo pattern das JSP.
const P = {
  telefone: String.raw`^8[2-7]\d{7}$`,
  pessoa: String.raw`^[A-Za-zÀ-ÖØ-öø-ÿ][A-Za-zÀ-ÖØ-öø-ÿ '\-]*$`,
  entidade: String.raw`^[A-Za-zÀ-ÖØ-öø-ÿ][A-Za-zÀ-ÖØ-öø-ÿ .,&'\-]*$`,
  unidade: String.raw`^[A-Za-zÀ-ÖØ-öø-ÿ]{1,20}$`,
  email: String.raw`^[^@\s]+@[^@\s]+\.[^@\s]{2,}$`,
  foto: String.raw`^(https?:\/\/\S+|img\/[\w.\/\-]+)$`,
};
const casos = {
  telefone: [["841234567", true], ["871234567", true], ["881234567", false], ["84123456", false], ["84 123 4567", false], ["+258841234567", false]],
  pessoa: [["João Silva", true], ["Ana Macuácua", true], ["D'Almeida-Cossa", true], ["João 2", false], ["Ana×", false]],
  entidade: [["Sementes do Sul, Lda", true], ["FertiMoz, SA", true], ["A & B Lda.", true], ["Agro 2000", false]],
  unidade: [["kg", true], ["saco", true], ["50kg", false]],
  email: [["joao@teste.mz", true], ["joao@teste", false], ["a b@c.mz", false]],
  foto: [["img/produtos/feijao.svg", true], ["https://exemplo.mz/a.png", true], ["javascript:alert(1)", false], ["img/../x y", false]],
};
let falhas = 0;
for (const [nome, p] of Object.entries(P)) {
  const re = new RegExp(p, "v");   // como o browser compila o atributo pattern
  for (const [v, esperado] of casos[nome]) {
    const ok = re.test(v) === esperado;
    if (!ok) falhas++;
    console.log(`${ok ? "OK   " : "FALHA"} ${nome.padEnd(9)} ${JSON.stringify(v)} -> ${re.test(v)}`);
  }
}
console.log(falhas ? `${falhas} falhas` : "todos os padrões compilam com a flag v e dão o resultado esperado");

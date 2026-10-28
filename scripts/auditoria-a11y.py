"""Auditoria simples de acessibilidade a páginas HTML guardadas (uso: python scripts/auditoria-a11y.py pasta-com-html)."""
import os
import re
import sys
from collections import Counter
from html.parser import HTMLParser


class Auditor(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.ids = []
        self.labels_for = set()
        self.campos = []          # (tag, id, name, type, aria-label, dentro_de_label)
        self.imgs_sem_alt = 0
        self.describedby = []
        self.botoes = []          # textos
        self._botao = None
        self._label_profundidade = 0
        self.titulos = []
        self._titulo = None
        self.lang = None
        self.main = 0
        self.skip = False

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if "id" in a:
            self.ids.append(a["id"])
        if tag == "html":
            self.lang = a.get("lang")
        if tag == "main":
            self.main += 1
        if tag == "a" and "skip-link" in a.get("class", ""):
            self.skip = True
        if tag == "label":
            self._label_profundidade += 1
            if a.get("for"):
                self.labels_for.add(a["for"])
        if tag in ("input", "select", "textarea") and a.get("type") != "hidden":
            self.campos.append((tag, a.get("id"), a.get("name"), a.get("type"), a.get("aria-label"),
                                self._label_profundidade > 0))
        if tag == "img" and "alt" not in a:
            self.imgs_sem_alt += 1
        for x in (a.get("aria-describedby") or "").split():
            self.describedby.append(x)
        if tag in ("button", "summary"):
            self._botao = ""
        if re.fullmatch(r"h[1-6]", tag):
            self._titulo = int(tag[1])

    def handle_endtag(self, tag):
        if tag == "label":
            self._label_profundidade -= 1
        if tag in ("button", "summary") and self._botao is not None:
            self.botoes.append(self._botao.strip())
            self._botao = None
        if self._titulo and re.fullmatch(r"h[1-6]", tag):
            self.titulos.append(self._titulo)
            self._titulo = None

    def handle_data(self, data):
        if self._botao is not None:
            self._botao += data


def auditar(caminho):
    p = Auditor()
    p.feed(open(caminho, encoding="utf-8").read())
    problemas = []
    if not p.lang:
        problemas.append("sem <html lang>")
    if p.main != 1:
        problemas.append(f"{p.main} elementos <main>")
    for i, n in Counter(p.ids).items():
        if n > 1:
            problemas.append(f"id duplicado: {i}")
    for tag, i, nome, tipo, aria, dentro in p.campos:
        if not (aria or dentro or (i and i in p.labels_for)):
            problemas.append(f"{tag} name={nome} sem label")
    if p.imgs_sem_alt:
        problemas.append(f"{p.imgs_sem_alt} <img> sem alt")
    ids = set(p.ids)
    for x in p.describedby:
        if x not in ids:
            problemas.append(f"aria-describedby aponta para id inexistente: {x}")
    for b in p.botoes:
        if not b:
            problemas.append("botão sem texto")
    if p.titulos.count(1) != 1:
        problemas.append(f"{p.titulos.count(1)} <h1>")
    for a, b in zip(p.titulos, p.titulos[1:]):
        if b > a + 1:
            problemas.append(f"salto de título h{a} -> h{b}")
            break
    return problemas, len(p.campos)


pasta = sys.argv[1]
total = 0
for nome in sorted(os.listdir(pasta)):
    problemas, campos = auditar(os.path.join(pasta, nome))
    total += len(problemas)
    estado = "OK " if not problemas else "!! "
    print(f"{estado}{nome:<28} {campos:>2} campos  " + ("; ".join(sorted(set(problemas))) if problemas else ""))
print(f"\n{total} problemas")

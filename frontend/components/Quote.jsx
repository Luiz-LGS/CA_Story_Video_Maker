"use client";
import { useEffect, useState } from "react";
import { brl, wa, isContato } from "../lib/config";

// servicos: [{ id, n, o: [[rótulo, preço], ...] }] · extras: [{ n, p (R$), m (fração) }]
export default function Quote({ cfg, servicos, extras }) {
  const [si, setSi] = useState(0);
  const [i, setI] = useState(0);
  const [x, setX] = useState([]);
  const [pop, setPop] = useState(false);
  const [nome, setNome] = useState("");
  const [contato, setContato] = useState("");
  const [err, setErr] = useState("");

  const sv = servicos[si];
  const [sizeLabel, base] = sv.o[i];
  const picked = x.map((k) => extras[k]);
  let total = base + picked.reduce((a, e) => a + (e.p || 0), 0);
  picked.forEach((e) => { if (e.m) total += total * e.m; });
  const lines = [`${sv.n}: ${sizeLabel}`, ...picked.map((e) => e.n)];

  useEffect(() => {
    setPop(true);
    const t = setTimeout(() => setPop(false), 180);
    return () => clearTimeout(t);
  }, [total]);

  const link = wa(cfg.whats,
    `Olá, ${cfg.nome}! Quero aprovar este orçamento do site:\n${lines.join("\n")}\nTotal: ${brl(total)}\nPodemos reservar a data?`);
  const toggle = (k) => setX((c) => (c.includes(k) ? c.filter((v) => v !== k) : [...c, k]));

  // confere nome e contato e abre o WhatsApp com o pedido pronto
  function aprovar() {
    if (nome.trim().length < 2) { setErr("Preencha seu nome."); return; }
    if (!isContato(contato)) { setErr("Digite um WhatsApp com DDD (ex: 18 99999-9999) ou um e-mail válido."); return; }
    setErr("");
    const msg = `${link}${encodeURIComponent(`\nMeu nome: ${nome.trim()}\nMeu contato: ${contato.trim()}`)}`;
    window.open(msg, "_blank", "noopener");
  }

  return (
    <section className="s quote" id="orcamento">
      <div className="wrap">
        <span className="eyebrow">sem enrolação, direto ao valor</span>
        <h2>Orçamento pré-aprovado</h2>
        <p className="lead">
          Monte o seu pacote e veja o valor na hora. Gostou? Um clique e o pedido chega no meu WhatsApp, já pronto para eu reservar a sua data.
        </p>
        <div className="qbox">
          <div>
            <div className="step">
              <h3>O que você precisa?</h3>
              <div className="opts">
                {servicos.map((s, k) => (
                  <button key={s.id} className="opt" aria-pressed={k === si} onClick={() => { setSi(k); setI(0); }}>{s.n}</button>
                ))}
              </div>
            </div>
            <div className="step">
              <h3>Qual o tamanho?</h3>
              <div className="opts">
                {sv.o.map(([l, p], n) => (
                  <button key={l} className="opt" aria-pressed={n === i} onClick={() => setI(n)}>
                    {l}<small>{brl(p)}</small>
                  </button>
                ))}
              </div>
            </div>
            {extras.length > 0 && (
              <div className="step">
                <h3>Quer algum extra?</h3>
                <div className="opts">
                  {extras.map((e, k) => (
                    <button key={e.n} className="opt" aria-pressed={x.includes(k)} onClick={() => toggle(k)}>
                      {e.n}<small>{e.m ? `+${Math.round(e.m * 100)}%` : `+ ${brl(e.p)}`}</small>
                    </button>
                  ))}
                </div>
              </div>
            )}
          </div>
          <aside className="total" aria-live="polite">
            <div className="lbl">Seu pacote</div>
            <div className={`val${pop ? " pop" : ""}`}>{brl(total)}</div>
            <ul>{lines.map((l) => <li key={l}>{l}</li>)}</ul>
            <input aria-label="Seu nome" placeholder="Seu nome" value={nome} onChange={(e) => setNome(e.target.value)} />
            <input aria-label="Seu WhatsApp ou e-mail" placeholder="Seu WhatsApp ou e-mail" value={contato} onChange={(e) => setContato(e.target.value)} />
            {err && <p className="qerr">{err}</p>}
            <button className="btn y" type="button" onClick={aprovar}>Aprovar no WhatsApp</button>
            <small>Valor fixo para o escopo escolhido. Ajustes fora do pacote eu combino com você antes.</small>
          </aside>
        </div>
      </div>
    </section>
  );
}

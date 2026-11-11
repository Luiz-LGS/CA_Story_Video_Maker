"use client";
import { useState } from "react";
import { wa, isContato } from "../lib/config";

// confere cada campo e devolve só os que têm erro
function validar(d) {
  const e = {};
  if (d.n.length < 2) e.n = "Digite seu nome.";
  if (!isContato(d.c)) e.c = "Digite um WhatsApp com DDD (ex: 18 99999-9999) ou um e-mail válido.";
  if (d.m.length < 5) e.m = "Conte um pouco sobre o projeto.";
  return e;
}

export default function Contact({ cfg }) {
  const [err, setErr] = useState({});

  function send(e) {
    e.preventDefault();
    const f = new FormData(e.currentTarget);
    const d = { n: f.get("n").trim(), c: f.get("c").trim(), m: f.get("m").trim() };
    const erros = validar(d);
    setErr(erros);
    const primeiro = Object.keys(erros)[0];
    if (primeiro) { e.currentTarget.elements[primeiro].focus(); return; }
    window.open(wa(cfg.whats, `Olá! Me chamo ${d.n} (${d.c}).\n${d.m}`), "_blank", "noopener");
  }

  // apaga o erro do campo assim que a pessoa volta a digitar
  const limpar = (k) => () => err[k] && setErr((c) => ({ ...c, [k]: undefined }));
  const campo = (k) => ({
    name: k,
    onInput: limpar(k),
    "aria-invalid": !!err[k],
    "aria-describedby": err[k] ? `err-${k}` : undefined,
  });
  const msg = (k) => err[k] && <span className="ferr" id={`err-${k}`}>{err[k]}</span>;

  return (
    <section className="s" id="contato">
      <div className="wrap">
        <span className="eyebrow">bora fazer acontecer?</span>
        <h2>Vamos conversar</h2>
        <p className="lead">Escolha o canal que for mais fácil. Eu respondo no mesmo dia útil.</p>
        <div className="cts">
          <a className="ct" href={wa(cfg.whats, "Olá! Vim pelo seu site e quero conversar sobre um projeto.")} target="_blank" rel="noopener noreferrer">
            <b>WhatsApp</b><span>Resposta mais rápida</span>
          </a>
          <a className="ct" href={`mailto:${cfg.email}`}>
            <b>E-mail</b><span>Para briefings e propostas</span>
          </a>
          <a className="ct" href={cfg.insta} target="_blank" rel="noopener noreferrer">
            <b>Instagram</b><span>Bastidores e novidades</span>
          </a>
        </div>
        <form onSubmit={send} noValidate>
          <label>Seu nome<input {...campo("n")} autoComplete="name" />{msg("n")}</label>
          <label>Seu WhatsApp ou e-mail<input {...campo("c")} placeholder="18 99999-9999 ou voce@email.com" />{msg("c")}</label>
          <label>Conte sobre o projeto<textarea {...campo("m")} rows={4} />{msg("m")}</label>
          <button className="btn y" type="submit">Enviar pelo WhatsApp</button>
        </form>
      </div>
    </section>
  );
}

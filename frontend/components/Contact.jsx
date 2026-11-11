"use client";
import { wa } from "../lib/config";

export default function Contact({ cfg }) {
  function send(e) {
    e.preventDefault();
    const d = new FormData(e.currentTarget);
    window.open(wa(cfg.whats, `Olá! Me chamo ${d.get("n")} (${d.get("c")}).\n${d.get("m")}`), "_blank", "noopener");
  }

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
        <form onSubmit={send}>
          <label>Seu nome<input name="n" required autoComplete="name" /></label>
          <label>Seu WhatsApp ou e-mail<input name="c" required /></label>
          <label>Conte sobre o projeto<textarea name="m" rows={4} required /></label>
          <button className="btn y" type="submit">Enviar pelo WhatsApp</button>
        </form>
      </div>
    </section>
  );
}

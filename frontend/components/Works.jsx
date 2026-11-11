"use client";
import { useState } from "react";

const FILTERS = [["all", "Todos"], ["story", "Stories"], ["video", "Vídeos"]];

export default function Works({ works }) {
  const [f, setF] = useState("all");
  return (
    <section className="s" id="trabalhos">
      <div className="wrap">
        <span className="eyebrow">um pouquinho do que eu faço</span>
        <h2>Trabalhos</h2>
        <p className="lead">Uma amostra do que já saiu da minha câmera e da minha timeline.</p>
        <div className="filters" role="group" aria-label="Filtrar trabalhos">
          {FILTERS.map(([k, l]) => (
            <button key={k} className="chip" aria-pressed={f === k} onClick={() => setF(k)}>{l}</button>
          ))}
        </div>
        <div className="grid">
          {works.map((w) => (
            <a
              key={w.id}
              className={`work${w.w ? " wide" : ""}${f !== "all" && w.k !== f ? " hide" : ""}`}
              href={w.u}
              style={{ "--g": w.g }}
            >
              <span className="pl"></span>
              <div>
                <h3>{w.t}</h3>
                <p>{w.c}</p>
              </div>
            </a>
          ))}
        </div>
      </div>
    </section>
  );
}

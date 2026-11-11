"use client";
import Image from "next/image";
import { useEffect, useRef } from "react";

export default function Hero() {
  const root = useRef(null);
  const tc = useRef(null);

  // timecode a 24 quadros por segundo
  useEffect(() => {
    const t0 = performance.now();
    const p = (n) => String(n).padStart(2, "0");
    let raf;
    const tick = (now) => {
      const f = Math.floor(((now - t0) / 1000) * 24);
      if (tc.current) {
        tc.current.textContent = `${p(Math.floor(f / 86400))}:${p(Math.floor(f / 1440) % 60)}:${p(Math.floor(f / 24) % 60)}:${p(f % 24)}`;
      }
      raf = requestAnimationFrame(tick);
    };
    raf = requestAnimationFrame(tick);
    return () => cancelAnimationFrame(raf);
  }, []);

  // parallax leve com o mouse
  function onMove(e) {
    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return;
    const el = root.current;
    const r = el.getBoundingClientRect();
    el.style.setProperty("--px", ((e.clientX - r.left) / r.width - 0.5).toFixed(3));
    el.style.setProperty("--py", ((e.clientY - r.top) / r.height - 0.5).toFixed(3));
  }

  return (
    <header ref={root} className="hero" id="top" onPointerMove={onMove}>
      <div className="sun" aria-hidden="true"><i></i><i></i><i></i></div>
      <svg className="wave" viewBox="0 0 520 140" aria-hidden="true">
        <path pathLength="1" d="M-30 80C40 20 110 20 190 60S330 120 470 70" />
      </svg>
      <div className="wrap hw">
        <nav className="nav" aria-label="Principal">
          <b>story &amp; vídeo maker</b>
          <div>
            <a href="#trabalhos">Trabalhos</a>
            <a href="#orcamento">Orçamento</a>
            <a href="#contato">Contato</a>
          </div>
        </nav>
        <div className="stage">
          <div className="vf">
            <i></i><i></i><i></i><i></i>
            <div className="hud">
              <span className="rec">REC</span>
              <span ref={tc}>00:00:00:00</span>
            </div>
            <div className="vg">
              <div className="lg">
                <Image src="/img/logo.png" width={430} height={596} alt="Logo CA, Story e Vídeo Maker" priority />
              </div>
              <div className="tx">
                <h1>
                  <span><em>Sua história</em></span>
                  <span><em>em <b className="ul">movimento.</b></em></span>
                </h1>
                <p className="sub">
                  Storymaker e videomaker. Eu filmo, edito e conto o que a sua marca vive, em stories, reels e vídeos que a pessoa assiste até o fim.
                </p>
                <div className="btns">
                  <a className="btn y" href="#orcamento">Ver meu orçamento</a>
                  <a className="btn o" href="#trabalhos">Assistir aos trabalhos</a>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </header>
  );
}

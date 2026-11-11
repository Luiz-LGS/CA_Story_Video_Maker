import Hero from "../components/Hero";
import Marquee from "../components/Marquee";
import Works from "../components/Works";
import Quote from "../components/Quote";
import Contact from "../components/Contact";
import Reveal from "../components/Reveal";
import { CFG, WORKS, SV, EX } from "../lib/config";

// Os dados vêm de lib/config.js
const works = WORKS.map((w, i) => ({ id: i, ...w }));
const servicos = Object.values(SV).map((s, i) => ({ id: i, ...s }));

// Ano em cache: o Next 16 (cacheComponents) não deixa usar new Date() direto
async function Ano() {
  "use cache";
  return new Date().getFullYear();
}

export default function Home() {
  return (
    <>
      <Hero />
      <Marquee />
      <Works works={works} />
      <Quote cfg={CFG} servicos={servicos} extras={EX} />
      <Contact cfg={CFG} />
      <footer>
        <div className="wrap">© <Ano /> {CFG.nome}.</div>
      </footer>
      <Reveal />
    </>
  );
}

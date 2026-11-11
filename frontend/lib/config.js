/* ===== EDITE AQUI: contatos, trabalhos, preços e extras do site.
   Salve o arquivo e o site já usa os novos dados. ===== */
export const CFG = {
  nome: "Story & Vídeo Maker",
  whats: "5518998029192", // DDI + DDD + número, só dígitos
  email: "contato@seusite.com",
  insta: "https://www.instagram.com/anne_sa21/",
};

// k: "story" ou "video" (usado no filtro) · u: link do projeto · w: card largo
export const WORKS = [
  { t: "Lançamento de coleção", c: "Stories · moda", k: "story", g: "linear-gradient(135deg,#F35E96,#36106A)", u: "#" },
  { t: "Dia na cozinha", c: "Vídeo institucional · gastronomia", k: "video", g: "linear-gradient(160deg,#FFBE16,#FF711F)", u: "#", w: true },
  { t: "Bastidores do evento", c: "Stories · cobertura", k: "story", g: "linear-gradient(120deg,#21A7AA,#36106A)", u: "#" },
  { t: "Marca em primeira pessoa", c: "Reels · personal brand", k: "video", g: "linear-gradient(150deg,#FF711F,#F35E96)", u: "#" },
  { t: "Aftermovie", c: "Vídeo · festival", k: "video", g: "linear-gradient(135deg,#FFBE16,#F35E96)", u: "#", w: true },
  { t: "Série de depoimentos", c: "Stories · clientes", k: "story", g: "linear-gradient(170deg,#21A7AA,#FFBE16)", u: "#" },
];

// Serviços e pacotes: [rótulo, preço em R$]
export const SV = {
  story: { n: "Storymaker", o: [["5 stories", 450], ["10 stories", 800], ["20 stories", 1400]] },
  reels: { n: "Reels e vídeos curtos", o: [["1 vídeo", 600], ["3 vídeos", 1500], ["6 vídeos", 2700]] },
  film: { n: "Vídeo institucional", o: [["até 1 min", 2500], ["até 3 min", 4500], ["evento completo", 3800]] },
};

// Extras: p = valor fixo (R$) · m = acréscimo percentual (0.3 = +30%)
export const EX = [
  { n: "Roteiro incluso", p: 300 },
  { n: "Entrega em 48h", m: 0.3 },
  { n: "Captação em outra cidade", p: 400 },
];
/* ====================================================== */

// Mostra os centavos só quando existem (R$ 800 ou R$ 49,90)
export const brl = (n) =>
  "R$ " + Number(n).toLocaleString("pt-BR", { minimumFractionDigits: Number.isInteger(+n) ? 0 : 2, maximumFractionDigits: 2 });
export const wa = (whats, text) => `https://wa.me/${whats}?text=${encodeURIComponent(text)}`;

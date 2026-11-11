const WORDS = ["stories", "reels", "vídeo institucional", "cobertura de eventos", "roteiro", "edição"];

export default function Marquee() {
  const items = Array.from({ length: 4 }).flatMap((_, r) => WORDS.map((w) => ({ w, k: `${r}-${w}` })));
  return (
    <div className="strip" aria-hidden="true">
      <div>{items.map((i) => <span key={i.k}>{i.w}</span>)}</div>
    </div>
  );
}

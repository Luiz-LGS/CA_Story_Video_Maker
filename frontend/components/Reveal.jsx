"use client";
import { useEffect } from "react";

// Faz os blocos entrarem suavemente ao rolar a página (usa data-rv, definido no CSS).
export default function Reveal() {
  useEffect(() => {
    if (!("IntersectionObserver" in window)) return;
    const io = new IntersectionObserver(
      (entries) =>
        entries.forEach((e) => {
          if (!e.isIntersecting) return;
          const t = e.target;
          t.dataset.rv = "in";
          io.unobserve(t);
          setTimeout(() => { t.style.transitionDelay = ""; }, 1100);
        }),
      { threshold: 0.12 }
    );
    document.querySelectorAll(".s h2,.eyebrow,.work,.step,.ct,.total,form").forEach((el, i) => {
      el.dataset.rv = "";
      el.style.transitionDelay = `${(i % 3) * 90}ms`;
      io.observe(el);
    });
    return () => io.disconnect();
  }, []);
  return null;
}

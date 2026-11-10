import { Nunito } from "next/font/google"
import "./globals.css";

const nunito = Nunito({ subsets: ['latin'] });

//importando bootstrap

import "../public/template/css/sb-admin-2.min.css";
import "../public/template/css/fontawesome-free/css/all.min.css";

export const metadata = {
  title: "Locação de Imoveis",
  description: "Aplicação criada para a disciplina de PFS2",
};

export default function RootLayout({ children }) {
  return (
    <html lang="en" className={nunito.className}>
        <head>
          <script src="/template/js/jquery.min.js"></script>
          <script src="/template/js/bootstrap.bundle.min.js"></script>
          <script src="/template/js/sb-admin-2.min.js"></script>
        </head>
        <body>
          {children}
        </body>
    </html>
  );
}

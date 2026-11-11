/*
  CA - Story & Video Maker · BANCO DE DADOS COMPLETO
  Para MySQL 8 ou MariaDB 10.4+ (utf8mb4).
 
  COMO IMPORTAR
    Terminal:   mysql -u root -p < banco-de-dados-completo.sql
    phpMyAdmin / Workbench: Importar e escolher este arquivo.
    Hospedagem compartilhada (o banco já vem criado pelo painel da hospedagem):
    apague as linhas CREATE DATABASE e USE da SEÇÃO 1, escolha o seu banco
    e então importe.
 
  PADRÃO DE NOMES
    Tabelas começam com tb_ e ficam no singular; cada coluna leva a sigla da tabela:
    tb_usuario (usu_id, usu_nome, usu_email ...), tb_cliente (cli_id ...), tb_projeto (pro_id ...).
    Chave estrangeira usa o nome da chave que aponta: tb_cliente.usu_id → tb_usuario.usu_id.
 
  O QUE TEM AQUI
    SEÇÃO 1  Estrutura: 16 tabelas
    SEÇÃO 2  Dados iniciais: perfis, configurações do site, catálogo de preços e portfólio
    SEÇÃO 3  Dados de exemplo (opcional): clientes, trabalhos, pagamentos, agenda, orçamentos e 3 logins de teste
    SEÇÃO 4  Apagar os exemplos (opcional, comentada)
    SEÇÃO 5  Consultas para conferir os números do painel (opcional, comentadas)
 
  Depois de importar, aponte o app para o banco em .env.local:
    DATABASE_URL=mysql://usuario:senha@localhost:3306/ca_sistema
*/
 
-- =====================================================================
-- SEÇÃO 1 · ESTRUTURA (16 tabelas)
-- =====================================================================
CREATE DATABASE IF NOT EXISTS ca_sistema CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ca_sistema;
SET NAMES utf8mb4;
 
-- Para recomeçar do zero (APAGA TUDO), tire os dois traços da linha abaixo e rode antes de importar:
-- DROP DATABASE IF EXISTS ca_sistema;
 
-- ---------- acesso ----------
CREATE TABLE tb_perfil (
  per_id TINYINT AUTO_INCREMENT PRIMARY KEY,
  per_nome VARCHAR(30) NOT NULL UNIQUE,
  per_descricao VARCHAR(80) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
CREATE TABLE tb_usuario (
  usu_id INT AUTO_INCREMENT PRIMARY KEY,
  per_id TINYINT NOT NULL,
  usu_nome VARCHAR(120) NOT NULL,
  usu_email VARCHAR(160) NOT NULL UNIQUE,
  usu_senha_hash VARCHAR(100) NOT NULL,
  usu_ativo TINYINT(1) NOT NULL DEFAULT 1,
  usu_criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (per_id) REFERENCES tb_perfil(per_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- ---------- clientes (podem ou não ter login) ----------
CREATE TABLE tb_cliente (
  cli_id INT AUTO_INCREMENT PRIMARY KEY,
  usu_id INT NULL UNIQUE,
  cli_nome VARCHAR(120) NOT NULL,
  cli_empresa VARCHAR(120) NULL,
  cli_email VARCHAR(160) NULL,
  cli_telefone VARCHAR(30) NULL,
  cli_documento VARCHAR(20) NULL,
  cli_observacoes TEXT NULL,
  cli_criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (usu_id) REFERENCES tb_usuario(usu_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- ---------- trabalhos dos clientes (cada trabalho é um card no funil) ----------
CREATE TABLE tb_projeto (
  pro_id INT AUTO_INCREMENT PRIMARY KEY,
  cli_id INT NOT NULL,
  pro_titulo VARCHAR(160) NOT NULL,
  pro_servico VARCHAR(120) NULL,
  pro_valor DECIMAL(10,2) NOT NULL DEFAULT 0,
  pro_status ENUM('novo_contato','negociacao','agendado','andamento','pago','finalizado','cancelado') NOT NULL DEFAULT 'novo_contato',
  pro_data_servico DATE NULL,
  pro_prazo DATE NULL,
  pro_liberado TINYINT(1) NOT NULL DEFAULT 0,
  pro_descricao TEXT NULL,
  pro_criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (cli_id) REFERENCES tb_cliente(cli_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX idx_projeto_status ON tb_projeto (pro_status);
CREATE INDEX idx_projeto_data_servico ON tb_projeto (pro_data_servico);
 
CREATE TABLE tb_etapa (
  eta_id INT AUTO_INCREMENT PRIMARY KEY,
  pro_id INT NOT NULL,
  eta_nome VARCHAR(80) NOT NULL,
  eta_ordem TINYINT NOT NULL,
  eta_status ENUM('pendente','andamento','concluida') NOT NULL DEFAULT 'pendente',
  FOREIGN KEY (pro_id) REFERENCES tb_projeto(pro_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
CREATE TABLE tb_entrega (
  ent_id INT AUTO_INCREMENT PRIMARY KEY,
  pro_id INT NOT NULL,
  ent_titulo VARCHAR(160) NOT NULL,
  ent_url VARCHAR(500) NOT NULL,
  ent_tipo ENUM('video','arquivo') NOT NULL DEFAULT 'video',
  ent_versao TINYINT NOT NULL DEFAULT 1,
  ent_status ENUM('em_revisao','aprovado','ajustes') NOT NULL DEFAULT 'em_revisao',
  ent_comentario TEXT NULL,
  ent_criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (pro_id) REFERENCES tb_projeto(pro_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- ---------- financeiro ----------
CREATE TABLE tb_pagamento (
  pag_id INT AUTO_INCREMENT PRIMARY KEY,
  pro_id INT NOT NULL,
  pag_valor DECIMAL(10,2) NOT NULL,
  pag_data_pagamento DATE NOT NULL,
  pag_forma ENUM('pix','dinheiro','cartao','transferencia','outro') NOT NULL DEFAULT 'pix',
  pag_obs VARCHAR(200) NULL,
  FOREIGN KEY (pro_id) REFERENCES tb_projeto(pro_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX idx_pagamento_data ON tb_pagamento (pag_data_pagamento);
 
CREATE TABLE tb_despesa (
  des_id INT AUTO_INCREMENT PRIMARY KEY,
  des_descricao VARCHAR(160) NOT NULL,
  des_valor DECIMAL(10,2) NOT NULL,
  des_data_despesa DATE NOT NULL,
  des_categoria VARCHAR(60) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX idx_despesa_data ON tb_despesa (des_data_despesa);
 
-- ---------- histórico de observações do cliente ----------
CREATE TABLE tb_observacao (
  obs_id INT AUTO_INCREMENT PRIMARY KEY,
  cli_id INT NOT NULL,
  pro_id INT NULL,
  obs_texto TEXT NOT NULL,
  obs_criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (cli_id) REFERENCES tb_cliente(cli_id) ON DELETE CASCADE,
  FOREIGN KEY (pro_id) REFERENCES tb_projeto(pro_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- ---------- agenda (gravações, eventos e reuniões; os prazos de entrega vêm dos trabalhos) ----------
CREATE TABLE tb_agenda (
  age_id INT AUTO_INCREMENT PRIMARY KEY,
  age_titulo VARCHAR(160) NOT NULL,
  age_tipo ENUM('gravacao','evento','reuniao') NOT NULL DEFAULT 'gravacao',
  age_data_hora DATETIME NOT NULL,
  age_lugar VARCHAR(160) NULL,
  cli_id INT NULL,
  age_notas TEXT NULL,
  FOREIGN KEY (cli_id) REFERENCES tb_cliente(cli_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX idx_agenda_data ON tb_agenda (age_data_hora);
 
-- ---------- orçamentos recebidos pelo site ou criados no painel ----------
CREATE TABLE tb_orcamento (
  orc_id INT AUTO_INCREMENT PRIMARY KEY,
  orc_nome VARCHAR(120) NOT NULL,
  orc_contato VARCHAR(160) NOT NULL,
  orc_resumo TEXT NOT NULL,
  orc_total DECIMAL(10,2) NOT NULL DEFAULT 0,
  orc_origem ENUM('site','contato','manual') NOT NULL DEFAULT 'site',
  orc_status ENUM('novo','aprovado','recusado') NOT NULL DEFAULT 'novo',
  cli_id INT NULL,
  pro_id INT NULL,
  orc_criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (cli_id) REFERENCES tb_cliente(cli_id) ON DELETE SET NULL,
  FOREIGN KEY (pro_id) REFERENCES tb_projeto(pro_id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX idx_orcamento_status ON tb_orcamento (orc_status, orc_criado_em);
 
-- ---------- portfólio (aparece no site) ----------
CREATE TABLE tb_trabalho (
  tra_id INT AUTO_INCREMENT PRIMARY KEY,
  tra_titulo VARCHAR(160) NOT NULL,
  tra_categoria VARCHAR(160) NULL,
  tra_tipo ENUM('story','video') NOT NULL DEFAULT 'story',
  tra_link VARCHAR(500) NULL,
  tra_capa_url VARCHAR(500) NULL,
  tra_gradiente VARCHAR(120) NOT NULL DEFAULT 'linear-gradient(135deg,#F35E96,#36106A)',
  tra_ordem INT NOT NULL DEFAULT 0,
  tra_largo TINYINT(1) NOT NULL DEFAULT 0,
  tra_publicado TINYINT(1) NOT NULL DEFAULT 1,
  tra_criado_em DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
CREATE INDEX idx_trabalho_publicado ON tb_trabalho (tra_publicado, tra_ordem);
 
-- ---------- catálogo da calculadora de orçamento (aparece no site) ----------
CREATE TABLE tb_servico (
  ser_id INT AUTO_INCREMENT PRIMARY KEY,
  ser_nome VARCHAR(120) NOT NULL,
  ser_ordem INT NOT NULL DEFAULT 0,
  ser_ativo TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
CREATE TABLE tb_pacote (
  pac_id INT AUTO_INCREMENT PRIMARY KEY,
  ser_id INT NOT NULL,
  pac_rotulo VARCHAR(80) NOT NULL,
  pac_preco DECIMAL(10,2) NOT NULL,
  pac_ordem INT NOT NULL DEFAULT 0,
  pac_ativo TINYINT(1) NOT NULL DEFAULT 1,
  FOREIGN KEY (ser_id) REFERENCES tb_servico(ser_id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
CREATE TABLE tb_extra (
  ext_id INT AUTO_INCREMENT PRIMARY KEY,
  ext_nome VARCHAR(120) NOT NULL,
  ext_valor_fixo DECIMAL(10,2) NOT NULL DEFAULT 0,
  ext_percentual DECIMAL(5,2) NOT NULL DEFAULT 0,
  ext_ordem INT NOT NULL DEFAULT 0,
  ext_ativo TINYINT(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- ---------- dados do site (uma linha só) ----------
CREATE TABLE tb_configuracao (
  cfg_id TINYINT PRIMARY KEY DEFAULT 1,
  cfg_marca VARCHAR(120) NOT NULL,
  cfg_whatsapp VARCHAR(20) NOT NULL,
  cfg_email VARCHAR(160) NOT NULL,
  cfg_instagram VARCHAR(255) NOT NULL,
  cfg_pix VARCHAR(160) NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
 
-- =====================================================================
-- SEÇÃO 2 · DADOS INICIAIS (necessários; troque os textos pelo painel depois)
-- =====================================================================
INSERT INTO tb_perfil (per_id, per_nome, per_descricao) VALUES
  (1, 'admin', 'Administrador'),
  (2, 'cliente', 'Cliente');
 
INSERT INTO tb_configuracao (cfg_id, cfg_marca, cfg_whatsapp, cfg_email, cfg_instagram, cfg_pix) VALUES
  (1, 'Story & Vídeo Maker', '5518999999999', 'contato@seusite.com', 'https://instagram.com/seuperfil', 'Chave Pix: contato@seusite.com');
 
INSERT INTO tb_servico (ser_id, ser_nome, ser_ordem) VALUES
  (1, 'Storymaker', 1),
  (2, 'Reels e vídeos curtos', 2),
  (3, 'Vídeo institucional', 3);
 
INSERT INTO tb_pacote (ser_id, pac_rotulo, pac_preco, pac_ordem) VALUES
  (1, '5 stories', 450, 1),
  (1, '10 stories', 800, 2),
  (1, '20 stories', 1400, 3),
  (2, '1 vídeo', 600, 1),
  (2, '3 vídeos', 1500, 2),
  (2, '6 vídeos', 2700, 3),
  (3, 'até 1 min', 2500, 1),
  (3, 'até 3 min', 4500, 2),
  (3, 'evento completo', 3800, 3);
 
INSERT INTO tb_extra (ext_nome, ext_valor_fixo, ext_percentual, ext_ordem) VALUES
  ('Roteiro incluso', 300, 0, 1),
  ('Entrega em 48h', 0, 30, 2),
  ('Captação em outra cidade', 400, 0, 3);
 
INSERT INTO tb_trabalho (tra_titulo, tra_categoria, tra_tipo, tra_gradiente, tra_largo, tra_ordem) VALUES
  ('Lançamento de coleção', 'Stories · moda', 'story', 'linear-gradient(135deg,#F35E96,#36106A)', 0, 1),
  ('Dia na cozinha', 'Vídeo institucional · gastronomia', 'video', 'linear-gradient(160deg,#FFBE16,#FF711F)', 1, 2),
  ('Bastidores do evento', 'Stories · cobertura', 'story', 'linear-gradient(120deg,#21A7AA,#36106A)', 0, 3),
  ('Marca em primeira pessoa', 'Reels · personal brand', 'video', 'linear-gradient(150deg,#FF711F,#F35E96)', 0, 4),
  ('Aftermovie', 'Vídeo · festival', 'video', 'linear-gradient(135deg,#FFBE16,#F35E96)', 1, 5),
  ('Série de depoimentos', 'Stories · clientes', 'story', 'linear-gradient(170deg,#21A7AA,#FFBE16)', 0, 6);
 
-- =====================================================================
-- SEÇÃO 3 · DADOS DE EXEMPLO (opcional)
--
-- Serve para você ver o sistema funcionando. Para um banco limpo, apague
-- do começo desta seção até o fim da SEÇÃO 3 antes de importar, ou use a
-- SEÇÃO 4 depois.
--
-- LOGINS DE TESTE (senha de todos: demonstracao)
--   admin@exemplo.com            painel do administrador  (/login → /admin)
--   marina@studiolume.com        área do cliente         (/login → /cliente)
--   contato@cafedobairro.com     área do cliente
-- Essa senha é pública. Antes de colocar o site no ar, apague estes logins
-- (SEÇÃO 4) e crie o seu com:  npm run criar-admin -- "Seu Nome" voce@email.com suaSenha
--
-- As datas dos exemplos são de novembro de 2026. Em outro mês, os cartões
-- "faturado no mês" e "recebido no mês" do painel mostram R$ 0, o que é normal.
-- =====================================================================
START TRANSACTION;
 
INSERT INTO tb_usuario (usu_id, per_id, usu_nome, usu_email, usu_senha_hash, usu_ativo, usu_criado_em) VALUES
  (1, 1, 'Administradora (exemplo)', 'admin@exemplo.com', '$2a$10$4CadE.cND1Qek6mBlSf3v.uMPZ0EffFkixSsc/8KY3t9qzmSN9iX2', 1, '2026-10-01 09:00:00'),
  (2, 2, 'Marina Costa', 'marina@studiolume.com', '$2a$10$9T8B1R3wOlIbVfN38l9wJuLbjGjhe9a78z25q6s9tv6E2Qbx5M5Fi', 1, '2026-10-28 10:10:00'),
  (3, 2, 'Café do Bairro', 'contato@cafedobairro.com', '$2a$10$/.kDdmRhIRVophO3RPAMOuAlgmwIrsyj6njUMTfK31UvIIkMdHczO', 1, '2026-10-12 14:10:00');
 
INSERT INTO tb_cliente (cli_id, usu_id, cli_nome, cli_empresa, cli_email, cli_telefone, cli_documento, cli_observacoes, cli_criado_em) VALUES
  (1, 2, 'Marina Costa', 'Studio Lume', 'marina@studiolume.com', '(18) 99111-2233', '12.345.678/0001-90', NULL, '2026-10-28 10:05:00'),
  (2, 3, 'Café do Bairro', NULL, 'contato@cafedobairro.com', '(18) 99222-3344', NULL, NULL, '2026-10-12 13:50:00'),
  (3, NULL, 'Rafael Lima', 'Lima Fit', 'rafael@limafit.com', '(18) 99333-4455', NULL, NULL, '2026-09-28 15:55:00'),
  (4, NULL, 'Juliana Prado', NULL, NULL, '(18) 99777-1010', NULL, NULL, '2026-11-08 08:41:00');
 
INSERT INTO tb_projeto (pro_id, cli_id, pro_titulo, pro_servico, pro_valor, pro_status, pro_data_servico, pro_prazo, pro_liberado, pro_descricao, pro_criado_em) VALUES
  (1, 1, 'Campanha de lançamento', 'Reels e vídeos curtos', 2700, 'andamento', '2026-11-12', '2026-11-28', 1, '3 reels e capas dos destaques', '2026-10-30 10:00:00'),
  (2, 1, 'Vídeo institucional 2026', 'Vídeo institucional', 4500, 'negociacao', NULL, '2026-12-15', 0, 'Vídeo de até 3 minutos', '2026-11-08 09:00:00'),
  (3, 2, 'Dia na cozinha', 'Vídeo institucional', 2500, 'pago', '2026-11-14', '2026-11-20', 1, 'Vídeo gastronômico de 1 minuto', '2026-10-15 11:00:00'),
  (4, 3, 'Stories de lançamento', 'Storymaker', 800, 'agendado', '2026-11-18', '2026-11-20', 0, '10 stories na academia', '2026-11-05 15:00:00'),
  (5, 4, 'Storymaker · 10 stories', 'Storymaker', 1040, 'novo_contato', NULL, NULL, 0, 'Storymaker: 10 stories
Entrega em 48h', '2026-11-08 08:41:00'),
  (6, 3, 'Stories do verão', 'Storymaker', 450, 'finalizado', '2026-10-20', '2026-10-22', 0, '5 stories', '2026-10-01 10:00:00'),
  (7, 2, 'Reels de inverno', 'Reels e vídeos curtos', 1500, 'cancelado', NULL, NULL, 0, NULL, '2026-10-12 14:00:00');
 
INSERT INTO tb_etapa (eta_id, pro_id, eta_nome, eta_ordem, eta_status) VALUES
  (1, 1, 'Briefing', 1, 'concluida'),
  (2, 1, 'Roteiro', 2, 'concluida'),
  (3, 1, 'Gravação', 3, 'andamento'),
  (4, 1, 'Edição', 4, 'pendente'),
  (5, 1, 'Revisão', 5, 'pendente'),
  (6, 1, 'Entrega', 6, 'pendente'),
  (7, 2, 'Briefing', 1, 'concluida'),
  (8, 2, 'Roteiro', 2, 'andamento'),
  (9, 2, 'Gravação', 3, 'pendente'),
  (10, 2, 'Edição', 4, 'pendente'),
  (11, 2, 'Revisão', 5, 'pendente'),
  (12, 2, 'Entrega', 6, 'pendente'),
  (13, 3, 'Briefing', 1, 'concluida'),
  (14, 3, 'Roteiro', 2, 'concluida'),
  (15, 3, 'Gravação', 3, 'concluida'),
  (16, 3, 'Edição', 4, 'andamento'),
  (17, 3, 'Revisão', 5, 'pendente'),
  (18, 3, 'Entrega', 6, 'pendente'),
  (19, 4, 'Briefing', 1, 'pendente'),
  (20, 4, 'Roteiro', 2, 'pendente'),
  (21, 4, 'Gravação', 3, 'pendente'),
  (22, 4, 'Edição', 4, 'pendente'),
  (23, 4, 'Revisão', 5, 'pendente'),
  (24, 4, 'Entrega', 6, 'pendente'),
  (25, 5, 'Briefing', 1, 'pendente'),
  (26, 5, 'Roteiro', 2, 'pendente'),
  (27, 5, 'Gravação', 3, 'pendente'),
  (28, 5, 'Edição', 4, 'pendente'),
  (29, 5, 'Revisão', 5, 'pendente'),
  (30, 5, 'Entrega', 6, 'pendente'),
  (31, 6, 'Briefing', 1, 'concluida'),
  (32, 6, 'Roteiro', 2, 'concluida'),
  (33, 6, 'Gravação', 3, 'concluida'),
  (34, 6, 'Edição', 4, 'concluida'),
  (35, 6, 'Revisão', 5, 'concluida'),
  (36, 6, 'Entrega', 6, 'concluida'),
  (37, 7, 'Briefing', 1, 'pendente'),
  (38, 7, 'Roteiro', 2, 'pendente'),
  (39, 7, 'Gravação', 3, 'pendente'),
  (40, 7, 'Edição', 4, 'pendente'),
  (41, 7, 'Revisão', 5, 'pendente'),
  (42, 7, 'Entrega', 6, 'pendente');
 
INSERT INTO tb_entrega (ent_id, pro_id, ent_titulo, ent_url, ent_tipo, ent_versao, ent_status, ent_comentario, ent_criado_em) VALUES
  (1, 1, 'Reel 1 · Bastidores', 'https://exemplo.com/entregas/reel-1-bastidores-v2.mp4', 'video', 2, 'em_revisao', NULL, '2026-11-07 16:20:00'),
  (2, 1, 'Reel 1 · Bastidores', 'https://exemplo.com/entregas/reel-1-bastidores-v1.mp4', 'video', 1, 'ajustes', 'Trocar a música aos 0:12 e deixar o logo mais tempo na tela.', '2026-11-05 11:00:00'),
  (3, 1, 'Capas dos destaques', 'https://exemplo.com/entregas/capas-destaques.zip', 'arquivo', 1, 'aprovado', NULL, '2026-11-04 09:30:00'),
  (4, 3, 'Corte inicial', 'https://exemplo.com/entregas/cafe-corte-inicial.mp4', 'video', 1, 'em_revisao', NULL, '2026-11-06 18:00:00');
 
INSERT INTO tb_pagamento (pag_id, pro_id, pag_valor, pag_data_pagamento, pag_forma, pag_obs) VALUES
  (1, 1, 1350, '2026-11-02', 'pix', 'Entrada 50%'),
  (2, 3, 1250, '2026-10-20', 'pix', 'Entrada'),
  (3, 3, 1250, '2026-11-03', 'pix', 'Saldo'),
  (4, 4, 400, '2026-11-06', 'dinheiro', 'Sinal'),
  (5, 6, 450, '2026-10-22', 'cartao', NULL);
 
INSERT INTO tb_despesa (des_id, des_descricao, des_valor, des_data_despesa, des_categoria) VALUES
  (1, 'Combustível · gravação da cozinha', 85, '2026-11-03', 'Transporte'),
  (2, 'Bateria extra para a câmera', 190, '2026-11-05', 'Equipamento'),
  (3, 'Aluguel de luz', 150, '2026-11-08', 'Equipamento'),
  (4, 'Assinatura do editor de vídeo', 120, '2026-10-28', 'Software');
 
INSERT INTO tb_observacao (obs_id, cli_id, pro_id, obs_texto, obs_criado_em) VALUES
  (1, 1, 1, 'Prefere gravar de manhã, antes das 11h.', '2026-11-01 14:10:00'),
  (2, 1, 1, 'Quer o logo mais tempo na tela nos reels.', '2026-11-05 11:30:00'),
  (3, 1, 2, 'Pediu orçamento do vídeo institucional. Vai decidir até o fim do mês.', '2026-11-08 09:15:00'),
  (4, 2, 3, 'Pagou tudo por Pix. Quer ver o vídeo antes do dia 20.', '2026-11-03 18:40:00'),
  (5, 3, NULL, 'Chegou pelo Instagram. Quer um pacote de stories para o verão.', '2026-09-28 16:00:00');
 
INSERT INTO tb_agenda (age_id, age_titulo, age_tipo, age_data_hora, age_lugar, cli_id, age_notas) VALUES
  (1, 'Briefing do vídeo institucional', 'reuniao', '2026-11-03 15:00:00', 'Online', 1, NULL),
  (2, 'Gravação da campanha', 'gravacao', '2026-11-12 09:00:00', 'Loja centro', 1, 'Levar tripé e luz extra'),
  (3, 'Captação na cozinha', 'gravacao', '2026-11-14 14:00:00', 'Café do Bairro', 2, NULL),
  (4, 'Stories de lançamento', 'gravacao', '2026-11-18 10:00:00', 'Lima Fit', 3, NULL),
  (5, 'Festival da cidade', 'evento', '2026-11-21 19:00:00', 'Praça central', NULL, 'Cobertura de stories'),
  (6, 'Alinhamento do roteiro', 'reuniao', '2026-11-25 16:00:00', 'Online', 1, NULL);
 
INSERT INTO tb_orcamento (orc_id, orc_nome, orc_contato, orc_resumo, orc_total, orc_origem, orc_status, cli_id, pro_id, orc_criado_em) VALUES
  (1, 'Juliana Prado', '(18) 99777-1010', 'Storymaker: 10 stories
Entrega em 48h', 1040, 'site', 'novo', 4, 5, '2026-11-08 08:41:00'),
  (2, 'Studio Aurora', 'aurora@studio.com', 'Reels e vídeos curtos: 3 vídeos
Roteiro incluso', 1800, 'site', 'novo', NULL, NULL, '2026-11-07 20:15:00'),
  (3, 'Marina Costa', 'marina@studiolume.com', 'Vídeo institucional: até 3 min', 4500, 'site', 'aprovado', 1, 2, '2026-10-28 10:02:00'),
  (4, 'Pedro Alves', '(18) 99888-2020', 'Queria um vídeo para a abertura da minha loja.', 0, 'contato', 'novo', NULL, NULL, '2026-11-06 14:30:00');
 
COMMIT;
 
-- =====================================================================
-- SEÇÃO 4 · APAGAR OS EXEMPLOS (opcional, vem comentada)
--
-- Use SÓ logo depois de importar, antes de cadastrar dados de verdade:
-- apaga TODOS os clientes, trabalhos de clientes, pagamentos, despesas,
-- agenda e orçamentos. O portfólio, o catálogo de preços e as configurações
-- do site (SEÇÃO 2) continuam. Para usar, tire os "-- " do início das linhas.
-- =====================================================================
-- DELETE FROM tb_orcamento;
-- DELETE FROM tb_agenda;
-- DELETE FROM tb_observacao;
-- DELETE FROM tb_pagamento;
-- DELETE FROM tb_entrega;
-- DELETE FROM tb_etapa;
-- DELETE FROM tb_projeto;
-- DELETE FROM tb_cliente;
-- DELETE FROM tb_despesa;
-- DELETE FROM tb_usuario WHERE usu_email IN ('admin@exemplo.com', 'marina@studiolume.com', 'contato@cafedobairro.com');
-- ALTER TABLE tb_orcamento AUTO_INCREMENT = 1;
-- ALTER TABLE tb_agenda AUTO_INCREMENT = 1;
-- ALTER TABLE tb_observacao AUTO_INCREMENT = 1;
-- ALTER TABLE tb_pagamento AUTO_INCREMENT = 1;
-- ALTER TABLE tb_entrega AUTO_INCREMENT = 1;
-- ALTER TABLE tb_etapa AUTO_INCREMENT = 1;
-- ALTER TABLE tb_projeto AUTO_INCREMENT = 1;
-- ALTER TABLE tb_cliente AUTO_INCREMENT = 1;
-- ALTER TABLE tb_despesa AUTO_INCREMENT = 1;
-- ALTER TABLE tb_usuario AUTO_INCREMENT = 1;
 
-- =====================================================================
-- SEÇÃO 5 · CONSULTAS PARA CONFERIR OS NÚMEROS DO PAINEL (opcional)
--
-- São as mesmas regras do painel, para o mês de novembro de 2026.
-- Com os dados de exemplo o resultado esperado é:
--   faturado 6000 · recebido 3000 · pendente 1750 · 3 clientes ativos · 1 em andamento
-- Tire os "-- " do início das linhas para rodar.
-- =====================================================================
-- Faturado no mês: valor combinado dos trabalhos fechados com data do serviço no mês
-- SELECT COALESCE(SUM(pro_valor), 0) AS faturado FROM tb_projeto
--   WHERE pro_status IN ('agendado','andamento','pago','finalizado')
--   AND COALESCE(pro_data_servico, DATE(pro_criado_em)) >= '2026-11-01'
--   AND COALESCE(pro_data_servico, DATE(pro_criado_em)) < '2026-12-01';
 
-- Recebido no mês: pagamentos com data no mês
-- SELECT COALESCE(SUM(pag_valor), 0) AS recebido FROM tb_pagamento
--   WHERE pag_data_pagamento >= '2026-11-01' AND pag_data_pagamento < '2026-12-01';
 
-- Valores pendentes: o que falta receber dos trabalhos fechados
-- SELECT COALESCE(SUM(CASE WHEN t.pro_valor > t.pago THEN t.pro_valor - t.pago ELSE 0 END), 0) AS pendente
--   FROM (SELECT p.pro_valor, (SELECT COALESCE(SUM(pg.pag_valor), 0) FROM tb_pagamento pg WHERE pg.pro_id = p.pro_id) AS pago
--         FROM tb_projeto p WHERE p.pro_status IN ('agendado','andamento','pago','finalizado')) t;
 
-- Clientes ativos: com algum trabalho agendado, em andamento ou pago
-- SELECT COUNT(DISTINCT cli_id) AS clientes_ativos FROM tb_projeto WHERE pro_status IN ('agendado','andamento','pago');
 
-- Serviços em andamento
-- SELECT COUNT(*) AS em_andamento FROM tb_projeto WHERE pro_status = 'andamento';
 
-- Financeiro por trabalho: contratado, pago e quanto falta
-- SELECT c.cli_nome AS cliente, p.pro_titulo, p.pro_valor AS contratado,
--        COALESCE(SUM(pg.pag_valor), 0) AS pago, p.pro_valor - COALESCE(SUM(pg.pag_valor), 0) AS falta
--   FROM tb_projeto p JOIN tb_cliente c ON c.cli_id = p.cli_id LEFT JOIN tb_pagamento pg ON pg.pro_id = p.pro_id
--   WHERE p.pro_status IN ('agendado','andamento','pago','finalizado')
--   GROUP BY p.pro_id, c.cli_nome, p.pro_titulo, p.pro_valor ORDER BY c.cli_nome;
 
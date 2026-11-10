CREATE DATABASE IF NOT EXISTS ca_sistema CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE ca_sistema;

/* ---------- acesso ---------- */
CREATE TABLE tb_perfil (
  per_id TINYINT AUTO_INCREMENT PRIMARY KEY,
  per_descricao VARCHAR(30) NOT NULL UNIQUE,
);

INSERT INTO tb_perfil (per_nome, per_descricao) VALUES ('Administrador'), ('Cliente');

CREATE TABLE tb_usuario (
  usu_id INT AUTO_INCREMENT PRIMARY KEY,
  usu_nome VARCHAR(120) NOT NULL,
  usu_email VARCHAR(160) NOT NULL UNIQUE,
  usu_senha VARCHAR(100) NOT NULL,
  usu_ativo TINYINT(1) NOT NULL DEFAULT 1,
  per_id TINYINT NOT NULL,
  FOREIGN KEY (per_id) REFERENCES tb_perfil(per_id)
);

/* ---------- clientes (podem ou não ter login) ---------- */
/* cli_nome = nome da pessoa (PF) ou nome de exibição da empresa (PJ) */
CREATE TABLE tb_cliente (
  cli_id INT AUTO_INCREMENT PRIMARY KEY,
  cli_tipo ENUM('PF','PJ') NOT NULL DEFAULT 'PF',
  cli_nome VARCHAR(120) NOT NULL,
  cli_email VARCHAR(160) NULL,
  cli_telefone VARCHAR(30) NULL,
  cli_observacoes TEXT NULL,
  usu_id INT NULL UNIQUE,
  FOREIGN KEY (usu_id) REFERENCES tb_usuario(usu_id) ON DELETE SET NULL
);

/* dados de pessoa física (1 para 1 com tb_cliente quando cli_tipo = 'PF') */
CREATE TABLE tb_pessoa_fisica (
  cli_id INT PRIMARY KEY,
  pf_cpf CHAR(11) NOT NULL UNIQUE,          -- só números
  pf_rg VARCHAR(20) NULL,
  pf_data_nascimento DATE NULL,
  FOREIGN KEY (cli_id) REFERENCES tb_cliente(cli_id) ON DELETE CASCADE
);

/* dados de pessoa jurídica (1 para 1 com tb_cliente quando cli_tipo = 'PJ') */
CREATE TABLE tb_pessoa_juridica (
  cli_id INT PRIMARY KEY,
  pj_cnpj CHAR(14) NOT NULL UNIQUE,         -- só números
  pj_razao_social VARCHAR(160) NOT NULL,
  pj_nome_fantasia VARCHAR(120) NULL,
  pj_inscricao_estadual VARCHAR(20) NULL,
  pj_responsavel VARCHAR(120) NULL,         -- pessoa de contato na empresa
  FOREIGN KEY (cli_id) REFERENCES tb_cliente(cli_id) ON DELETE CASCADE
);

/* ---------- projetos ---------- */
CREATE TABLE tb_projeto (
  pro_id INT AUTO_INCREMENT PRIMARY KEY,
  cli_id INT NOT NULL,
  pro_titulo VARCHAR(160) NOT NULL,
  pro_descricao TEXT NULL,
  pro_prazo DATE NULL,
  pro_criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (cli_id) REFERENCES tb_cliente(cli_id) ON DELETE CASCADE
);
CREATE TABLE tb_etapa (
  eta_id INT AUTO_INCREMENT PRIMARY KEY,
  pro_id INT NOT NULL,
  eta_nome VARCHAR(80) NOT NULL,
  eta_ordem TINYINT NOT NULL,
  eta_status ENUM('pendente','andamento','concluida') NOT NULL DEFAULT 'pendente',
  FOREIGN KEY (pro_id) REFERENCES tb_projeto(pro_id) ON DELETE CASCADE
);
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
);

/* ---------- portfólio (aparece no site) ---------- */
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
);

/* ---------- catálogo da calculadora de orçamento (aparece no site) ---------- */
CREATE TABLE tb_servico (
  ser_id INT AUTO_INCREMENT PRIMARY KEY,
  ser_nome VARCHAR(120) NOT NULL,
  ser_ordem INT NOT NULL DEFAULT 0,
  ser_ativo TINYINT(1) NOT NULL DEFAULT 1
);
CREATE TABLE tb_pacote (
  pac_id INT AUTO_INCREMENT PRIMARY KEY,
  ser_id INT NOT NULL,
  pac_rotulo VARCHAR(80) NOT NULL,
  pac_preco DECIMAL(10,2) NOT NULL,
  pac_ordem INT NOT NULL DEFAULT 0,
  pac_ativo TINYINT(1) NOT NULL DEFAULT 1,
  FOREIGN KEY (ser_id) REFERENCES tb_servico(ser_id) ON DELETE CASCADE
);
CREATE TABLE tb_extra (
  ext_id INT AUTO_INCREMENT PRIMARY KEY,
  ext_nome VARCHAR(120) NOT NULL,
  ext_valor_fixo DECIMAL(10,2) NOT NULL DEFAULT 0,
  ext_percentual DECIMAL(5,2) NOT NULL DEFAULT 0,
  ext_ordem INT NOT NULL DEFAULT 0,
  ext_ativo TINYINT(1) NOT NULL DEFAULT 1
);

/* ---------- orçamentos recebidos / criados ---------- */
CREATE TABLE tb_orcamento (
  orc_id INT AUTO_INCREMENT PRIMARY KEY,
  cli_id INT NULL,
  orc_nome VARCHAR(120) NOT NULL,
  orc_contato VARCHAR(160) NOT NULL,
  orc_resumo TEXT NOT NULL,
  orc_total DECIMAL(10,2) NOT NULL DEFAULT 0,
  orc_origem ENUM('site','contato','manual') NOT NULL DEFAULT 'site',
  orc_status ENUM('novo','aprovado','recusado') NOT NULL DEFAULT 'novo',
  orc_criado_em DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (cli_id) REFERENCES tb_cliente(cli_id) ON DELETE SET NULL
);

/* ---------- financeiro e agenda ---------- */
CREATE TABLE tb_cobranca (
  cob_id INT AUTO_INCREMENT PRIMARY KEY,
  cli_id INT NOT NULL,
  pro_id INT NULL,
  cob_descricao VARCHAR(200) NOT NULL,
  cob_valor DECIMAL(10,2) NOT NULL,
  cob_vencimento DATE NOT NULL,
  cob_status ENUM('pendente','pago') NOT NULL DEFAULT 'pendente',
  cob_pago_em DATETIME NULL,
  cob_instrucoes TEXT NULL,
  FOREIGN KEY (cli_id) REFERENCES tb_cliente(cli_id) ON DELETE CASCADE,
  FOREIGN KEY (pro_id) REFERENCES tb_projeto(pro_id) ON DELETE SET NULL
);
CREATE TABLE tb_agenda (
  age_id INT AUTO_INCREMENT PRIMARY KEY,
  pro_id INT NULL,
  age_titulo VARCHAR(160) NOT NULL,
  age_data_hora DATETIME NOT NULL,
  age_lugar VARCHAR(160) NULL,
  age_notas TEXT NULL,
  FOREIGN KEY (pro_id) REFERENCES tb_projeto(pro_id) ON DELETE SET NULL
);

/* ---------- dados iniciais (troque pelo painel) ---------- */
INSERT INTO tb_servico (ser_nome, ser_ordem) VALUES ('Storymaker', 1), ('Reels e vídeos curtos', 2), ('Vídeo institucional', 3);
INSERT INTO tb_pacote (ser_id, pac_rotulo, pac_preco, pac_ordem) VALUES
  (1, '5 stories', 450, 1), (1, '10 stories', 800, 2), (1, '20 stories', 1400, 3),
  (2, '1 vídeo', 600, 1), (2, '3 vídeos', 1500, 2), (2, '6 vídeos', 2700, 3),
  (3, 'até 1 min', 2500, 1), (3, 'até 3 min', 4500, 2), (3, 'evento completo', 3800, 3);
INSERT INTO tb_extra (ext_nome, ext_valor_fixo, ext_percentual, ext_ordem) VALUES
  ('Roteiro incluso', 300, 0, 1), ('Entrega em 48h', 0, 30, 2), ('Captação em outra cidade', 400, 0, 3);

INSERT INTO tb_trabalho (tra_titulo, tra_categoria, tra_tipo, tra_gradiente, tra_largo, tra_ordem) VALUES
  ('Lançamento de coleção', 'Stories · moda', 'story', 'linear-gradient(135deg,#F35E96,#36106A)', 0, 1),
  ('Dia na cozinha', 'Vídeo institucional · gastronomia', 'video', 'linear-gradient(160deg,#FFBE16,#FF711F)', 1, 2),
  ('Bastidores do evento', 'Stories · cobertura', 'story', 'linear-gradient(120deg,#21A7AA,#36106A)', 0, 3),
  ('Marca em primeira pessoa', 'Reels · personal brand', 'video', 'linear-gradient(150deg,#FF711F,#F35E96)', 0, 4),
  ('Aftermovie', 'Vídeo · festival', 'video', 'linear-gradient(135deg,#FFBE16,#F35E96)', 1, 5),
  ('Série de depoimentos', 'Stories · clientes', 'story', 'linear-gradient(170deg,#21A7AA,#FFBE16)', 0, 6);

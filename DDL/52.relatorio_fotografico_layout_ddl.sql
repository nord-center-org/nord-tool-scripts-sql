-- Relatório fotográfico v2: layouts de página (retrato/paisagem, foto com texto ao lado), e nos modelos
-- fundo (marca d'água), ícone no canto superior direito, fonte e cabeçalho padrão.

-- Layout por código (ex.: R4, R3L, P2). nr_fotos_pagina passa a ser só a quantidade de fotos do layout.
ALTER TABLE relatorio_modelo ADD COLUMN IF NOT EXISTS cd_layout VARCHAR(10) NULL;
ALTER TABLE relatorio_fotografico ADD COLUMN IF NOT EXISTS cd_layout VARCHAR(10) NULL;

ALTER TABLE relatorio_modelo DROP CONSTRAINT IF EXISTS CK01_relatorio_modelo_layout;
ALTER TABLE relatorio_fotografico DROP CONSTRAINT IF EXISTS CK01_relatorio_fotografico_layout;
ALTER TABLE relatorio_modelo ADD CONSTRAINT CK01_relatorio_modelo_layout CHECK (nr_fotos_pagina BETWEEN 1 AND 8);
ALTER TABLE relatorio_fotografico ADD CONSTRAINT CK01_relatorio_fotografico_layout CHECK (nr_fotos_pagina BETWEEN 1 AND 8);

-- Registros antigos: o layout equivalente ao número de fotos por página.
UPDATE relatorio_modelo SET cd_layout = 'R' || nr_fotos_pagina WHERE cd_layout IS NULL;
UPDATE relatorio_fotografico SET cd_layout = 'R' || nr_fotos_pagina WHERE cd_layout IS NULL;

-- Aparência do PDF definida no modelo.
ALTER TABLE relatorio_modelo ADD COLUMN IF NOT EXISTS cd_fonte VARCHAR(20) NOT NULL DEFAULT 'HELVETICA';
ALTER TABLE relatorio_modelo ADD COLUMN IF NOT EXISTS in_cabecalho BOOLEAN NOT NULL DEFAULT TRUE;
ALTER TABLE relatorio_modelo ADD COLUMN IF NOT EXISTS nr_opacidade_fundo SMALLINT NOT NULL DEFAULT 12;
ALTER TABLE relatorio_modelo ADD COLUMN IF NOT EXISTS id_arquivo_fundo BIGINT NULL;
ALTER TABLE relatorio_modelo ADD COLUMN IF NOT EXISTS id_arquivo_icone BIGINT NULL;

ALTER TABLE relatorio_modelo DROP CONSTRAINT IF EXISTS CK02_relatorio_modelo_fonte;
ALTER TABLE relatorio_modelo ADD CONSTRAINT CK02_relatorio_modelo_fonte CHECK (cd_fonte IN ('HELVETICA', 'TIMES', 'COURIER'));
ALTER TABLE relatorio_modelo DROP CONSTRAINT IF EXISTS CK03_relatorio_modelo_opacidade;
ALTER TABLE relatorio_modelo ADD CONSTRAINT CK03_relatorio_modelo_opacidade CHECK (nr_opacidade_fundo BETWEEN 3 AND 60);

ALTER TABLE relatorio_modelo DROP CONSTRAINT IF EXISTS FK01_arquivo_x_modelo_fundo;
ALTER TABLE relatorio_modelo ADD CONSTRAINT FK01_arquivo_x_modelo_fundo FOREIGN KEY (id_arquivo_fundo) REFERENCES arquivo_armazenado (id_arquivo);
ALTER TABLE relatorio_modelo DROP CONSTRAINT IF EXISTS FK02_arquivo_x_modelo_icone;
ALTER TABLE relatorio_modelo ADD CONSTRAINT FK02_arquivo_x_modelo_icone FOREIGN KEY (id_arquivo_icone) REFERENCES arquivo_armazenado (id_arquivo);

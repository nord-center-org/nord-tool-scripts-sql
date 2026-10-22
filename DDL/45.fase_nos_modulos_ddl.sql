-- Obra/fase nos dados de obra. Cada registro pertence a uma fase; o backend só mostra as fases em que o usuário
-- está (o admin vê todas). id_fase nulo = registro antigo ainda sem fase: só o admin vê (e todos veem enquanto
-- nenhuma fase tiver sido cadastrada, para nada sumir antes da configuração).
ALTER TABLE apartamento_vistoria ADD COLUMN IF NOT EXISTS id_fase BIGINT NULL;
ALTER TABLE apartamento_vistoria DROP CONSTRAINT IF EXISTS FK03_fase_x_apartamento_vistoria;
ALTER TABLE apartamento_vistoria ADD CONSTRAINT FK03_fase_x_apartamento_vistoria FOREIGN KEY (id_fase) REFERENCES fase (id_fase) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS IX01_apartamento_vistoria_fase ON apartamento_vistoria (id_fase);

-- Ferramenta sem fase = compartilhada (aparece em todas as fases).
ALTER TABLE ferramentas ADD COLUMN IF NOT EXISTS id_fase BIGINT NULL;
ALTER TABLE ferramentas DROP CONSTRAINT IF EXISTS FK01_fase_x_ferramentas;
ALTER TABLE ferramentas ADD CONSTRAINT FK01_fase_x_ferramentas FOREIGN KEY (id_fase) REFERENCES fase (id_fase) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS IX01_ferramentas_fase ON ferramentas (id_fase);

ALTER TABLE medicao ADD COLUMN IF NOT EXISTS id_fase BIGINT NULL;
ALTER TABLE medicao DROP CONSTRAINT IF EXISTS FK02_fase_x_medicao;
ALTER TABLE medicao ADD CONSTRAINT FK02_fase_x_medicao FOREIGN KEY (id_fase) REFERENCES fase (id_fase) ON DELETE SET NULL;
CREATE INDEX IF NOT EXISTS IX03_medicao_fase ON medicao (id_fase);

-- Apartamentos antigos entram na fase pela sigla do código ("N1-01-0101" → fase com sigla N1), quando a sigla
-- é única entre as fases. Reexecutável; o admin também pode rodar pelo botão em Obras e fases.
UPDATE apartamento_vistoria av SET id_fase = f.id_fase
FROM fase f
WHERE av.id_fase IS NULL
  AND f.cd_fase IS NOT NULL
  AND UPPER(f.cd_fase) = UPPER(SPLIT_PART(av.nm_apartamento_vistoria, '-', 1))
  AND (SELECT COUNT(*) FROM fase f2 WHERE UPPER(f2.cd_fase) = UPPER(f.cd_fase)) = 1;

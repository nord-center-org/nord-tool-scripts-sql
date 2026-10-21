-- Medições: status iniciais (reexecutável). Para adicionar outro:
--   INSERT INTO medicao_status (cd_status, nm_status, nr_ordem) VALUES ('EM_ANALISE', 'Em análise', 3);
INSERT INTO medicao_status (cd_status, nm_status, nr_ordem)
VALUES
    ('PENDENTE', 'Pendente', 1),
    ('FEITA', 'Feita', 2)
ON CONFLICT (cd_status) DO NOTHING;

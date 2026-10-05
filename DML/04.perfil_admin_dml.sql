INSERT INTO perfil (cd_perfil, nm_perfil)
VALUES ('ADMIN', 'Administrador')
ON CONFLICT (cd_perfil) DO NOTHING;

INSERT INTO perfil_permissao (id_perfil, cd_modulo, cd_acao)
SELECT id_perfil, '*', 'ESCRITA' FROM perfil WHERE cd_perfil = 'ADMIN'
ON CONFLICT DO NOTHING;

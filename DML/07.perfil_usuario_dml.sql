-- Perfil USER: todo usuário novo nasce nele, sem nenhum acesso. Os módulos são liberados por pessoa
-- (usuario_permissao) na tela de Acessos. Reexecutável.
INSERT INTO perfil (cd_perfil, nm_perfil)
VALUES ('USER', 'Usuário')
ON CONFLICT (cd_perfil) DO NOTHING;

-- Garante o nome do perfil ADMIN (criado em DML/04 com acesso total '*').
UPDATE perfil SET nm_perfil = 'Administrador' WHERE cd_perfil = 'ADMIN';

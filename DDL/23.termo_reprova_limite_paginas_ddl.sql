-- Amplia o limite de páginas do termo de reprova de 40 para 80.
-- Idempotente: remove a CHECK antiga (nome gerado ou já renomeado) e recria com nome fixo.
DO $$
DECLARE
    v_nome TEXT;
BEGIN
    FOR v_nome IN
        SELECT c.conname
        FROM pg_constraint c
        WHERE c.conrelid = 'apartamento_termo_reprova'::regclass
          AND c.contype = 'c'
          AND pg_get_constraintdef(c.oid) ILIKE '%nr_paginas%'
    LOOP
        EXECUTE format('ALTER TABLE apartamento_termo_reprova DROP CONSTRAINT %I', v_nome);
    END LOOP;

    ALTER TABLE apartamento_termo_reprova
        ADD CONSTRAINT ck_termo_nr_paginas CHECK (nr_paginas > 0 AND nr_paginas <= 80);
END $$;

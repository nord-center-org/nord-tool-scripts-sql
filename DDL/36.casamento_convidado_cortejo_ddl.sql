-- Casamento: papel do convidado no cortejo nupcial (padrinho, madrinha, daminha, pajem...). Texto livre; nulo = não faz parte.
ALTER TABLE casamento_convidado
    ADD COLUMN IF NOT EXISTS nm_cortejo VARCHAR(40);

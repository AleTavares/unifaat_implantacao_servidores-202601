-- Script SQL: Criar Tabela de Alunos
-- Destino: RDS PostgreSQL
-- RA: 4025109

-- Criar tabela
CREATE TABLE IF NOT EXISTS alunos (
    id SERIAL PRIMARY KEY,
    ra VARCHAR(10) UNIQUE NOT NULL,
    nome VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    data_inscricao TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(10) DEFAULT 'ativo' CHECK (status IN ('ativo', 'inativo'))
);

-- Criar índices para melhor performance
CREATE INDEX IF NOT EXISTS idx_alunos_ra ON alunos(ra);
CREATE INDEX IF NOT EXISTS idx_alunos_email ON alunos(email);
CREATE INDEX IF NOT EXISTS idx_alunos_status ON alunos(status);

-- Comentários descritivos
COMMENT ON TABLE alunos IS 'Tabela de alunos da Aula 011';
COMMENT ON COLUMN alunos.id IS 'ID único do aluno';
COMMENT ON COLUMN alunos.ra IS 'Número de matrícula (RA)';
COMMENT ON COLUMN alunos.nome IS 'Nome completo do aluno';
COMMENT ON COLUMN alunos.email IS 'Email do aluno (único)';
COMMENT ON COLUMN alunos.data_inscricao IS 'Data e hora da inscrição';
COMMENT ON COLUMN alunos.status IS 'Status do aluno (ativo/inativo)';

-- Verificar tabela criada
\dt alunos
\d alunos

-- Script SQL: Inserir Dados de Alunos
-- Destino: RDS PostgreSQL - Tabela alunos
-- RA: 4025109

-- Inserir dados de alunos de exemplo
INSERT INTO alunos (ra, nome, email, status) VALUES
('6325128', 'João Silva', 'joao.silva@unifaat.edu.br', 'ativo'),
('6325129', 'Maria Santos', 'maria.santos@unifaat.edu.br', 'ativo'),
('6325130', 'Pedro Oliveira', 'pedro.oliveira@unifaat.edu.br', 'ativo'),
('4025109', 'Seu Nome', 'seu.email@unifaat.edu.br', 'ativo');

-- Verificar quantidade de registros inseridos
SELECT COUNT(*) as total_alunos FROM alunos;

-- Listar todos os alunos
SELECT * FROM alunos;

-- Listar com formatação melhorada
SELECT 
    id,
    ra,
    nome,
    email,
    TO_CHAR(data_inscricao, 'DD/MM/YYYY HH24:MI:SS') as data_inscricao,
    status
FROM alunos
ORDER BY id;

-- Estatísticas
SELECT 
    COUNT(*) as total_registros,
    COUNT(CASE WHEN status = 'ativo' THEN 1 END) as alunos_ativos,
    COUNT(CASE WHEN status = 'inativo' THEN 1 END) as alunos_inativos
FROM alunos;

# Louja

## Estrutura

- `frontend/public/` - páginas do site
- `frontend/public/admin/` - páginas do administrador
- `frontend/public/css/` - estilos
- `frontend/public/js/` - animações GSAP
- `backend/config/` - conexão com o banco e login
- `docs/louja.sql` - banco de dados

## Banco de dados

Depois de importar `docs/louja.sql`, execute `docs/multiplas_plataformas_generos.sql` para criar e preencher as relações de gêneros e plataformas. Esse segundo script pode ser executado novamente sem duplicar relações.

Se o banco de dados já existia antes do recurso de foto de perfil, execute `docs/migracao_foto_perfil.sql` uma vez para adicionar a coluna usada para armazenar o caminho da imagem.




-- ============================================
-- CONSULTAS SQL - DataScienceHub Database
-- Archivo: Consultas_DataScienceHub.sql
-- ============================================
-- Descripción:
-- Script con las 4 consultas de análisis requeridas.
-- Cada consulta usa los alias de columnas especificados en el enunciado.
-- ============================================

USE data_science_hub_db;
GO

SET NOCOUNT ON;
GO

PRINT '========================================';
PRINT 'CONSULTAS DE ANÁLISIS - DataScienceHub';
PRINT '========================================';
PRINT '';
GO

-- ============================================
-- CONSULTA 1: Título, fecha y cantidad de autores por artículo
-- ============================================
-- Descripción:
-- Muestra cada artículo con su título, fecha de publicación
-- y la cantidad de autores que lo escribieron.
-- Columnas esperadas: ArticleTitle, PublicationDate, AuthorCount
-- ============================================

PRINT '[Consulta 1] Artículos con título, fecha y cantidad de autores';
PRINT '─────────────────────────────────────────────────────────────';
PRINT '';

SELECT 
    a.title AS ArticleTitle,
    a.publication_date AS PublicationDate,
    COUNT(aa.author_id) AS AuthorCount
FROM Article a
LEFT JOIN Article_Author aa ON a.id = aa.article_id
GROUP BY a.id, a.title, a.publication_date
ORDER BY a.publication_date DESC;

PRINT '';
PRINT '✓ Consulta 1 ejecutada.';
PRINT '';
GO

-- ============================================
-- CONSULTA 2: Top 5 palabras clave más frecuentes
-- ============================================
-- Descripción:
-- Lista las 5 palabras clave (keywords) que aparecen en
-- la mayor cantidad de artículos.
-- Columnas esperadas: Keyword, ArticleCount
-- ============================================

PRINT '[Consulta 2] Top 5 palabras clave más frecuentes';
PRINT '─────────────────────────────────────────────────';
PRINT '';

SELECT TOP 5
    k.keyword_name AS Keyword,
    COUNT(ak.article_id) AS ArticleCount
FROM Keyword k
INNER JOIN Article_Keyword ak ON k.keyword_id = ak.keyword_id
GROUP BY k.keyword_id, k.keyword_name
ORDER BY ArticleCount DESC;

PRINT '';
PRINT '✓ Consulta 2 ejecutada.';
PRINT '';
GO

-- ============================================
-- CONSULTA 3: Artículos del venue "info.info-ai"
-- ============================================
-- Descripción:
-- Muestra todos los artículos que fueron publicados
-- en el medio/venue "info.info-ai".
-- Columnas esperadas: ArticleID, ArticleTitle, VenueName
-- ============================================

PRINT '[Consulta 3] Artículos publicados en el venue "info.info-ai"';
PRINT '────────────────────────────────────────────────────────────';
PRINT '';

SELECT 
    a.id AS ArticleID,
    a.title AS ArticleTitle,
    v.venue_name AS VenueName
FROM Article a
INNER JOIN Article_Venue av ON a.id = av.article_id
INNER JOIN Venue v ON av.venue_id = v.venue_id
WHERE v.venue_name = 'info.info-ai'
ORDER BY a.publication_date DESC;

PRINT '';
PRINT '✓ Consulta 3 ejecutada.';
PRINT '';
GO

-- ============================================
-- CONSULTA 4: Artículos que contienen "privacy" en el abstract
-- ============================================
-- Descripción:
-- Busca artículos cuyo resumen (abstract) contenga la palabra "privacy".
-- Muestra un fragmento (snippet) del abstract.
-- Columnas esperadas: ArticleID, ArticleTitle, Snippet
-- ============================================

PRINT '[Consulta 4] Artículos que contienen "privacy" en el abstract';
PRINT '──────────────────────────────────────────────────────────────';
PRINT '';

SELECT 
    a.id AS ArticleID,
    a.title AS ArticleTitle,
    CASE 
        WHEN LEN(a.abstract) > 200 
        THEN LEFT(a.abstract, 200) + '...'
        ELSE a.abstract
    END AS Snippet
FROM Article a
WHERE a.abstract LIKE '%privacy%'
ORDER BY a.publication_date DESC;

PRINT '';
PRINT '✓ Consulta 4 ejecutada.';
PRINT '';
GO

-- ============================================
-- RESUMEN DE RESULTADOS
-- ============================================
PRINT '========================================';
PRINT 'RESUMEN DE CONSULTAS';
PRINT '========================================';

DECLARE @TotalArticles INT;
DECLARE @ArticlesWithPrivacy INT;
DECLARE @ArticlesInInfoAI INT;

SELECT @TotalArticles = COUNT(*) FROM Article;
SELECT @ArticlesWithPrivacy = COUNT(*) FROM Article WHERE abstract LIKE '%privacy%';
SELECT @ArticlesInInfoAI = COUNT(DISTINCT a.id) 
FROM Article a
INNER JOIN Article_Venue av ON a.id = av.article_id
INNER JOIN Venue v ON av.venue_id = v.venue_id
WHERE v.venue_name = 'info.info-ai';

PRINT 'Total de artículos en la BD: ' + CAST(@TotalArticles AS VARCHAR(10));
PRINT 'Artículos con "privacy" en abstract: ' + CAST(@ArticlesWithPrivacy AS VARCHAR(10));
PRINT 'Artículos en venue "info.info-ai": ' + CAST(@ArticlesInInfoAI AS VARCHAR(10));
PRINT '';
PRINT '========================================';
PRINT 'TODAS LAS CONSULTAS FINALIZADAS';
PRINT '========================================';
GO









-- ============================================
-- CARGA DE DATOS - DataScienceHub Database
-- Archivo: CargaDatos
-- ============================================
-- Descripción:
-- Importación completa de datos desde articles.json usando OPENROWSET y OPENJSON.
-- El script carga automáticamente todas las tablas en el orden correcto:
-- 1. Tablas de catálogo (Keyword, Author, Venue, Team)
-- 2. Tabla principal (Article)
-- 3. Tablas intermedias (relaciones M:N)
-- ============================================

USE data_science_hub_db;
GO

SET NOCOUNT ON;  
GO

PRINT '========================================';
PRINT 'INICIO DE CARGA DE DATOS DESDE JSON';
PRINT '========================================';
PRINT '';
GO

-- ============================================
-- PASO 1: Leer el archivo JSON completo
-- ============================================
PRINT '[1/7] Leyendo archivo JSON...';

DECLARE @JSON NVARCHAR(MAX);

BEGIN TRY
    -- Leer el archivo JSON desde la ruta especificada
    SELECT @JSON = BulkColumn
    FROM OPENROWSET(
        BULK 'D:\Development\Proyectos\articles.json',
        SINGLE_CLOB
    ) AS JsonFile;
    
    PRINT ' Archivo JSON leído exitosamente.';
    PRINT '  Tamaño: ' + CAST(LEN(@JSON) AS VARCHAR(20)) + ' caracteres';
    PRINT '';
END TRY
BEGIN CATCH
    PRINT ' ERROR al leer el archivo JSON:';
    PRINT '  ' + ERROR_MESSAGE();
    PRINT '  Verifica que:';
    PRINT '    - La ruta sea correcta: D:\Development\Proyectos\articles.json';
    PRINT '    - SQL Server tenga permisos de lectura en esa carpeta';
    PRINT '    - El archivo exista y no esté abierto en otro programa';
    RETURN;
END CATCH
GO

-- ============================================
-- PASO 2: Cargar tabla KEYWORD
-- ============================================
PRINT '[2/7] Cargando tabla Keyword...';

DECLARE @JSON NVARCHAR(MAX);
SELECT @JSON = BulkColumn FROM OPENROWSET(BULK 'D:\Development\Proyectos\articles.json', SINGLE_CLOB) AS JsonFile;

BEGIN TRY
    -- Insertar keywords únicas del JSON
    INSERT INTO Keyword (keyword_name)
    SELECT DISTINCT LTRIM(RTRIM(keyword_value)) AS keyword_name
    FROM OPENJSON(@JSON) AS articles
    CROSS APPLY OPENJSON(articles.value, '$.keywords') 
    WITH (
        keyword_value NVARCHAR(100) '$'
    )
    WHERE LTRIM(RTRIM(keyword_value)) IS NOT NULL
      AND LTRIM(RTRIM(keyword_value)) != ''
      AND LTRIM(RTRIM(keyword_value)) NOT IN (SELECT keyword_name FROM Keyword);
    
    DECLARE @KeywordCount INT = @@ROWCOUNT;
    PRINT ' Tabla Keyword cargada.';
    PRINT '  Registros insertados: ' + CAST(@KeywordCount AS VARCHAR(10));
    PRINT '';
END TRY
BEGIN CATCH
    PRINT ' ERROR al cargar Keyword:';
    PRINT '  ' + ERROR_MESSAGE();
END CATCH
GO

-- ============================================
-- PASO 3: Cargar tabla AUTHOR
-- ============================================
PRINT '[3/7] Cargando tabla Author...';

DECLARE @JSON NVARCHAR(MAX);
SELECT @JSON = BulkColumn FROM OPENROWSET(BULK 'D:\Development\Proyectos\articles.json', SINGLE_CLOB) AS JsonFile;

BEGIN TRY
    -- Insertar autores únicos del JSON
    INSERT INTO Author (author_name)
    SELECT DISTINCT LTRIM(RTRIM(author_value)) AS author_name
    FROM OPENJSON(@JSON) AS articles
    CROSS APPLY OPENJSON(articles.value, '$.authors') 
    WITH (
        author_value NVARCHAR(200) '$'
    )
    WHERE LTRIM(RTRIM(author_value)) IS NOT NULL
      AND LTRIM(RTRIM(author_value)) != ''
      AND LTRIM(RTRIM(author_value)) NOT IN (SELECT author_name FROM Author);
    
    DECLARE @AuthorCount INT = @@ROWCOUNT;
    PRINT ' Tabla Author cargada.';
    PRINT '  Registros insertados: ' + CAST(@AuthorCount AS VARCHAR(10));
    PRINT '';
END TRY
BEGIN CATCH
    PRINT ' ERROR al cargar Author:';
    PRINT '  ' + ERROR_MESSAGE();
END CATCH
GO

-- ============================================
-- PASO 4: Cargar tabla VENUE
-- ============================================
PRINT '[4/7] Cargando tabla Venue...';

DECLARE @JSON NVARCHAR(MAX);
SELECT @JSON = BulkColumn FROM OPENROWSET(BULK 'D:\Development\Proyectos\articles.json', SINGLE_CLOB) AS JsonFile;

BEGIN TRY
    -- Insertar venues únicos del JSON
    INSERT INTO Venue (venue_name)
    SELECT DISTINCT LTRIM(RTRIM(venue_value)) AS venue_name
    FROM OPENJSON(@JSON) AS articles
    CROSS APPLY OPENJSON(articles.value, '$.venue') 
    WITH (
        venue_value NVARCHAR(100) '$'
    )
    WHERE LTRIM(RTRIM(venue_value)) IS NOT NULL
      AND LTRIM(RTRIM(venue_value)) != ''
      AND LTRIM(RTRIM(venue_value)) NOT IN (SELECT venue_name FROM Venue);
    
    DECLARE @VenueCount INT = @@ROWCOUNT;
    PRINT ' Tabla Venue cargada.';
    PRINT '  Registros insertados: ' + CAST(@VenueCount AS VARCHAR(10));
    PRINT '';
END TRY
BEGIN CATCH
    PRINT ' ERROR al cargar Venue:';
    PRINT '  ' + ERROR_MESSAGE();
END CATCH
GO

-- ============================================
-- PASO 5: Cargar tabla TEAM
-- ============================================
PRINT '[5/7] Cargando tabla Team...';

DECLARE @JSON NVARCHAR(MAX);
SELECT @JSON = BulkColumn FROM OPENROWSET(BULK 'D:\Development\Proyectos\articles.json', SINGLE_CLOB) AS JsonFile;

BEGIN TRY
    -- Insertar teams únicos del JSON
    INSERT INTO Team (team_name)
    SELECT DISTINCT LTRIM(RTRIM(team_value)) AS team_name
    FROM OPENJSON(@JSON) AS articles
    CROSS APPLY OPENJSON(articles.value, '$.teams') 
    WITH (
        team_value NVARCHAR(100) '$'
    )
    WHERE LTRIM(RTRIM(team_value)) IS NOT NULL
      AND LTRIM(RTRIM(team_value)) != ''
      AND LTRIM(RTRIM(team_value)) NOT IN (SELECT team_name FROM Team);
    
    DECLARE @TeamCount INT = @@ROWCOUNT;
    PRINT ' Tabla Team cargada.';
    PRINT '  Registros insertados: ' + CAST(@TeamCount AS VARCHAR(10));
    PRINT '';
END TRY
BEGIN CATCH
    PRINT ' ERROR al cargar Team:';
    PRINT '  ' + ERROR_MESSAGE();
END CATCH
GO

-- ============================================
-- PASO 6: Cargar tabla ARTICLE (tabla principal)
-- ============================================
PRINT '[6/7] Cargando tabla Article...';

DECLARE @JSON NVARCHAR(MAX);
SELECT @JSON = BulkColumn FROM OPENROWSET(BULK 'D:\Development\Proyectos\articles.json', SINGLE_CLOB) AS JsonFile;

BEGIN TRY
    -- Insertar artículos
    INSERT INTO Article (id, title, abstract, publication_date)
    SELECT 
        id,
        title,
        abstract,
        TRY_CONVERT(DATETIME2, date) AS publication_date
    FROM OPENJSON(@JSON)
    WITH (
        id VARCHAR(20) '$.id',
        title NVARCHAR(500) '$.title',
        abstract NVARCHAR(MAX) '$.abstract',
        date VARCHAR(50) '$.date'
    )
    WHERE id IS NOT NULL
      AND id NOT IN (SELECT id FROM Article);
    
    DECLARE @ArticleCount INT = @@ROWCOUNT;
    PRINT ' Tabla Article cargada.';
    PRINT '  Registros insertados: ' + CAST(@ArticleCount AS VARCHAR(10));
    PRINT '';
END TRY
BEGIN CATCH
    PRINT ' ERROR al cargar Article:';
    PRINT '  ' + ERROR_MESSAGE();
END CATCH
GO

-- ============================================
-- PASO 7: Cargar tablas INTERMEDIAS (relaciones M:N)
-- ============================================
PRINT '[7/7] Cargando tablas intermedias (relaciones)...';
PRINT '';

DECLARE @JSON NVARCHAR(MAX);
SELECT @JSON = BulkColumn FROM OPENROWSET(BULK 'D:\Development\Proyectos\articles.json', SINGLE_CLOB) AS JsonFile;

-- ============================================
-- 7a. Article_Keyword
-- ============================================
PRINT '  [7a] Cargando Article_Keyword...';

BEGIN TRY
    INSERT INTO Article_Keyword (article_id, keyword_id)
    SELECT DISTINCT
        a.id AS article_id,
        k.keyword_id
    FROM OPENJSON(@JSON) AS articles
    CROSS APPLY OPENJSON(articles.value) 
    WITH (
        id VARCHAR(20) '$.id'
    ) AS a
    CROSS APPLY OPENJSON(articles.value, '$.keywords') 
    WITH (
        keyword_value NVARCHAR(100) '$'
    ) AS kw
    INNER JOIN Keyword k ON k.keyword_name = LTRIM(RTRIM(kw.keyword_value))
    WHERE a.id IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM Article_Keyword ak 
          WHERE ak.article_id = a.id AND ak.keyword_id = k.keyword_id
      );
    
    DECLARE @AKCount INT = @@ROWCOUNT;
    PRINT '   Article_Keyword: ' + CAST(@AKCount AS VARCHAR(10)) + ' relaciones insertadas.';
END TRY
BEGIN CATCH
    PRINT '   ERROR en Article_Keyword: ' + ERROR_MESSAGE();
END CATCH

-- ============================================
-- 7b. Article_Author
-- ============================================
PRINT '  [7b] Cargando Article_Author...';

BEGIN TRY
    INSERT INTO Article_Author (article_id, author_id)
    SELECT DISTINCT
        a.id AS article_id,
        au.author_id
    FROM OPENJSON(@JSON) AS articles
    CROSS APPLY OPENJSON(articles.value) 
    WITH (
        id VARCHAR(20) '$.id'
    ) AS a
    CROSS APPLY OPENJSON(articles.value, '$.authors') 
    WITH (
        author_value NVARCHAR(200) '$'
    ) AS aut
    INNER JOIN Author au ON au.author_name = LTRIM(RTRIM(aut.author_value))
    WHERE a.id IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM Article_Author aa 
          WHERE aa.article_id = a.id AND aa.author_id = au.author_id
      );
    
    DECLARE @AACount INT = @@ROWCOUNT;
    PRINT '   Article_Author: ' + CAST(@AACount AS VARCHAR(10)) + ' relaciones insertadas.';
END TRY
BEGIN CATCH
    PRINT '   ERROR en Article_Author: ' + ERROR_MESSAGE();
END CATCH

-- ============================================
-- 7c. Article_Venue
-- ============================================
PRINT '  [7c] Cargando Article_Venue...';

BEGIN TRY
    INSERT INTO Article_Venue (article_id, venue_id)
    SELECT DISTINCT
        a.id AS article_id,
        v.venue_id
    FROM OPENJSON(@JSON) AS articles
    CROSS APPLY OPENJSON(articles.value) 
    WITH (
        id VARCHAR(20) '$.id'
    ) AS a
    CROSS APPLY OPENJSON(articles.value, '$.venue') 
    WITH (
        venue_value NVARCHAR(100) '$'
    ) AS ven
    INNER JOIN Venue v ON v.venue_name = LTRIM(RTRIM(ven.venue_value))
    WHERE a.id IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM Article_Venue av 
          WHERE av.article_id = a.id AND av.venue_id = v.venue_id
      );
    
    DECLARE @AVCount INT = @@ROWCOUNT;
    PRINT '   Article_Venue: ' + CAST(@AVCount AS VARCHAR(10)) + ' relaciones insertadas.';
END TRY
BEGIN CATCH
    PRINT '   ERROR en Article_Venue: ' + ERROR_MESSAGE();
END CATCH

-- ============================================
-- 7d. Article_Team
-- ============================================
PRINT '  [7d] Cargando Article_Team...';

BEGIN TRY
    INSERT INTO Article_Team (article_id, team_id)
    SELECT DISTINCT
        a.id AS article_id,
        t.team_id
    FROM OPENJSON(@JSON) AS articles
    CROSS APPLY OPENJSON(articles.value) 
    WITH (
        id VARCHAR(20) '$.id'
    ) AS a
    CROSS APPLY OPENJSON(articles.value, '$.teams') 
    WITH (
        team_value NVARCHAR(100) '$'
    ) AS tm
    INNER JOIN Team t ON t.team_name = LTRIM(RTRIM(tm.team_value))
    WHERE a.id IS NOT NULL
      AND NOT EXISTS (
          SELECT 1 FROM Article_Team at 
          WHERE at.article_id = a.id AND at.team_id = t.team_id
      );
    
    DECLARE @ATCount INT = @@ROWCOUNT;
    PRINT '   Article_Team: ' + CAST(@ATCount AS VARCHAR(10)) + ' relaciones insertadas.';
    PRINT '';
END TRY
BEGIN CATCH
    PRINT '   ERROR en Article_Team: ' + ERROR_MESSAGE();
END CATCH
GO

-- ============================================
-- RESUMEN FINAL
-- ============================================
PRINT '========================================';
PRINT 'RESUMEN DE CARGA COMPLETADA';
PRINT '========================================';

SELECT 'Keyword' AS Tabla, COUNT(*) AS TotalRegistros FROM Keyword
UNION ALL
SELECT 'Author', COUNT(*) FROM Author
UNION ALL
SELECT 'Venue', COUNT(*) FROM Venue
UNION ALL
SELECT 'Team', COUNT(*) FROM Team
UNION ALL
SELECT 'Article', COUNT(*) FROM Article
UNION ALL
SELECT 'Article_Keyword', COUNT(*) FROM Article_Keyword
UNION ALL
SELECT 'Article_Author', COUNT(*) FROM Article_Author
UNION ALL
SELECT 'Article_Venue', COUNT(*) FROM Article_Venue
UNION ALL
SELECT 'Article_Team', COUNT(*) FROM Article_Team;

PRINT '';
PRINT '========================================';
PRINT 'CARGA DE DATOS FINALIZADA EXITOSAMENTE';
PRINT '========================================';
GO









-- ============================================
-- ADMINISTRACIÓN - DataScienceHub Database
-- Archivo: Administracion_DataScienceHub.sql
-- ============================================
-- Descripción:
-- Script de administración básica de la base de datos.
-- Muestra el espacio ocupado desglosado por archivos físicos.
-- Columnas esperadas: FileName, FileType, SizeMB, FilePath
-- ============================================

USE data_science_hub_db;
GO

SET NOCOUNT ON;
GO

PRINT '========================================';
PRINT 'ADMINISTRACIÓN - DataScienceHub Database';
PRINT '========================================';
PRINT '';
GO

-- ============================================
-- CONSULTA PRINCIPAL: Espacio ocupado por la base de datos
-- ============================================
-- Descripción:
-- Muestra el espacio total ocupado por cada archivo físico
-- de la base de datos (archivos de datos y log).
-- Incluye nombre lógico, tipo, tamaño y ubicación física.
-- ============================================

PRINT '[Información de Archivos] Espacio ocupado por archivo físico';
PRINT '─────────────────────────────────────────────────────────────';
PRINT '';

SELECT 
    name AS FileName,
    CASE type
        WHEN 0 THEN 'DATA'    -- Archivo de datos (.mdf o .ndf)
        WHEN 1 THEN 'LOG'     -- Archivo de log (.ldf)
        ELSE 'UNKNOWN'
    END AS FileType,
    CAST(size * 8.0 / 1024 AS DECIMAL(10,2)) AS SizeMB,
    physical_name AS FilePath
FROM sys.database_files
ORDER BY type, name;

PRINT '';
PRINT '✓ Información de archivos mostrada.';
PRINT '';
GO

-- ============================================
-- INFORMACIÓN ADICIONAL: Resumen por Filegroup
-- ============================================
-- Descripción:
-- Muestra el espacio ocupado agrupado por filegroup
-- (PRIMARY y DATA_FG).
-- ============================================

PRINT '[Resumen por Filegroup] Espacio ocupado por filegroup';
PRINT '──────────────────────────────────────────────────────';
PRINT '';

SELECT 
    fg.name AS FileGroupName,
    CAST(SUM(df.size * 8.0 / 1024) AS DECIMAL(10,2)) AS TotalSizeMB,
    COUNT(df.file_id) AS NumberOfFiles
FROM sys.filegroups fg
LEFT JOIN sys.database_files df ON fg.data_space_id = df.data_space_id
GROUP BY fg.name
ORDER BY fg.name;

PRINT '';
PRINT '✓ Resumen por filegroup mostrado.';
PRINT '';
GO

-- ============================================
-- INFORMACIÓN ADICIONAL: Espacio usado vs disponible
-- ============================================
-- Descripción:
-- Detalla cuánto espacio está realmente utilizado vs cuánto
-- está reservado en cada archivo.
-- ============================================

PRINT '[Uso de Espacio] Espacio usado vs reservado';
PRINT '────────────────────────────────────────────';
PRINT '';

SELECT 
    name AS FileName,
    CASE type
        WHEN 0 THEN 'DATA'
        WHEN 1 THEN 'LOG'
    END AS FileType,
    CAST(size * 8.0 / 1024 AS DECIMAL(10,2)) AS AllocatedSizeMB,
    CAST(FILEPROPERTY(name, 'SpaceUsed') * 8.0 / 1024 AS DECIMAL(10,2)) AS UsedSizeMB,
    CAST((size - FILEPROPERTY(name, 'SpaceUsed')) * 8.0 / 1024 AS DECIMAL(10,2)) AS FreeSizeMB,
    CAST(
        (CAST(FILEPROPERTY(name, 'SpaceUsed') AS FLOAT) / size) * 100 
        AS DECIMAL(5,2)
    ) AS PercentUsed
FROM sys.database_files
WHERE type = 0  -- Solo archivos de datos (no log)
ORDER BY name;

PRINT '';
PRINT '✓ Análisis de uso de espacio completado.';
PRINT '';
GO

-- ============================================
-- INFORMACIÓN ADICIONAL: Espacio por tabla
-- ============================================
-- Descripción:
-- Muestra cuánto espacio ocupa cada tabla en la base de datos.
-- Útil para identificar qué tablas consumen más recursos.
-- ============================================

PRINT '[Espacio por Tabla] Top 10 tablas más grandes';
PRINT '──────────────────────────────────────────────';
PRINT '';

SELECT TOP 10
    t.name AS TableName,
    fg.name AS FileGroupName,
    p.rows AS RowCounts,
    CAST(SUM(a.total_pages) * 8.0 / 1024 AS DECIMAL(10,2)) AS TotalSpaceMB,
    CAST(SUM(a.used_pages) * 8.0 / 1024 AS DECIMAL(10,2)) AS UsedSpaceMB,
    CAST(SUM(a.data_pages) * 8.0 / 1024 AS DECIMAL(10,2)) AS DataSpaceMB
FROM sys.tables t
INNER JOIN sys.indexes i ON t.object_id = i.object_id
INNER JOIN sys.partitions p ON i.object_id = p.object_id AND i.index_id = p.index_id
INNER JOIN sys.allocation_units a ON p.partition_id = a.container_id
INNER JOIN sys.filegroups fg ON i.data_space_id = fg.data_space_id
WHERE t.is_ms_shipped = 0  -- Excluir tablas del sistema
GROUP BY t.name, fg.name, p.rows
ORDER BY TotalSpaceMB DESC;

PRINT '';
PRINT '✓ Análisis de espacio por tabla completado.';
PRINT '';
GO

-- ============================================
-- INFORMACIÓN ADICIONAL: Configuración de crecimiento
-- ============================================
-- Descripción:
-- Muestra cómo están configurados los archivos para crecer
-- cuando se quedan sin espacio.
-- ============================================

PRINT '[Configuración de Crecimiento] Parámetros de auto-crecimiento';
PRINT '──────────────────────────────────────────────────────────────';
PRINT '';

SELECT 
    name AS FileName,
    CASE type
        WHEN 0 THEN 'DATA'
        WHEN 1 THEN 'LOG'
    END AS FileType,
    CAST(size * 8.0 / 1024 AS DECIMAL(10,2)) AS CurrentSizeMB,
    CASE 
        WHEN max_size = -1 THEN 'UNLIMITED'
        ELSE CAST(max_size * 8.0 / 1024 AS VARCHAR(20)) + ' MB'
    END AS MaxSize,
    CASE 
        WHEN is_percent_growth = 1 
        THEN CAST(growth AS VARCHAR(10)) + ' %'
        ELSE CAST(growth * 8.0 / 1024 AS VARCHAR(20)) + ' MB'
    END AS GrowthIncrement
FROM sys.database_files
ORDER BY type, name;

PRINT '';
PRINT '✓ Configuración de crecimiento mostrada.';
PRINT '';
GO

-- ============================================
-- RESUMEN EJECUTIVO
-- ============================================

PRINT '========================================';
PRINT 'RESUMEN EJECUTIVO';
PRINT '========================================';

DECLARE @TotalDataSizeMB DECIMAL(10,2);
DECLARE @TotalLogSizeMB DECIMAL(10,2);
DECLARE @TotalSizeMB DECIMAL(10,2);
DECLARE @TotalTables INT;
DECLARE @TotalRows BIGINT;

-- Calcular tamaños
SELECT @TotalDataSizeMB = SUM(CAST(size * 8.0 / 1024 AS DECIMAL(10,2)))
FROM sys.database_files
WHERE type = 0;

SELECT @TotalLogSizeMB = SUM(CAST(size * 8.0 / 1024 AS DECIMAL(10,2)))
FROM sys.database_files
WHERE type = 1;

SET @TotalSizeMB = @TotalDataSizeMB + @TotalLogSizeMB;

-- Contar tablas y registros
SELECT @TotalTables = COUNT(*)
FROM sys.tables
WHERE is_ms_shipped = 0;

SELECT @TotalRows = SUM(p.rows)
FROM sys.tables t
INNER JOIN sys.partitions p ON t.object_id = p.object_id
WHERE t.is_ms_shipped = 0 AND p.index_id IN (0,1);

-- Mostrar resumen
PRINT 'Base de Datos: data_science_hub_db';
PRINT '─────────────────────────────────────';
PRINT 'Total de archivos de datos: ' + CAST(@TotalDataSizeMB AS VARCHAR(20)) + ' MB';
PRINT 'Total de archivos de log: ' + CAST(@TotalLogSizeMB AS VARCHAR(20)) + ' MB';
PRINT 'Espacio total ocupado: ' + CAST(@TotalSizeMB AS VARCHAR(20)) + ' MB';
PRINT '';
PRINT 'Total de tablas: ' + CAST(@TotalTables AS VARCHAR(10));
PRINT 'Total de registros: ' + CAST(@TotalRows AS VARCHAR(20));
PRINT '';
PRINT '========================================';
PRINT 'ANÁLISIS DE ADMINISTRACIÓN COMPLETADO';
PRINT '========================================';
GO




-- ============================================
-- DDL - DataScienceHub Database
-- SECCIÓN 1: Creación de Base de Datos y Filegroups
-- ============================================
-- Descripción:
-- Este script crea la base de datos data_science_hub_db con dos filegroups:
-- - PRIMARY: Para tablas de catálogo/referencia (Keyword, Author, Venue, Team)
-- - DATA_FG: Para datos transaccionales (Article y tablas intermedias)
-- ============================================

-- Eliminar la base de datos si ya existe (para pruebas)
-- CUIDADO: Esto borra todo si ya existe
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'data_science_hub_db')
BEGIN
    ALTER DATABASE data_science_hub_db SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE data_science_hub_db;
    PRINT 'Base de datos existente eliminada.';
END
GO

-- Crear la base de datos con filegroups
CREATE DATABASE data_science_hub_db
ON PRIMARY  -- Filegroup PRIMARY (obligatorio, se crea automáticamente)
(
    NAME = 'data_science_hub_db_primary',           -- Nombre lógico del archivo
    FILENAME = 'data_science_hub_db_primary.mdf',   -- Nombre físico (ruta predeterminada)
    SIZE = 10MB,                                     -- Tamaño inicial
    MAXSIZE = UNLIMITED,                             -- Sin límite de crecimiento
    FILEGROWTH = 5MB                                 -- Crece de 5MB en 5MB
),
FILEGROUP DATA_FG  -- Filegroup para datos transaccionales
(
    NAME = 'data_science_hub_db_data',              -- Nombre lógico del archivo
    FILENAME = 'data_science_hub_db_data.ndf',      -- Nombre físico (archivo secundario)
    SIZE = 50MB,                                     -- Tamaño inicial más grande
    MAXSIZE = UNLIMITED,                             -- Sin límite de crecimiento
    FILEGROWTH = 10MB                                -- Crece de 10MB en 10MB
)
LOG ON  -- Archivo de transacciones (log)
(
    NAME = 'data_science_hub_db_log',               -- Nombre lógico del log
    FILENAME = 'data_science_hub_db_log.ldf',       -- Nombre físico del log
    SIZE = 5MB,                                      -- Tamaño inicial del log
    MAXSIZE = 1GB,                                   -- Límite del log
    FILEGROWTH = 5MB                                 -- Crece de 5MB en 5MB
);
GO

PRINT 'Base de datos data_science_hub_db creada exitosamente.';
PRINT 'Filegroups configurados: PRIMARY y DATA_FG';
GO

-- Cambiar al contexto de la nueva base de datos
USE data_science_hub_db;
GO

PRINT 'Contexto cambiado a data_science_hub_db.';
GO


---




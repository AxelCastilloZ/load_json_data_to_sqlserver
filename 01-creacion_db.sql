



-- ============================================
-- DDL - DataScienceHub Database
-- SECCIÓN 1: Creación de Base de Datos y Filegroups
-- ============================================
-- Descripción:
-- Este script crea la base de datos data_science_hub_db con dos filegroups:
-- - PRIMARY: Para tablas de catálogo/referencia (Keyword, Author, Venue, Team)
-- - DATA_FG: Para datos transaccionales (Article y tablas intermedias)
-
IF EXISTS (SELECT name FROM sys.databases WHERE name = 'data_science_hub_db')
BEGIN
    ALTER DATABASE data_science_hub_db SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE data_science_hub_db;
    PRINT 'Base de datos existente eliminada.';
END
GO

-- Crear la base de datos con filegroups
CREATE DATABASE data_science_hub_db
ON PRIMARY  
(
    NAME = 'data_science_hub_db_primary',           
    FILENAME = 'data_science_hub_db_primary.mdf',  
    SIZE = 10MB,                                    
    MAXSIZE = UNLIMITED,                             
    FILEGROWTH = 5MB                                
),
FILEGROUP DATA_FG  -- Filegroup para datos transaccionales
(
    NAME = 'data_science_hub_db_data',              
    FILENAME = 'data_science_hub_db_data.ndf',      
    SIZE = 50MB,                                     
    MAXSIZE = UNLIMITED,                             
    FILEGROWTH = 10MB                                
)
LOG ON  -- Archivo de transacciones (log)
(
    NAME = 'data_science_hub_db_log',             
    FILENAME = 'data_science_hub_db_log.ldf',       
    SIZE = 5MB,                                     
    MAXSIZE = 1GB,                                   
    FILEGROWTH = 5MB                                 
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







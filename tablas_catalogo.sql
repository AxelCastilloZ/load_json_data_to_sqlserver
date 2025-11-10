




-- ============================================
-- DDL - DataScienceHub Database
-- SECCIÓN 2: Creación de Tablas de Catálogo (PRIMARY Filegroup)
-- ============================================
-- Descripción:
-- Creación de las tablas de referencia/catálogo que contienen
-- listas únicas de keywords, autores, venues y teams.
-- Estas tablas son pequeñas, estables y van en PRIMARY filegroup.
-- ============================================

USE data_science_hub_db;
GO

PRINT 'Iniciando creación de tablas de catálogo en PRIMARY filegroup...';
GO

-- ============================================
-- TABLA: Keyword
-- Descripción: Catálogo de palabras clave/temas
-- ============================================
CREATE TABLE Keyword
(
    keyword_id INT IDENTITY(1,1) NOT NULL,           -- ID auto-incremental
    keyword_name NVARCHAR(100) NOT NULL,              -- Nombre de la palabra clave
    
    -- Constraints
    CONSTRAINT PK_Keyword PRIMARY KEY (keyword_id),   -- Clave primaria
    CONSTRAINT UQ_Keyword_Name UNIQUE (keyword_name)  -- No puede haber keywords duplicados
) ON [PRIMARY];  -- Especifica que va en el filegroup PRIMARY
GO

PRINT 'Tabla Keyword creada exitosamente en PRIMARY.';
GO

-- ============================================
-- TABLA: Author
-- Descripción: Catálogo de autores
-- ============================================
CREATE TABLE Author
(
    author_id INT IDENTITY(1,1) NOT NULL,            -- ID auto-incremental
    author_name NVARCHAR(200) NOT NULL,               -- Nombre completo del autor
    
    -- Constraints
    CONSTRAINT PK_Author PRIMARY KEY (author_id),     -- Clave primaria
    CONSTRAINT UQ_Author_Name UNIQUE (author_name)    -- No puede haber autores duplicados
) ON [PRIMARY];  -- Especifica que va en el filegroup PRIMARY
GO

PRINT 'Tabla Author creada exitosamente en PRIMARY.';
GO

-- ============================================
-- TABLA: Venue
-- Descripción: Catálogo de medios/conferencias de publicación
-- ============================================
CREATE TABLE Venue
(
    venue_id INT IDENTITY(1,1) NOT NULL,             -- ID auto-incremental
    venue_name NVARCHAR(100) NOT NULL,                -- Nombre del venue
    
    -- Constraints
    CONSTRAINT PK_Venue PRIMARY KEY (venue_id),       -- Clave primaria
    CONSTRAINT UQ_Venue_Name UNIQUE (venue_name)      -- No puede haber venues duplicados
) ON [PRIMARY];  -- Especifica que va en el filegroup PRIMARY
GO

PRINT 'Tabla Venue creada exitosamente en PRIMARY.';
GO

-- ============================================
-- TABLA: Team
-- Descripción: Catálogo de equipos/instituciones
-- ============================================
CREATE TABLE Team
(
    team_id INT IDENTITY(1,1) NOT NULL,              -- ID auto-incremental
    team_name NVARCHAR(100) NOT NULL,                 -- Nombre del equipo/institución
    
    -- Constraints
    CONSTRAINT PK_Team PRIMARY KEY (team_id),         -- Clave primaria
    CONSTRAINT UQ_Team_Name UNIQUE (team_name)        -- No puede haber teams duplicados
) ON [PRIMARY];  -- Especifica que va en el filegroup PRIMARY
GO

PRINT 'Tabla Team creada exitosamente en PRIMARY.';
GO

PRINT 'SECCIÓN 2 COMPLETADA: Todas las tablas de catálogo creadas exitosamente.';
GO









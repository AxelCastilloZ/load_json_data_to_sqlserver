




-- ============================================
-- DDL - DataScienceHub Database
-- SECCIÓN 3: Tabla Article y Tablas Intermedias (DATA_FG Filegroup)
-- ============================================
-- Descripción:
-- Creación de la tabla principal Article (con los artículos científicos)
-- y las 4 tablas intermedias que resuelven las relaciones M:N.


USE data_science_hub_db;
GO

PRINT 'Iniciando creación de tabla Article y tablas intermedias en DATA_FG filegroup...';
GO

-- ============================================
-- TABLA PRINCIPAL: Article
-- Descripción: Contiene la información de cada artículo científico
-- ============================================
CREATE TABLE Article
(
    id VARCHAR(20) NOT NULL,                        
    title NVARCHAR(500) NOT NULL,                    
    abstract NVARCHAR(MAX) NULL,                     
    publication_date DATETIME2 NOT NULL,              -- Fecha de publicación
    
    -- Constraints
    CONSTRAINT PK_Article PRIMARY KEY (id)            -- Clave primaria
) ON [DATA_FG];  
GO

PRINT 'Tabla Article creada exitosamente en DATA_FG.';
GO

-- Crear índice en publication_date para optimizar búsquedas por fecha
CREATE NONCLUSTERED INDEX IX_Article_PublicationDate 
ON Article(publication_date)
ON [DATA_FG];
GO

PRINT 'Índice IX_Article_PublicationDate creado.';
GO

-- ============================================
-- TABLA INTERMEDIA: Article_Keyword
-- Descripción: Relación M:N entre Article y Keyword
-- Un artículo puede tener múltiples keywords
-- Una keyword puede estar en múltiples artículos
-- ============================================
CREATE TABLE Article_Keyword
(
    article_id VARCHAR(20) NOT NULL,                  -- FK hacia Article
    keyword_id INT NOT NULL,                          -- FK hacia Keyword
    
    -- Constraints
    CONSTRAINT PK_Article_Keyword PRIMARY KEY (article_id, keyword_id),
    CONSTRAINT FK_Article_Keyword_Article FOREIGN KEY (article_id) 
        REFERENCES Article(id) 
        ON DELETE CASCADE                            
        ON UPDATE CASCADE,                            -- Si se actualiza el ID del artículo, se actualiza aquí
    CONSTRAINT FK_Article_Keyword_Keyword FOREIGN KEY (keyword_id) 
        REFERENCES Keyword(keyword_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ON [DATA_FG];  
GO

PRINT 'Tabla Article_Keyword creada exitosamente en DATA_FG.';
GO

-- ============================================
-- TABLA INTERMEDIA: Article_Author
-- Descripción: Relación M:N entre Article y Author
-- Un artículo puede tener múltiples autores
-- Un autor puede escribir múltiples artículos
-- ============================================
CREATE TABLE Article_Author
(
    article_id VARCHAR(20) NOT NULL,                
    author_id INT NOT NULL,                          
    
    -- Constraints
    CONSTRAINT PK_Article_Author PRIMARY KEY (article_id, author_id),  
    CONSTRAINT FK_Article_Author_Article FOREIGN KEY (article_id) 
        REFERENCES Article(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_Article_Author_Author FOREIGN KEY (author_id) 
        REFERENCES Author(author_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ON [DATA_FG]; 
GO

PRINT 'Tabla Article_Author creada exitosamente en DATA_FG.';
GO

-- ============================================
-- TABLA INTERMEDIA: Article_Venue
-- Descripción: Relación M:N entre Article y Venue
-- Un artículo puede estar en múltiples venues
-- Un venue puede tener múltiples artículos
-- ============================================
CREATE TABLE Article_Venue
(
    article_id VARCHAR(20) NOT NULL,                 
    venue_id INT NOT NULL,                          
    
    -- Constraints
    CONSTRAINT PK_Article_Venue PRIMARY KEY (article_id, venue_id), 
    CONSTRAINT FK_Article_Venue_Article FOREIGN KEY (article_id) 
        REFERENCES Article(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_Article_Venue_Venue FOREIGN KEY (venue_id) 
        REFERENCES Venue(venue_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ON [DATA_FG]; 
GO

PRINT 'Tabla Article_Venue creada exitosamente en DATA_FG.';
GO

-- ============================================
-- TABLA INTERMEDIA: Article_Team
-- Descripción: Relación M:N entre Article y Team
-- Un artículo puede ser de múltiples equipos/instituciones
-- Un equipo puede tener múltiples artículos
-- ============================================
CREATE TABLE Article_Team
(
    article_id VARCHAR(20) NOT NULL,                  
    team_id INT NOT NULL,                          
    
    -- Constraints
    CONSTRAINT PK_Article_Team PRIMARY KEY (article_id, team_id),  
    CONSTRAINT FK_Article_Team_Article FOREIGN KEY (article_id) 
        REFERENCES Article(id)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT FK_Article_Team_Team FOREIGN KEY (team_id) 
        REFERENCES Team(team_id)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ON [DATA_FG]; 
GO

PRINT 'Tabla Article_Team creada exitosamente en DATA_FG.';
GO

PRINT 'SECCIÓN 3 COMPLETADA: Tabla Article y todas las tablas intermedias creadas exitosamente.';
PRINT 'Total de tablas en la base de datos: 9';
PRINT '  - 4 tablas de catálogo en PRIMARY filegroup';
PRINT '  - 1 tabla principal en DATA_FG filegroup';
PRINT '  - 4 tablas intermedias en DATA_FG filegroup';
GO



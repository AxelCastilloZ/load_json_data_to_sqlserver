


-- ============================================
-- Configuración previa para OPENROWSET
-- ============================================
-- Habilitar Ad Hoc Distributed Queries
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
GO

EXEC sp_configure 'Ad Hoc Distributed Queries', 1;
RECONFIGURE;
GO

PRINT 'Ad Hoc Distributed Queries habilitado.';
GO






SET XACT_ABORT ON;
SET NOCOUNT ON;
IF DB_NAME() <> N'DAYR_PWA_QUOTE_DEV'
    THROW 51000, 'Select the isolated DAYR_PWA_QUOTE_DEV database.', 1;
BEGIN TRANSACTION;
IF EXISTS (SELECT 1 FROM dbo.EncargadosPasillo WITH (TABLOCKX, HOLDLOCK))
   OR EXISTS (SELECT 1 FROM dbo.UbicacionesProducto WITH (TABLOCKX, HOLDLOCK))
   OR EXISTS (SELECT 1 FROM dbo.Pasillos WITH (TABLOCKX, HOLDLOCK))
    THROW 51002, 'Rollback refused: aisle tables contain data.', 1;
DROP TABLE dbo.EncargadosPasillo;
DROP TABLE dbo.UbicacionesProducto;
DROP TABLE dbo.Pasillos;
COMMIT;

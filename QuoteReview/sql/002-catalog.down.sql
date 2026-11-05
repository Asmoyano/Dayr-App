SET XACT_ABORT ON;
SET NOCOUNT ON;
IF DB_NAME() <> N'DAYR_PWA_QUOTE_DEV'
    THROW 51000, 'Select the isolated DAYR_PWA_QUOTE_DEV database.', 1;
BEGIN TRANSACTION;
IF EXISTS (SELECT 1 FROM dbo.PreciosCatalogo WITH (TABLOCKX, HOLDLOCK)) THROW 51002, 'Rollback refused: PreciosCatalogo contains data.', 1;
IF EXISTS (SELECT 1 FROM dbo.AccesoProductoVendedor WITH (TABLOCKX, HOLDLOCK)) THROW 51002, 'Rollback refused: AccesoProductoVendedor contains data.', 1;
IF EXISTS (SELECT 1 FROM dbo.AccesoClienteVendedor WITH (TABLOCKX, HOLDLOCK)) THROW 51002, 'Rollback refused: AccesoClienteVendedor contains data.', 1;
IF EXISTS (SELECT 1 FROM dbo.ListasPrecio WITH (TABLOCKX, HOLDLOCK)) THROW 51002, 'Rollback refused: ListasPrecio contains data.', 1;
IF EXISTS (SELECT 1 FROM dbo.AccesoVendedor WITH (TABLOCKX, HOLDLOCK)) THROW 51002, 'Rollback refused: AccesoVendedor contains data.', 1;
DROP PROCEDURE dbo.LeerCatalogoCotizacion;
DROP ROLE dayr_catalog_api;
DROP TABLE dbo.ConfiguracionCotizacion;
DROP TABLE dbo.PreciosCatalogo;
DROP TABLE dbo.AccesoProductoVendedor;
DROP TABLE dbo.AccesoClienteVendedor;
DROP TABLE dbo.ListasPrecio;
DROP TABLE dbo.AccesoVendedor;
COMMIT;

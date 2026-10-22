namespace Backend.Contracts;

/// <summary>Contrato JSON de lectura compatible con Product del frontend oficial.</summary>
public sealed record ProductResponse(
    string Id,
    string Sku,
    string Barcode,
    string Name,
    string Brand,
    string Unit,
    string Aisle,
    string Shelf,
    decimal ErpStock,
    decimal? PhysicalStock,
    decimal UnitPrice,
    DateTimeOffset? LastCountAt,
    string? LastCountBy);

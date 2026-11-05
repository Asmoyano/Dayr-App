namespace Backend.Contracts;

/// <summary>Salud del proceso únicamente; no comprueba bases de datos ni ERP.</summary>
public sealed record HealthResponse(
    string Status,
    string Service,
    DateTimeOffset TimestampUtc,
    string Scope,
    string DataMode);

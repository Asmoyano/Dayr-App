namespace Backend.Services.Quotations;

public sealed record QuoteDocumentLine(string Description, decimal Quantity, string Unit);

public sealed record QuoteDocument(
    string LocalReference,
    string CustomerDisplayName,
    IReadOnlyList<QuoteDocumentLine> Lines);

public sealed record QuoteLinePricing(decimal NetUnitPrice, decimal DiscountPercent, decimal NetAmount);

public sealed record PricedQuoteDocument(
    QuoteDocument Document,
    string Currency,
    IReadOnlyList<QuoteLinePricing> LinePricing,
    QuoteTotals Totals);

public interface IQuotePdfRenderer
{
    Task WriteUnpricedAsync(QuoteDocument document, Stream destination, CancellationToken cancellationToken);
    Task WritePricedAsync(PricedQuoteDocument document, Stream destination, CancellationToken cancellationToken);
}

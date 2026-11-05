namespace Backend.Services.Quotations;

public sealed record QuoteLine(decimal Quantity, decimal NetUnitPrice, decimal DiscountPercent);

public sealed record QuoteTotals(decimal Gross, decimal Discount, decimal Subtotal, decimal Tax, decimal Total);

public static class QuoteCalculator
{
    public static QuoteTotals Calculate(IReadOnlyList<QuoteLine> lines, decimal taxRate)
    {
        ArgumentNullException.ThrowIfNull(lines);
        ArgumentOutOfRangeException.ThrowIfNegative(taxRate);
        ArgumentOutOfRangeException.ThrowIfGreaterThan(taxRate, 1m);

        decimal gross = 0m;
        decimal subtotal = 0m;
        foreach (var line in lines)
        {
            ArgumentOutOfRangeException.ThrowIfNegativeOrZero(line.Quantity);
            ArgumentOutOfRangeException.ThrowIfNegative(line.NetUnitPrice);
            ArgumentOutOfRangeException.ThrowIfNegative(line.DiscountPercent);
            ArgumentOutOfRangeException.ThrowIfGreaterThan(line.DiscountPercent, 100m);

            var lineGross = line.Quantity * line.NetUnitPrice;
            gross += lineGross;
            subtotal += RoundMoney(lineGross * (1m - line.DiscountPercent / 100m));
        }

        gross = RoundMoney(gross);
        var tax = RoundMoney(subtotal * taxRate);
        return new(gross, gross - subtotal, subtotal, tax, subtotal + tax);
    }

    private static decimal RoundMoney(decimal amount) =>
        decimal.Round(amount, 2, MidpointRounding.AwayFromZero);
}

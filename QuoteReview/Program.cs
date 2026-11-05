using Backend.Services.Quotations;

Expect(new(40m, 4m, 36m, 6.48m, 42.48m),
    QuoteCalculator.Calculate([new(2m, 20m, 10m)], 0.18m));
Expect(new(0.01m, -0.01m, 0.02m, 0m, 0.02m),
    QuoteCalculator.Calculate([new(1m, 0.005m, 0m), new(1m, 0.005m, 0m)], 0.18m));
Expect(new(0m, 0m, 0m, 0m, 0m), QuoteCalculator.Calculate([], 0.18m));
Expect(new(12.5m, 12.5m, 0m, 0m, 0m),
    QuoteCalculator.Calculate([new(1.25m, 10m, 100m)], 0.18m));

Reject(() => QuoteCalculator.Calculate([new(0m, 10m, 0m)], 0.18m));
Reject(() => QuoteCalculator.Calculate([new(1m, -10m, 0m)], 0.18m));
Reject(() => QuoteCalculator.Calculate([new(1m, 10m, -1m)], 0.18m));
Reject(() => QuoteCalculator.Calculate([new(1m, 10m, 101m)], 0.18m));
Reject(() => QuoteCalculator.Calculate([], 1.01m));
Console.WriteLine("PASS: 9 quote calculation checks");
var sample = new QuoteDocument("LOCAL-DEMO", "<Cliente>", [new("Artículo <demo>", 2m, "UND")]);
var unpriced = DemoQuoteHtml.Unpriced(sample);
var priced = DemoQuoteHtml.Priced(new(sample, "PEN", [new(20m, 10m, 36m)],
    new(40m, 4m, 36m, 6.48m, 42.48m)));
if (unpriced.Contains("<Cliente>") || !unpriced.Contains("&lt;Cliente&gt;") ||
    unpriced.Contains("Importe neto") || unpriced.Contains("42.48") ||
    !priced.Contains("Importe neto") || !priced.Contains("42.48"))
    throw new InvalidOperationException("Unexpected disclosure or escaping in demo templates.");
Console.WriteLine("PASS: priced and unpriced demo templates");

if (args.Length == 1 && args[0] == "--demo")
{
    File.WriteAllText("cotizacion-demo-con-precios.html", priced);
    File.WriteAllText("cotizacion-demo-sin-precios.html", unpriced);
}

static void Expect(QuoteTotals expected, QuoteTotals actual)
{
    if (expected != actual)
        throw new InvalidOperationException($"Expected {expected}, got {actual}");
}

static void Reject(Action action)
{
    try
    {
        action();
    }
    catch (ArgumentOutOfRangeException)
    {
        return;
    }

    throw new InvalidOperationException("Expected an out-of-range error");
}

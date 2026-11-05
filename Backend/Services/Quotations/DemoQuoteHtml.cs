using System.Globalization;
using System.Net;
using System.Text;

namespace Backend.Services.Quotations;

/// <summary>Preview template for offline browser printing. Corporate styling is supplied separately.</summary>
public static class DemoQuoteHtml
{
    public static string Unpriced(QuoteDocument document) => Render(document, null);

    public static string Priced(PricedQuoteDocument document)
    {
        if (document.Document.Lines.Count != document.LinePricing.Count)
            throw new ArgumentException("Each document line requires pricing.", nameof(document));

        return Render(document.Document, document);
    }

    private static string Render(QuoteDocument document, PricedQuoteDocument? priced)
    {
        var html = new StringBuilder("""
            <!doctype html><html lang="es"><meta charset="utf-8">
            <title>Cotización de demostración</title>
            <style>body{font:16px sans-serif}table{border-collapse:collapse;width:100%}
            td,th{padding:.5rem;border-bottom:1px solid #aaa;text-align:left}tr{break-inside:avoid}</style>
            <h1>Cotización de demostración</h1>
            """);
        html.Append("<p>").Append(WebUtility.HtmlEncode(document.LocalReference)).Append("</p><p>")
            .Append(WebUtility.HtmlEncode(document.CustomerDisplayName)).Append("</p>");
        html.Append("<table><thead><tr><th>Descripción</th><th>Cantidad</th><th>Unidad</th>");
        if (priced is not null)
            html.Append("<th>Precio neto</th><th>Descuento (%)</th><th>Importe neto</th>");
        html.Append("</tr></thead><tbody>");
        for (var index = 0; index < document.Lines.Count; index++)
        {
            var line = document.Lines[index];
            html.Append("<tr>");
            Cell(html, line.Description);
            Cell(html, Format(line.Quantity));
            Cell(html, line.Unit);
            if (priced is not null)
            {
                var price = priced.LinePricing[index];
                Cell(html, Format(price.NetUnitPrice));
                Cell(html, Format(price.DiscountPercent));
                Cell(html, Format(price.NetAmount));
            }
            html.Append("</tr>");
        }
        html.Append("</tbody></table>");
        if (priced is not null)
        {
            html.Append("<dl><dt>Moneda</dt><dd>").Append(WebUtility.HtmlEncode(priced.Currency))
                .Append("</dd><dt>Subtotal</dt><dd>").Append(Format(priced.Totals.Subtotal))
                .Append("</dd><dt>Impuesto</dt><dd>").Append(Format(priced.Totals.Tax))
                .Append("</dd><dt>Total</dt><dd>").Append(Format(priced.Totals.Total)).Append("</dd></dl>");
        }
        return html.Append("</html>").ToString();
    }

    private static void Cell(StringBuilder html, string value) =>
        html.Append("<td>").Append(WebUtility.HtmlEncode(value)).Append("</td>");

    private static string Format(decimal value) => value.ToString(CultureInfo.InvariantCulture);
}

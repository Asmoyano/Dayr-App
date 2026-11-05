# Requires an existing .NET HTTPS development certificate and the seeded LocalDB with migration 004.
# Pass the built DLL explicitly to support custom build locations.
param([string] $Dll = (Join-Path $PSScriptRoot '../bin/Debug/net10.0/Backend.dll'))

$ErrorActionPreference = 'Stop'
$Dll = (Resolve-Path $Dll).Path
$token1 = [Convert]::ToHexString([Security.Cryptography.RandomNumberGenerator]::GetBytes(32)).ToLowerInvariant()
$token2 = [Convert]::ToHexString([Security.Cryptography.RandomNumberGenerator]::GetBytes(32)).ToLowerInvariant()

function Assert($Condition, [string] $Message) {
    if (!$Condition) { throw $Message }
}

function Start-Api([string] $Environment, [bool] $Enabled, [int] $Port) {
    $start = [Diagnostics.ProcessStartInfo]::new('dotnet')
    $start.ArgumentList.Add($Dll)
    $start.ArgumentList.Add('--urls')
    $start.ArgumentList.Add("https://localhost:$Port")
    $start.WorkingDirectory = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
    $start.UseShellExecute = $false
    $start.CreateNoWindow = $true
    $start.Environment['DOTNET_ENVIRONMENT'] = $Environment
    $start.Environment['ASPNETCORE_ENVIRONMENT'] = $Environment
    $start.Environment['QuoteCatalog__Enabled'] = "$Enabled"
    $start.Environment['QuoteCatalog__Seller1Token'] = $token1
    $start.Environment['QuoteCatalog__Seller2Token'] = $token2
    $process = [Diagnostics.Process]::Start($start)
    try {
        for ($attempt = 0; $attempt -lt 40; $attempt++) {
            if ($process.HasExited) { throw "Backend exited with code $($process.ExitCode)" }
            try {
                # Only the isolated test's localhost connection accepts the development certificate.
                $ready = Invoke-WebRequest "https://localhost:$Port/v1/quote-catalog/clients" -SkipCertificateCheck -SkipHttpErrorCheck -TimeoutSec 2
                if ($ready.StatusCode -eq 401) { return $process }
            } catch { }
            Start-Sleep -Milliseconds 250
        }
        throw "Backend did not become ready on port $Port"
    } catch {
        if (!$process.HasExited) { $process.Kill(); $process.WaitForExit() }
        $process.Dispose()
        throw
    }
}

function Read-Api([string] $Path, [string] $Token, [int] $Status = 200, [hashtable] $Extra = @{}) {
    $headers = $Extra.Clone()
    if ($Token) { $headers['Authorization'] = "Bearer $Token" }
    $response = Invoke-WebRequest "$base/$Path" -Headers $headers -SkipCertificateCheck -SkipHttpErrorCheck
    Assert ($response.StatusCode -eq $Status) "$Path expected $Status, got $($response.StatusCode)"
    Assert ($response.Headers['Cache-Control'] -contains 'no-store') 'Missing no-store'
    Assert ($response.Headers['X-Correlation-ID'].Count -gt 0) 'Missing correlation ID'
    if ($Status -ge 400) {
        Assert ($response.Headers['Content-Type'] -like 'application/problem+json*') 'Missing ProblemDetails'
    }
    $response.Content | ConvertFrom-Json
}

$base = 'https://localhost:17216/v1/quote-catalog'
$api = Start-Api Development $true 17216
try {
    Read-Api clients '' 401 @{ 'X-Seller-Id' = 'SIM-V1' } | Out-Null
    Read-Api clients ('a' * 64) 401 | Out-Null
    Read-Api 'clients?limit=101' $token1 400 | Out-Null
    Read-Api 'products?after=%00' $token1 400 | Out-Null
    $first = Read-Api 'clients?limit=3&sellerId=SIM-V2' $token1 200 @{ 'X-Seller-Id' = 'SIM-V2' }
    $next = Read-Api "clients?limit=100&after=$($first.nextCursor)" $token1
    $other = Read-Api clients $token2
    $seller1Codes = @($first.items.code) + @($next.items.code)
    Assert ($first.items.Count -eq 3 -and $first.nextCursor -eq $first.items[-1].code -and !$next.nextCursor) 'Invalid pagination'
    Assert ($seller1Codes.Count -eq 20 -and ($seller1Codes | Sort-Object -Unique).Count -eq 20) 'Seller 1 portfolio count'
    Assert ($other.items.Count -eq 20 -and @($other.items.code | Where-Object { $_ -in $seller1Codes }).Count -eq 0) 'Portfolios overlap'
    Assert ('SIM-C1' -in $seller1Codes -and 'SIM-C21' -in $other.items.code) 'Unexpected portfolio codes'
    Read-Api 'clients/SIM-C21/prices' $token1 404 | Out-Null
    Read-Api 'clients/SIM-C1/prices' $token2 404 | Out-Null
    Read-Api 'clients/unknown/prices' $token1 404 | Out-Null

    $products1 = Read-Api 'products?limit=2&after=SIM-03-000' $token1
    $products2 = Read-Api 'products?limit=2&after=SIM-03-000' $token2
    Assert ($products1.items[0].code -eq 'SIM-04-001' -and $products2.items[0].code -eq 'SIM-03-001') 'Product permissions ignored'
    Assert ($products1.nextCursor -eq $products1.items[-1].code) 'Missing product cursor'
    $prices = Read-Api 'clients/SIM-C1/prices?limit=2' $token1
    $more = Read-Api "clients/SIM-C1/prices?limit=2&after=$($prices.nextCursor)" $token1
    $wholesale = Read-Api 'clients/SIM-C2/prices?limit=2' $token1
    $otherPrices = Read-Api 'clients/SIM-C21/prices?limit=2&after=SIM-03-000' $token2
    Assert ($otherPrices.items[0].productCode -eq 'SIM-03-001' -and $otherPrices.items[0].priceList -eq 'SIM-DISTRIBUIDOR') 'Seller 2 price scope'
    Assert ($prices.items.Count -eq 2 -and $prices.nextCursor -eq $prices.items[-1].productCode -and $more.items[0].productCode -gt $prices.nextCursor) 'Price pagination'
    Assert (!$prices.stockValidationEnabled -and $prices.netPriceTaxRate -ceq '0.1800') 'Unexpected tax or stock policy'
    $allPrices = @($prices.items) + @($more.items) + @($wholesale.items) + @($otherPrices.items)
    foreach ($price in $allPrices) {
        Assert ($price.currency -ceq 'PEN' -and $price.netUnitPrice -is [string] -and $price.netUnitPrice -match '^\d+\.\d{4}$') 'Invalid net price or currency'
        Assert ($price.sourceVersion -eq 'SIMULACION-V1' -and $price.validFromUtc -le $price.readAtUtc) 'Invalid price provenance'
    }
    Assert ($prices.items[0].priceList -eq 'SIM-MINORISTA' -and $wholesale.items[0].priceList -eq 'SIM-MAYORISTA') 'Incorrect client lists'
    Assert ([decimal]$wholesale.items[0].netUnitPrice -eq [decimal]$prices.items[0].netUnitPrice * 0.93d) 'Net price differs from seed factor'
    $openApi = Invoke-RestMethod 'https://localhost:17216/openapi/v1.json' -SkipCertificateCheck
    Assert ($null -ne $openApi.paths.'/v1/quote-catalog/products'.get.security[0].DayrQuoteBearer) 'Missing OpenAPI bearer requirement'
} finally {
    $api.Kill()
    $api.WaitForExit()
    $api.Dispose()
}

$api = Start-Api Production $true 17216
try {
    Read-Api clients $token1 401 | Out-Null
} finally {
    $api.Kill()
    $api.WaitForExit()
    $api.Dispose()
}
Write-Host 'PASS: LocalDB quote API, pagination, portfolio isolation, price and tax contract, errors, OpenAPI and production guard.'

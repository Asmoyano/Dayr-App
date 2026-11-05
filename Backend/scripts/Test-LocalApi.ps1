param(
    [string]$BaseUrl = "https://localhost:7216",
    [string]$AllowedOrigin = "http://localhost:5173"
)

$ErrorActionPreference = "Stop"
$BaseUrl = $BaseUrl.TrimEnd('/')
function Assert-Check([bool]$Condition, [string]$Name) {
    if (-not $Condition) { throw "FALLO: $Name" }
    Write-Host "OK: $Name"
}
function Get-Response([string]$Path, [string]$Method = "GET", [hashtable]$Headers = @{}) {
    Invoke-WebRequest -Uri ($BaseUrl + $Path) -Method $Method -Headers $Headers -SkipHttpErrorCheck -TimeoutSec 15
}

function Read-Json($Response) {
    $content = $Response.Content
    if ($content -is [byte[]]) { $content = [Text.Encoding]::UTF8.GetString($content) }
    ConvertFrom-Json -InputObject ([string]$content)
}

$health = Get-Response '/health'
$healthBody = Read-Json $health
Assert-Check ($health.StatusCode -eq 200 -and $healthBody.status -eq 'Healthy' -and $healthBody.scope -eq 'Process') 'Salud del proceso, sin dependencias empresariales'
Assert-Check ($healthBody.dataMode -eq 'Synthetic') 'Entorno de prueba con catálogo sintético'
Assert-Check ($health.Headers['Cache-Control'] -contains 'no-store') 'Respuesta no almacenable'

$catalog = Get-Response '/v1/inventory/products'
$products = @(Read-Json $catalog)
Assert-Check ($catalog.StatusCode -eq 200 -and $products.Count -eq 3) 'Catálogo ficticio de tres productos'
$required = @('id','sku','barcode','name','brand','unit','aisle','shelf','erpStock','physicalStock','unitPrice','lastCountAt','lastCountBy')
foreach ($product in $products) {
    foreach ($field in $required) { Assert-Check ($product.PSObject.Properties.Name -ccontains $field) "Campo Product.$field" }
    Assert-Check ($product.id.StartsWith('test-') -and $product.sku.StartsWith('TEST-')) 'Identidad ficticia'
    Assert-Check ($product.unitPrice -ge 0 -and $product.erpStock -ge 0) 'Números no negativos'
}

$openapi = Get-Response '/openapi/v1.json'
$paths = (Read-Json $openapi).paths.PSObject.Properties.Name
Assert-Check ($openapi.StatusCode -eq 200 -and $paths -contains '/health' -and $paths -contains '/v1/inventory/products') 'OpenAPI contiene los contratos nuevos'

$preflightHeaders = @{Origin=$AllowedOrigin; 'Access-Control-Request-Method'='GET'; 'Access-Control-Request-Headers'='content-type,authorization'}
$allowed = Get-Response '/v1/inventory/products' 'OPTIONS' $preflightHeaders
Assert-Check ($allowed.StatusCode -eq 204 -and $allowed.Headers['Access-Control-Allow-Origin'] -contains $AllowedOrigin) 'CORS permite el origen autorizado'
$denied = Get-Response '/v1/inventory/products' 'OPTIONS' @{Origin='https://origen-no-autorizado.invalid'; 'Access-Control-Request-Method'='GET'}
Assert-Check (-not $denied.Headers.ContainsKey('Access-Control-Allow-Origin')) 'CORS no autoriza el origen ficticio externo'

foreach ($case in @(@{Path='/ruta-inexistente'; Method='GET'; Status=404}, @{Path='/v1/inventory/products'; Method='POST'; Status=405})) {
    $response = Get-Response $case.Path $case.Method
    $problem = Read-Json $response
    Assert-Check ($response.StatusCode -eq $case.Status -and $problem.status -eq $case.Status) "Error estructurado $($case.Status)"
    Assert-Check (($response.Headers['Content-Type'] -join ',') -like 'application/problem+json*') 'ProblemDetails JSON'
    Assert-Check ($response.Headers['X-Correlation-ID'] -contains $problem.traceId) 'TraceId correlacionado'
    Assert-Check (-not ($problem.PSObject.Properties.Name -contains 'exception')) 'Sin excepción pública'
}
Write-Host 'Smoke local completado. No valida autenticación, persistencia ni ERP.'

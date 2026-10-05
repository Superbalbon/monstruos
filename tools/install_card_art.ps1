$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path -Parent $PSScriptRoot
$sourceRoot = Join-Path $projectRoot 'assets/art_originals'
$targetRoot = Join-Path $projectRoot 'assets/cards'
$cards = (Get-Content -LiteralPath (Join-Path $projectRoot 'data/cartas_prototipo.json') -Raw -Encoding UTF8 | ConvertFrom-Json).cartas
$folders = @{ Humanos='humanos'; 'Hombres Lobo'='hombres_lobo'; Vampiros='vampiros'; Fantasmas='fantasmas' }
$plan = @()
foreach ($card in $cards) {
    $folder = $folders[$card.faccion]
    $sources = @(Get-ChildItem -LiteralPath (Join-Path $sourceRoot $folder) -File | Where-Object { $_.BaseName -match ('^' + [regex]::Escape($card.id) + '(?:\s|_|$)') -and $_.Extension -eq '.png' })
    if ($sources.Count -ne 1) { throw "Se esperaba un original PNG para $($card.id); encontrados: $($sources.Count)" }
    $slug = $card.nombre.Normalize([Text.NormalizationForm]::FormD) -replace '\p{Mn}', ''
    $slug = ($slug.ToLowerInvariant() -replace '[^a-z0-9]+', '_').Trim('_')
    $name = "$($card.id)_$slug.png"
    $target = Join-Path (Join-Path $targetRoot $folder) $name
    if ((Test-Path -LiteralPath $target) -and (Get-FileHash -LiteralPath $target).Hash -ne (Get-FileHash -LiteralPath $sources[0].FullName).Hash) {
        throw "El destino ya existe y es diferente; no se sobrescribe: $target"
    }
    $plan += [PSCustomObject]@{ id=$card.id; source=$sources[0].FullName; target=$target; resource="res://assets/cards/$folder/$name" }
}
# Validate every mapping before copying. Originals are never renamed or modified.
foreach ($entry in $plan) {
    if (-not (Test-Path -LiteralPath $entry.target)) {
        Copy-Item -LiteralPath $entry.source -Destination $entry.target
    }
    if ((Get-FileHash -LiteralPath $entry.source).Hash -ne (Get-FileHash -LiteralPath $entry.target).Hash) { throw "Copia no verificada: $($entry.id)" }
}
$plan | Select-Object id,resource | ConvertTo-Json

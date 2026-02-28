param(
    [switch]$Run
)

$ErrorActionPreference = 'Stop'

$outDir = Join-Path $PSScriptRoot '..\out'
$bootSrc = Join-Path $PSScriptRoot '..\bootloader\boot.asm'
$kernelSrc = Join-Path $PSScriptRoot '..\kernel\kernel.asm'
$bootBin = Join-Path $outDir 'boot.bin'
$kernelBin = Join-Path $outDir 'kernel.bin'
$image = Join-Path $outDir 'silver.img'

if (-not (Get-Command nasm -ErrorAction SilentlyContinue)) {
    throw 'nasm not found in PATH. Install NASM and reopen the terminal.'
}

if (-not (Test-Path $outDir)) {
    New-Item -ItemType Directory -Path $outDir | Out-Null
}

& nasm -f bin $bootSrc -o $bootBin
& nasm -f bin $kernelSrc -o $kernelBin

$floppySize = 1474560
$fs = [System.IO.File]::Create($image)
$fs.SetLength($floppySize)
$fs.Close()

$imgBytes = [System.IO.File]::ReadAllBytes($image)
$bootBytes = [System.IO.File]::ReadAllBytes($bootBin)
$kernelBytes = [System.IO.File]::ReadAllBytes($kernelBin)

[Array]::Copy($bootBytes, 0, $imgBytes, 0, [Math]::Min($bootBytes.Length, 512))
[Array]::Copy($kernelBytes, 0, $imgBytes, 512, [Math]::Min($kernelBytes.Length, $imgBytes.Length - 512))

[System.IO.File]::WriteAllBytes($image, $imgBytes)
Write-Host "Built image: $image"

if ($Run) {
    if (-not (Get-Command qemu-system-i386 -ErrorAction SilentlyContinue)) {
        throw 'qemu-system-i386 not found in PATH. Install QEMU or run without -Run.'
    }
    & qemu-system-i386 -drive "format=raw,file=$image"
}

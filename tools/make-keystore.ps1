# SPDX-FileCopyrightText: 2026 Sprime contributors
# SPDX-License-Identifier: GPL-3.0-or-later
#
# Creates a release keystore and the matching keystore.properties.
# Keep both files private: they are listed in .gitignore.

param(
    [string]$Alias = "sprime",
    [string]$Password = "",
    [string]$OutDir = ".secrets"
)

$ErrorActionPreference = "Stop"
$root = Split-Path -Parent $PSScriptRoot
Set-Location $root

if ([string]::IsNullOrWhiteSpace($Password)) {
    $bytes = New-Object byte[] 24
    [System.Security.Cryptography.RandomNumberGenerator]::Create().GetBytes($bytes)
    $Password = ([Convert]::ToBase64String($bytes) -replace '[^A-Za-z0-9]', '')
}

New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$store = Join-Path $OutDir "sprime-release.jks"
$storeProp = $store.Replace([char]92, [char]47)

if (Test-Path $store) {
    Write-Host "Keystore already exists: $store"
} else {
    $toolArgs = @(
        "-genkeypair", "-v",
        "-keystore", $store,
        "-alias", $Alias,
        "-keyalg", "RSA", "-keysize", "4096", "-validity", "10000",
        "-storepass", $Password, "-keypass", $Password,
        "-dname", "CN=Sprime, OU=Sprime, O=Sprime, C=CN"
    )
    & keytool @toolArgs
}

$lines = @(
    "storeFile=$storeProp",
    "storePassword=$Password",
    "keyAlias=$Alias",
    "keyPassword=$Password"
)
$lines | Set-Content -Path "keystore.properties" -Encoding ASCII

Write-Host "Wrote keystore.properties and $store"
Write-Host "Run: .\gradlew.bat :app:assembleRelease -PbuildAbi=arm64-v8a"

$sourceFolder = "E:\BACKUP_SCRIPT\out" # Папка с частями файлов
$destinationFolder = "E:\BACKUP_SCRIPT\reconstructed" # Папка для восстановления файлов

# Создать папку назначения, если она не существует
if (-not (Test-Path $destinationFolder)) {
    New-Item -Path $destinationFolder -ItemType Directory
}

# Группировать части файлов по их исходному имени
$parts = Get-ChildItem -Path $sourceFolder -Filter "*.part*" | 
    Group-Object { $_.Name -replace "\.part\d+$" }

foreach ($group in $parts) {
    $originalFileName = $group.Name
    $destinationFilePath = Join-Path -Path $destinationFolder -ChildPath $originalFileName
    $fileStream = [System.IO.File]::OpenWrite($destinationFilePath)
    
    foreach ($partFile in $group.Group | Sort-Object Name) {
        $partStream = [System.IO.File]::OpenRead($partFile.FullName)
        $buffer = New-Object byte[] $partStream.Length
        $bytesRead = $partStream.Read($buffer, 0, $buffer.Length)
        $fileStream.Write($buffer, 0, $bytesRead)
        $partStream.Close()
    }
    
    $fileStream.Close()
    Write-Output "Reconstructed file: $destinationFilePath"
}

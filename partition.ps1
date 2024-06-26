$sourceFolder = "E:\SVADBA"
$destinationFolder = "E:\BACKUP_SCRIPT\out"

# Set the maximum chunk size (e.g. 100MB)
$maxChunkSize = 500MB

# Get the list of large files in the source folder
$largeFiles = Get-ChildItem -Path $sourceFolder -Filter * -Recurse | Where-Object {$_.Length -gt $maxChunkSize}

# Loop through each large file
foreach ($file in $largeFiles) {
    # Split the file into chunks
    $chunkNumber = 1
    $reader = [System.IO.File]::OpenRead($file.FullName)
    $buffer = New-Object byte[] $maxChunkSize
    while ($reader.Read($buffer, 0, $buffer.Length) -gt 0) {
        $chunkPath = Join-Path -Path $destinationFolder -ChildPath ($file.Name + ".part$chunkNumber")
        $writer = [System.IO.File]::OpenWrite($chunkPath)
        $writer.Write($buffer, 0, $buffer.Length)
        $writer.Close()
        $chunkNumber++
    }
    $reader.Close()
}

$names = dvc queue status  | ForEach-Object { 
    $line = $_.Trim()
    if ($line -like "*Queued*") {
             ($line -split '\s+')[1] } 
}
      
Write-Host $names


foreach ($n in $names) {
    if ($n) {
        Write-Host "Processing Experiment: $n" -ForegroundColor Green
        dvc exp run --name $n
    }
}
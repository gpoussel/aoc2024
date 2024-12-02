
function Part1($file) {
    $safe_lines = 0
    foreach ($line in $file) {
        $numbers = $line -split ' ' | ForEach-Object { [int]$_ }
        $sig = 0
        if ($numbers[1] -gt $numbers[0]) {
            $sig = 1
        } elseif ($numbers[1] -lt $numbers[0]) {
            $sig = -1
        }
        $safe_line = 1
        for ($i = 1; $i -lt $numbers.Length -and $safe_line -eq 1; $i++) {
            if ($sig -eq 1 -and $numbers[$i] -lt $numbers[$i - 1]) {
                $safe_line = 0
            } elseif ($sig -eq -1 -and $numbers[$i] -gt $numbers[$i - 1]) {
                $safe_line = 0
            }
            $diff = [math]::Abs($numbers[$i] - $numbers[$i - 1])
            if ($diff -gt 3 -or $diff -eq 0) {
                $safe_line = 0
            }
        }
        if ($safe_line) {
            $safe_lines++
        }
    }

    Write-Host "Part 1: " $safe_lines
}

Write-Host "Example:"
Part1(Get-Content -Path ./example)


Write-Host "Input:"
Part1(Get-Content -Path ./input)


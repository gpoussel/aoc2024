function IsSafe($numbers) {
    $sig = 0
    if ($numbers[1] -gt $numbers[0]) {
        $sig = 1
    } elseif ($numbers[1] -lt $numbers[0]) {
        $sig = -1
    }
    for ($i = 1; $i -lt $numbers.Length; $i++) {
        if ($sig -eq 1 -and $numbers[$i] -lt $numbers[$i - 1]) {
            return 0
        } elseif ($sig -eq -1 -and $numbers[$i] -gt $numbers[$i - 1]) {
            return 0
        }
        $diff = [math]::Abs($numbers[$i] - $numbers[$i - 1])
        if ($diff -gt 3 -or $diff -eq 0) {
            return 0
        }
    }
    return 1
}

function IsSafeAfterAnyRemoval($numbers) {
    for ($i = 0; $i -lt $numbers.Length; $i++) {
        $new_numbers = @()
        for ($j = 0; $j -lt $numbers.Length; $j++) {
            if ($j -ne $i) {
                $new_numbers += $numbers[$j]
            }
        }
        if (IsSafe($new_numbers)) {
            return 1
        }
    }
    return 0
}

function Part1($file) {
    $safe_lines = 0
    foreach ($line in $file) {
        $numbers = $line -split ' ' | ForEach-Object { [int]$_ }
        if (IsSafe($numbers)) {
            $safe_lines++
        }
    }

    Write-Host "Part 1: " $safe_lines
}

function Part2($file) {
    $safe_lines = 0
    foreach ($line in $file) {
        $numbers = $line -split ' ' | ForEach-Object { [int]$_ }
        if (IsSafe($numbers)) {
            $safe_lines++
        } elseif (IsSafeAfterAnyRemoval($numbers)) {
            $safe_lines++
        }
    }

    Write-Host "Part 2: " $safe_lines
}

Write-Host "Example:"
Part1(Get-Content -Path ./example)
Part2(Get-Content -Path ./example)


Write-Host "Input:"
Part1(Get-Content -Path ./input)
Part2(Get-Content -Path ./input)


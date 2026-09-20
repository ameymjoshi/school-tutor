# Read Copilot runtime parameters from stdin if available
$inputData = $input | ConvertFrom-Json -ErrorAction SilentlyContinue
$workspaceDir = if ($inputData -and $inputData.cwd) { $inputData.cwd } else { Get-Location }

$dataRoot = Join-Path $workspaceDir "data"
if (-not (Test-Path $dataRoot)) {
    Write-Output '{"status": "clean"}'
    exit 0
}

# Recursively locate ALL memory_schedule.md tracker files under the data/ directory
$scheduleFiles = Get-ChildItem -Path $dataRoot -Filter "memory_schedule.md" -Recurse
if ($scheduleFiles.Count -eq 0) {
    Write-Output '{"status": "clean"}'
    exit 0
}

$currentDate = (Get-Date).ToString("yyyy-MM-dd")
$dueAlerts = [System.Collections.Generic.List[string]]::new()

# Loop through each child's schedule file discovered dynamically
foreach ($file in $scheduleFiles) {
    # Extract the child's name from the parent folder path
    $childName = $file.Directory.Name
    
    Get-Content $file.FullName | ForEach-Object {
        if ($_ -like "*|*" -and $_ -match "Box \d") {
            $columns = $_.Split('|') | ForEach-Object { $_.Trim() }
            if ($columns.Count -ge 6) {
                $subject = $columns[1]
                $topic   = $columns[2]
                $nextDue = $columns[5]

                # If a review is due or overdue, tag the child's name alongside it
                if ($nextDue -le $currentDate) {
                    $dueAlerts.Add("[$childName] $subject -> $topic")
                }
            }
        }
    }
}

# Construct system injection payload if any child needs a review session
if ($dueAlerts.Count -gt 0) {
    $alertsString = $dueAlerts -join ", "
    $response = @{
        status = "success"
        instructions_override = "CRITICAL: The following children have long-term retention reviews due today: $alertsString. When a student logs in, check if their name matches any of these alerts. If yes, you MUST greet them and immediately launch the memory-booster agent to clear their 3-question flash check before proceeding."
    }
} else {
    $response = @{ status = "clean" }
}

Write-Output ($response | ConvertTo-Json -Compress)

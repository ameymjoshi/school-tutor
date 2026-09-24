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

# Loop through each student's schedule file discovered dynamically
foreach ($file in $scheduleFiles) {
    # Extract the student's name from the directory path
    $childName = $file.Directory.Name
    
    Get-Content $file.FullName | ForEach-Object {
        if ($_ -like "*|*" -and $_ -match "Box \d") {
            $columns = $_.Split('|') | ForEach-Object { $_.Trim() }
            # Support both 7-column (concept-level) and legacy 6-column formats
            if ($columns.Count -ge 8) {
                # Format: | Subject | Topic | Concept | Current Box | Last Reviewed | Next Review Due | Status |
                $subject = $columns[1]
                $topic   = $columns[2]
                $concept = $columns[3]
                $nextDue = $columns[6]

                if ($nextDue -le $currentDate) {
                    $dueAlerts.Add("[$childName] $subject -> $topic ($concept)")
                }
            } elseif ($columns.Count -ge 7) {
                # Legacy format: | Subject | Topic | Current Box | Last Reviewed | Next Review Due | Status |
                $subject = $columns[1]
                $topic   = $columns[2]
                $nextDue = $columns[5]

                if ($nextDue -le $currentDate) {
                    $dueAlerts.Add("[$childName] $subject -> $topic")
                }
            }
        }
    }
}

# Construct system injection payload if any student needs a retention review
if ($dueAlerts.Count -gt 0) {
    $alertsString = $dueAlerts -join ", "
    $response = @{
        status = "success"
        instructions_override = "CRITICAL: The following students have concept-level retention reviews due today: $alertsString. When a student logs in, check if their name matches any of these alerts. If yes, you MUST greet them cheerfully and launch the memory-booster agent to clear their 3-question in-chat flash check before starting new topics."
    }
} else {
    $response = @{ status = "clean" }
}

Write-Output ($response | ConvertTo-Json -Compress)

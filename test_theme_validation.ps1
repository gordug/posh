# Oh My Posh Theme Validation Tests
# Tests for new segments: session, executiontime, status, azure

param(
    [string]$ThemeFile = "solarized_dark.omp.json"
)

# Test framework functions
function Test-Assert {
    param(
        [bool]$Condition,
        [string]$Message,
        [string]$TestName
    )
    
    if ($Condition) {
        Write-Host "✅ PASS: $TestName - $Message" -ForegroundColor Green
        return $true
    } else {
        Write-Host "❌ FAIL: $TestName - $Message" -ForegroundColor Red
        return $false
    }
}

function Test-SegmentExists {
    param(
        [object]$Theme,
        [string]$SegmentType,
        [string]$TestName
    )
    
    $segment = $Theme.blocks.segments | Where-Object { $_.type -eq $SegmentType }
    return Test-Assert -Condition ($null -ne $segment) -Message "Segment '$SegmentType' exists in theme" -TestName $TestName
}

function Test-SegmentProperty {
    param(
        [object]$Segment,
        [string]$PropertyPath,
        [object]$ExpectedValue,
        [string]$TestName
    )
    
    $actualValue = $Segment
    foreach ($prop in $PropertyPath.Split('.')) {
        $actualValue = $actualValue.$prop
    }
    
    $condition = if ($ExpectedValue -is [string]) {
        $actualValue -eq $ExpectedValue
    } elseif ($ExpectedValue -is [bool]) {
        $actualValue -eq $ExpectedValue
    } elseif ($ExpectedValue -is [int]) {
        $actualValue -eq $ExpectedValue
    } else {
        $actualValue -ne $null
    }
    
    return Test-Assert -Condition $condition -Message "Property '$PropertyPath' = '$actualValue' (expected: '$ExpectedValue')" -TestName $TestName
}

# Load and parse theme
Write-Host "🔍 Loading theme file: $ThemeFile" -ForegroundColor Cyan

if (-not (Test-Path $ThemeFile)) {
    Write-Host "❌ Theme file not found: $ThemeFile" -ForegroundColor Red
    exit 1
}

try {
    $theme = Get-Content $ThemeFile | ConvertFrom-Json
} catch {
    Write-Host "❌ Failed to parse theme JSON: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host "📋 Running theme validation tests..." -ForegroundColor Cyan
$testResults = @()

# Test 1: Session Segment Validation
Write-Host "`n🔐 Testing Session Segment..." -ForegroundColor Yellow
$sessionSegment = $theme.blocks[0].segments | Where-Object { $_.type -eq "session" }

$testResults += Test-SegmentExists -Theme $theme -SegmentType "session" -TestName "Session-Exists"
if ($sessionSegment) {
    $testResults += Test-SegmentProperty -Segment $sessionSegment -PropertyPath "style" -ExpectedValue "powerline" -TestName "Session-Style"
    $testResults += Test-SegmentProperty -Segment $sessionSegment -PropertyPath "powerline_symbol" -ExpectedValue "uE0B0" -TestName "Session-PowerlineSymbol"
    $testResults += Test-SegmentProperty -Segment $sessionSegment -PropertyPath "properties.ssh_icon" -ExpectedValue "🌐" -TestName "Session-SSHIcon"
    $testResults += Test-SegmentProperty -Segment $sessionSegment -PropertyPath "properties.user_info_separator" -ExpectedValue "@" -TestName "Session-UserSeparator"
    $testResults += Test-SegmentProperty -Segment $sessionSegment -PropertyPath "foreground" -ExpectedValue "#073642" -TestName "Session-Foreground"
    $testResults += Test-SegmentProperty -Segment $sessionSegment -PropertyPath "background" -ExpectedValue "#dc322f" -TestName "Session-Background"
}

# Test 2: Execution Time Segment Validation
Write-Host "`n⏱️ Testing Execution Time Segment..." -ForegroundColor Yellow
$execTimeSegment = $theme.blocks[1].segments | Where-Object { $_.type -eq "executiontime" }

$testResults += Test-SegmentExists -Theme $theme -SegmentType "executiontime" -TestName "ExecTime-Exists"
if ($execTimeSegment) {
    $testResults += Test-SegmentProperty -Segment $execTimeSegment -PropertyPath "style" -ExpectedValue "plain" -TestName "ExecTime-Style"
    $testResults += Test-SegmentProperty -Segment $execTimeSegment -PropertyPath "properties.threshold" -ExpectedValue 500 -TestName "ExecTime-Threshold"
    $testResults += Test-SegmentProperty -Segment $execTimeSegment -PropertyPath "properties.style" -ExpectedValue "roundrock" -TestName "ExecTime-TimeStyle"
    $testResults += Test-SegmentProperty -Segment $execTimeSegment -PropertyPath "properties.prefix" -ExpectedValue "⏱️ " -TestName "ExecTime-Prefix"
    $testResults += Test-SegmentProperty -Segment $execTimeSegment -PropertyPath "foreground" -ExpectedValue "#b58900" -TestName "ExecTime-Foreground"
}

# Test 3: Status Segment Validation
Write-Host "`n✅ Testing Status Segment..." -ForegroundColor Yellow
$statusSegment = $theme.blocks[2].segments | Where-Object { $_.type -eq "status" }

$testResults += Test-SegmentExists -Theme $theme -SegmentType "status" -TestName "Status-Exists"
if ($statusSegment) {
    $testResults += Test-SegmentProperty -Segment $statusSegment -PropertyPath "style" -ExpectedValue "powerline" -TestName "Status-Style"
    $testResults += Test-SegmentProperty -Segment $statusSegment -PropertyPath "properties.always_enabled" -ExpectedValue $true -TestName "Status-AlwaysEnabled"
    
    # Test conditional logic template
    $prefixTemplate = $statusSegment.properties.prefix
    $testResults += Test-Assert -Condition ($prefixTemplate -like "*if gt .Code 0*") -Message "Status prefix contains conditional logic for error codes" -TestName "Status-ConditionalPrefix"
    $testResults += Test-Assert -Condition ($prefixTemplate -like "*❌*") -Message "Status prefix contains error icon" -TestName "Status-ErrorIcon"
    $testResults += Test-Assert -Condition ($prefixTemplate -like "*✅*") -Message "Status prefix contains success icon" -TestName "Status-SuccessIcon"
    
    # Test background templates
    $bgTemplate = $statusSegment.background_templates[0]
    $testResults += Test-Assert -Condition ($bgTemplate -like "*if gt .Code 0*") -Message "Status background template contains conditional logic" -TestName "Status-ConditionalBackground"
    $testResults += Test-Assert -Condition ($bgTemplate -like "*#dc322f*") -Message "Status background template contains error color" -TestName "Status-ErrorColor"
}

# Test 4: Azure Segment Validation
Write-Host "`n☁️ Testing Azure Segment..." -ForegroundColor Yellow
$azureSegment = $theme.blocks[2].segments | Where-Object { $_.type -eq "azure" }

$testResults += Test-SegmentExists -Theme $theme -SegmentType "azure" -TestName "Azure-Exists"
if ($azureSegment) {
    $testResults += Test-SegmentProperty -Segment $azureSegment -PropertyPath "style" -ExpectedValue "powerline" -TestName "Azure-Style"
    $testResults += Test-SegmentProperty -Segment $azureSegment -PropertyPath "properties.prefix" -ExpectedValue "☁️ " -TestName "Azure-Prefix"
    $testResults += Test-SegmentProperty -Segment $azureSegment -PropertyPath "properties.display_mode" -ExpectedValue "context" -TestName "Azure-DisplayMode"
    $testResults += Test-SegmentProperty -Segment $azureSegment -PropertyPath "properties.missing_command_text" -ExpectedValue "" -TestName "Azure-MissingCommandText"
    $testResults += Test-SegmentProperty -Segment $azureSegment -PropertyPath "foreground" -ExpectedValue "#268bd2" -TestName "Azure-Foreground"
}

# Test 5: Enhanced Git Segment Validation
Write-Host "`n🔀 Testing Enhanced Git Segment..." -ForegroundColor Yellow
$gitSegment = $theme.blocks[2].segments | Where-Object { $_.type -eq "git" }

if ($gitSegment) {
    $testResults += Test-SegmentProperty -Segment $gitSegment -PropertyPath "properties.branch_icon" -ExpectedValue "🔀 " -TestName "Git-BranchIcon"
    $testResults += Test-SegmentProperty -Segment $gitSegment -PropertyPath "properties.commit_icon" -ExpectedValue "📝 " -TestName "Git-CommitIcon"
    $testResults += Test-SegmentProperty -Segment $gitSegment -PropertyPath "properties.branch_ahead_icon" -ExpectedValue "⬆️" -TestName "Git-AheadIcon"
    $testResults += Test-SegmentProperty -Segment $gitSegment -PropertyPath "properties.branch_behind_icon" -ExpectedValue "⬇️" -TestName "Git-BehindIcon"
    $testResults += Test-SegmentProperty -Segment $gitSegment -PropertyPath "properties.status.added" -ExpectedValue "➕" -TestName "Git-AddedIcon"
    $testResults += Test-SegmentProperty -Segment $gitSegment -PropertyPath "properties.status.modified" -ExpectedValue "📝" -TestName "Git-ModifiedIcon"
    $testResults += Test-SegmentProperty -Segment $gitSegment -PropertyPath "properties.status.staged" -ExpectedValue "🎯" -TestName "Git-StagedIcon"
}

# Test 6: Enhanced .NET Segment Validation
Write-Host "`n🔷 Testing Enhanced .NET Segment..." -ForegroundColor Yellow
$dotnetSegment = $theme.blocks[2].segments | Where-Object { $_.type -eq "dotnet" }

if ($dotnetSegment) {
    $testResults += Test-SegmentProperty -Segment $dotnetSegment -PropertyPath "properties.prefix" -ExpectedValue "🔷 .NET " -TestName "DotNet-Prefix"
    $testResults += Test-SegmentProperty -Segment $dotnetSegment -PropertyPath "properties.display_version" -ExpectedValue $true -TestName "DotNet-DisplayVersion"
    $testResults += Test-SegmentProperty -Segment $dotnetSegment -PropertyPath "properties.display_mode" -ExpectedValue "context" -TestName "DotNet-DisplayMode"
    $testResults += Test-SegmentProperty -Segment $dotnetSegment -PropertyPath "properties.missing_command_text" -ExpectedValue "" -TestName "DotNet-MissingCommandText"
}

# Test Summary
Write-Host "`n📊 Test Results Summary:" -ForegroundColor Cyan
$totalTests = $testResults.Count
$passedTests = ($testResults | Where-Object { $_ -eq $true }).Count
$failedTests = $totalTests - $passedTests

Write-Host "Total Tests: $totalTests" -ForegroundColor White
Write-Host "Passed: $passedTests" -ForegroundColor Green
Write-Host "Failed: $failedTests" -ForegroundColor Red

if ($failedTests -eq 0) {
    Write-Host "`n🎉 All tests passed! Theme validation successful." -ForegroundColor Green
    exit 0
} else {
    Write-Host "`n⚠️ Some tests failed. Please review the theme configuration." -ForegroundColor Yellow
    exit 1
} 
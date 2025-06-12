#!/usr/bin/env pwsh

# Oh My Posh Theme Test Runner
# This script runs comprehensive validation tests for the theme

param(
    [string]$ThemeFile = "solarized_dark.omp.json",
    [string]$ConfigFile = "theme-test-config.json",
    [switch]$Verbose,
    [switch]$CIMode,
    [string]$OutputFormat = "console" # console, json, junit
)

# Test runner configuration
$ErrorActionPreference = "Stop"
$script:TestResults = @()
$script:StartTime = Get-Date

function Write-TestOutput {
    param(
        [string]$Message,
        [string]$Level = "Info" # Info, Success, Warning, Error
    )
    
    if ($CIMode -and $OutputFormat -eq "console") {
        # CI-friendly output
        switch ($Level) {
            "Success" { Write-Host "##[section]✅ $Message" }
            "Error" { Write-Host "##[error]❌ $Message" }
            "Warning" { Write-Host "##[warning]⚠️ $Message" }
            default { Write-Host "##[debug]ℹ️ $Message" }
        }
    } else {
        # Regular console output
        $colors = @{
            "Success" = "Green"
            "Error" = "Red"
            "Warning" = "Yellow"
            "Info" = "Cyan"
        }
        Write-Host $Message -ForegroundColor $colors[$Level]
    }
}

function Test-Prerequisites {
    Write-TestOutput "🔍 Checking prerequisites..." -Level "Info"
    
    # Check PowerShell version
    if ($PSVersionTable.PSVersion.Major -lt 7) {
        Write-TestOutput "PowerShell 7+ required. Current version: $($PSVersionTable.PSVersion)" -Level "Warning"
    }
    
    # Check Oh My Posh installation
    try {
        $ompVersion = oh-my-posh version 2>$null
        if ($ompVersion) {
            Write-TestOutput "Oh My Posh version: $ompVersion" -Level "Success"
        }
    } catch {
        Write-TestOutput "Oh My Posh not found or not in PATH" -Level "Warning"
    }
    
    # Check theme file exists
    if (-not (Test-Path $ThemeFile)) {
        Write-TestOutput "Theme file not found: $ThemeFile" -Level "Error"
        exit 1
    }
    
    # Check config file exists
    if (-not (Test-Path $ConfigFile)) {
        Write-TestOutput "Test config file not found: $ConfigFile" -Level "Warning"
    }
}

function Invoke-ThemeValidation {
    Write-TestOutput "🧪 Running theme validation tests..." -Level "Info"
    
    try {
        $result = & ".\test_theme_validation.ps1" -ThemeFile $ThemeFile
        $exitCode = $LASTEXITCODE
        
        if ($exitCode -eq 0) {
            Write-TestOutput "Theme validation passed!" -Level "Success"
            return $true
        } else {
            Write-TestOutput "Theme validation failed with exit code: $exitCode" -Level "Error"
            return $false
        }
    } catch {
        Write-TestOutput "Error running theme validation: $($_.Exception.Message)" -Level "Error"
        return $false
    }
}

function Test-ThemePerformance {
    Write-TestOutput "⚡ Running performance tests..." -Level "Info"
    
    try {
        $theme = Get-Content $ThemeFile | ConvertFrom-Json
        
        # Load performance thresholds from config
        $maxSegmentsPerBlock = 15  # Default fallback
        $maxTotalSegments = 45     # Default: 3 blocks * 15 segments
        
        if (Test-Path $ConfigFile) {
            try {
                $config = Get-Content $ConfigFile | ConvertFrom-Json
                if ($config.performance_tests.segment_count.max_segments_per_block) {
                    $maxSegmentsPerBlock = $config.performance_tests.segment_count.max_segments_per_block
                    $maxTotalSegments = $maxSegmentsPerBlock * 3  # Assume max 3 blocks
                }
            } catch {
                Write-TestOutput "Warning: Could not load config, using defaults" -Level "Warning"
            }
        }
        
        $totalSegments = 0
        $blockIndex = 0
        $performanceIssues = @()
        
        foreach ($block in $theme.blocks) {
            if ($block.segments) {
                $blockSegmentCount = $block.segments.Count
                $totalSegments += $blockSegmentCount
                $blockIndex++
                
                Write-TestOutput "Block $blockIndex segments: $blockSegmentCount" -Level "Info"
                
                if ($blockSegmentCount -gt $maxSegmentsPerBlock) {
                    $performanceIssues += "Block $blockIndex has $blockSegmentCount segments (max: $maxSegmentsPerBlock)"
                }
            }
        }
        
        Write-TestOutput "Total segments: $totalSegments (max recommended: $maxTotalSegments)" -Level "Info"
        
        if ($totalSegments -gt $maxTotalSegments) {
            $performanceIssues += "Total segment count $totalSegments exceeds recommended maximum of $maxTotalSegments"
        }
        
        if ($performanceIssues.Count -gt 0) {
            foreach ($issue in $performanceIssues) {
                Write-TestOutput "Performance Warning: $issue" -Level "Warning"
            }
            return $false
        }
        
        Write-TestOutput "Performance check passed" -Level "Success"
        return $true
    } catch {
        Write-TestOutput "Error in performance test: $($_.Exception.Message)" -Level "Error"
        return $false
    }
}

function Test-ThemeAccessibility {
    Write-TestOutput "♿ Running accessibility tests..." -Level "Info"
    
    try {
        $theme = Get-Content $ThemeFile | ConvertFrom-Json
        $colorIssues = @()
        
        # Check for sufficient color contrast (simplified)
        foreach ($block in $theme.blocks) {
            if ($block.segments) {
                foreach ($segment in $block.segments) {
                    if ($segment.foreground -eq $segment.background) {
                        $colorIssues += "Segment '$($segment.type)' has identical foreground and background colors"
                    }
                }
            }
        }
        
        if ($colorIssues.Count -gt 0) {
            foreach ($issue in $colorIssues) {
                Write-TestOutput $issue -Level "Warning"
            }
        } else {
            Write-TestOutput "Accessibility check passed" -Level "Success"
        }
        
        return $true
    } catch {
        Write-TestOutput "Error in accessibility test: $($_.Exception.Message)" -Level "Error"
        return $false
    }
}

function Export-TestResults {
    param(
        [array]$Results,
        [string]$Format
    )
    
    $endTime = Get-Date
    $duration = $endTime - $script:StartTime
    
    switch ($Format) {
        "json" {
            $output = @{
                timestamp = $script:StartTime.ToString("o")
                duration_ms = $duration.TotalMilliseconds
                theme_file = $ThemeFile
                results = $Results
                summary = @{
                    total = $Results.Count
                    passed = ($Results | Where-Object { $_.passed }).Count
                    failed = ($Results | Where-Object { -not $_.passed }).Count
                }
            }
            $output | ConvertTo-Json -Depth 5 | Out-File "test-results.json"
            Write-TestOutput "Results exported to test-results.json" -Level "Info"
        }
        "junit" {
            # Basic JUnit XML for CI integration
            $xml = @"
<?xml version="1.0" encoding="UTF-8"?>
<testsuites name="Oh My Posh Theme Tests" time="$($duration.TotalSeconds)">
    <testsuite name="ThemeValidation" tests="$($Results.Count)" failures="$(($Results | Where-Object { -not $_.passed }).Count)">
"@
            foreach ($result in $Results) {
                $status = if ($result.passed) { "" } else { "<failure>$($result.message)</failure>" }
                $xml += "`n        <testcase name=`"$($result.name)`" time=`"0`">$status</testcase>"
            }
            $xml += "`n    </testsuite>`n</testsuites>"
            $xml | Out-File "test-results.xml"
            Write-TestOutput "Results exported to test-results.xml" -Level "Info"
        }
    }
}

# Main execution
try {
    Write-TestOutput "🚀 Starting Oh My Posh theme validation" -Level "Info"
    Write-TestOutput "Theme: $ThemeFile" -Level "Info"
    
    # Run test phases
    Test-Prerequisites
    
    $validationPassed = Invoke-ThemeValidation
    $performancePassed = Test-ThemePerformance
    $accessibilityPassed = Test-ThemeAccessibility
    
    # Collect results
    $script:TestResults += @{
        name = "ThemeValidation"
        passed = $validationPassed
        message = if ($validationPassed) { "All theme validation tests passed" } else { "Theme validation failed" }
    }
    
    $script:TestResults += @{
        name = "PerformanceTest"
        passed = $performancePassed
        message = if ($performancePassed) { "Performance tests passed" } else { "Performance issues detected" }
    }
    
    $script:TestResults += @{
        name = "AccessibilityTest"
        passed = $accessibilityPassed
        message = if ($accessibilityPassed) { "Accessibility tests passed" } else { "Accessibility issues detected" }
    }
    
    # Export results if requested
    if ($OutputFormat -ne "console") {
        Export-TestResults -Results $script:TestResults -Format $OutputFormat
    }
    
    # Final summary
    $totalTests = $script:TestResults.Count
    $passedTests = ($script:TestResults | Where-Object { $_.passed }).Count
    $failedTests = $totalTests - $passedTests
    
    Write-TestOutput "`n📊 Final Test Summary:" -Level "Info"
    Write-TestOutput "Total: $totalTests | Passed: $passedTests | Failed: $failedTests" -Level "Info"
    
    if ($failedTests -eq 0) {
        Write-TestOutput "🎉 All tests passed! Theme is ready for use." -Level "Success"
        exit 0
    } else {
        Write-TestOutput "❌ Some tests failed. Please review the issues above." -Level "Error"
        exit 1
    }
    
} catch {
    Write-TestOutput "Fatal error during test execution: $($_.Exception.Message)" -Level "Error"
    exit 1
} 
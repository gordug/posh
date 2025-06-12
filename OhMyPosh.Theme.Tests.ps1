#Requires -Modules Pester

<#
.SYNOPSIS
Pester tests for Oh My Posh theme validation

.DESCRIPTION
Comprehensive test suite for validating Oh My Posh themes including:
- Theme structure validation
- Segment configuration testing
- Performance validation
- Accessibility checks

.PARAMETER ThemeFile
Path to the theme JSON file to test

.PARAMETER ConfigFile
Path to the test configuration JSON file

.EXAMPLE
Invoke-Pester -Path "OhMyPosh.Theme.Tests.ps1" -Output Detailed

.EXAMPLE
Invoke-Pester -Path "OhMyPosh.Theme.Tests.ps1" -PassThru | Export-JUnitReport -Path "test-results.xml"
#>

param(
    [string]$ThemeFile = "solarized_dark.omp.json",
    [string]$ConfigFile = "theme-test-config.json"
)

BeforeAll {
    # Load theme file
    if (-not (Test-Path $ThemeFile)) {
        throw "Theme file not found: $ThemeFile"
    }
    
    try {
        $script:Theme = Get-Content $ThemeFile | ConvertFrom-Json
    } catch {
        throw "Failed to parse theme JSON: $($_.Exception.Message)"
    }
    
    # Load test configuration if available
    $script:Config = $null
    if (Test-Path $ConfigFile) {
        try {
            $script:Config = Get-Content $ConfigFile | ConvertFrom-Json
        } catch {
            Write-Warning "Could not load test config file: $ConfigFile"
        }
    }
    
    # Helper function to get segment by type from any block
    function Get-SegmentByType {
        param([string]$SegmentType)
        return $script:Theme.blocks.segments | Where-Object { $_.type -eq $SegmentType }
    }
    
    # Helper function to get nested property value
    function Get-NestedProperty {
        param(
            [object]$Object,
            [string]$PropertyPath
        )
        
        $value = $Object
        foreach ($prop in $PropertyPath.Split('.')) {
            $value = $value.$prop
            if ($null -eq $value) { break }
        }
        return $value
    }
}

Describe "Oh My Posh Theme Tests" {
    
    Context "Theme File Validation" -Tag "Validation" {
        It "Should load theme file successfully" {
            $script:Theme | Should -Not -BeNullOrEmpty
        }
        
        It "Should have blocks array" {
            $script:Theme.blocks | Should -Not -BeNullOrEmpty
            $script:Theme.blocks | Should -BeOfType [System.Array]
        }
        
        It "Should have valid JSON structure" {
            { $script:Theme | ConvertTo-Json -Depth 10 } | Should -Not -Throw
        }
    }
    
    Context "Session Segment" -Tag "Validation", "Segments" {
        BeforeAll {
            $script:SessionSegment = $script:Theme.blocks[0].segments | Where-Object { $_.type -eq "session" }
        }
        
        It "Should exist in theme" {
            $script:SessionSegment | Should -Not -BeNullOrEmpty
        }
        
        It "Should have powerline style" {
            $script:SessionSegment.style | Should -Be "powerline"
        }
        
        It "Should have correct powerline symbol" {
            $script:SessionSegment.powerline_symbol | Should -Be ""
        }
        
        It "Should have SSH icon configured" {
            Get-NestedProperty -Object $script:SessionSegment -PropertyPath "properties.ssh_icon" | Should -Be "🌐"
        }
        
        It "Should have user info separator" {
            Get-NestedProperty -Object $script:SessionSegment -PropertyPath "properties.user_info_separator" | Should -Be "@"
        }
        
        It "Should have correct foreground color" {
            $script:SessionSegment.foreground | Should -Be "#073642"
        }
        
        It "Should have correct background color" {
            $script:SessionSegment.background | Should -Be "#dc322f"
        }
    }
    
    Context "Execution Time Segment" -Tag "Validation", "Segments" {
        BeforeAll {
            $script:ExecTimeSegment = $script:Theme.blocks[1].segments | Where-Object { $_.type -eq "executiontime" }
        }
        
        It "Should exist in theme" {
            $script:ExecTimeSegment | Should -Not -BeNullOrEmpty
        }
        
        It "Should have plain style" {
            $script:ExecTimeSegment.style | Should -Be "plain"
        }
        
        It "Should have appropriate threshold" {
            Get-NestedProperty -Object $script:ExecTimeSegment -PropertyPath "properties.threshold" | Should -Be 500
        }
        
        It "Should have roundrock time style" {
            Get-NestedProperty -Object $script:ExecTimeSegment -PropertyPath "properties.style" | Should -Be "roundrock"
        }
        
        It "Should have timer prefix icon" {
            Get-NestedProperty -Object $script:ExecTimeSegment -PropertyPath "properties.prefix" | Should -Be "⏱️ "
        }
        
        It "Should have correct foreground color" {
            $script:ExecTimeSegment.foreground | Should -Be "#b58900"
        }
    }
    
    Context "Status Segment" -Tag "Validation", "Segments" {
        BeforeAll {
            $script:StatusSegment = $script:Theme.blocks[2].segments | Where-Object { $_.type -eq "status" }
        }
        
        It "Should exist in theme" {
            $script:StatusSegment | Should -Not -BeNullOrEmpty
        }
        
        It "Should have powerline style" {
            $script:StatusSegment.style | Should -Be "powerline"
        }
        
        It "Should be always enabled" {
            Get-NestedProperty -Object $script:StatusSegment -PropertyPath "properties.always_enabled" | Should -Be $true
        }
        
        It "Should have conditional logic for error codes in prefix" {
            $prefixTemplate = Get-NestedProperty -Object $script:StatusSegment -PropertyPath "properties.prefix"
            $prefixTemplate | Should -Match "if gt \.Code 0"
        }
        
        It "Should contain error icon in prefix template" {
            $prefixTemplate = Get-NestedProperty -Object $script:StatusSegment -PropertyPath "properties.prefix"
            $prefixTemplate | Should -Match "❌"
        }
        
        It "Should contain success icon in prefix template" {
            $prefixTemplate = Get-NestedProperty -Object $script:StatusSegment -PropertyPath "properties.prefix"
            $prefixTemplate | Should -Match "✅"
        }
        
        It "Should have conditional background templates" {
            $script:StatusSegment.background_templates | Should -Not -BeNullOrEmpty
            $script:StatusSegment.background_templates[0] | Should -Match "if gt \.Code 0"
        }
        
        It "Should contain error color in background template" {
            $script:StatusSegment.background_templates[0] | Should -Match "#dc322f"
        }
    }
    
    Context "Azure Segment" -Tag "Validation", "Segments" {
        BeforeAll {
            $script:AzureSegment = $script:Theme.blocks[2].segments | Where-Object { $_.type -eq "azure" }
        }
        
        It "Should exist in theme" {
            $script:AzureSegment | Should -Not -BeNullOrEmpty
        }
        
        It "Should have powerline style" {
            $script:AzureSegment.style | Should -Be "powerline"
        }
        
        It "Should have cloud prefix icon" {
            Get-NestedProperty -Object $script:AzureSegment -PropertyPath "properties.prefix" | Should -Be "☁️ "
        }
        
        It "Should have context display mode" {
            Get-NestedProperty -Object $script:AzureSegment -PropertyPath "properties.display_mode" | Should -Be "context"
        }
        
        It "Should have empty missing command text for graceful fallback" {
            Get-NestedProperty -Object $script:AzureSegment -PropertyPath "properties.missing_command_text" | Should -Be ""
        }
        
        It "Should have correct foreground color" {
            $script:AzureSegment.foreground | Should -Be "#268bd2"
        }
    }
    
    Context "Git Segment" -Tag "Validation", "Segments" {
        BeforeAll {
            $script:GitSegment = $script:Theme.blocks[2].segments | Where-Object { $_.type -eq "git" }
        }
        
        It "Should exist in theme" {
            $script:GitSegment | Should -Not -BeNullOrEmpty
        }
        
        Context "Basic Git Icons" {
            It "Should have branch icon" {
                Get-NestedProperty -Object $script:GitSegment -PropertyPath "properties.branch_icon" | Should -Be "🔀 "
            }
            
            It "Should have commit icon" {
                Get-NestedProperty -Object $script:GitSegment -PropertyPath "properties.commit_icon" | Should -Be "📝 "
            }
            
            It "Should have ahead icon" {
                Get-NestedProperty -Object $script:GitSegment -PropertyPath "properties.branch_ahead_icon" | Should -Be "⬆️"
            }
            
            It "Should have behind icon" {
                Get-NestedProperty -Object $script:GitSegment -PropertyPath "properties.branch_behind_icon" | Should -Be "⬇️"
            }
            
            It "Should have branch gone icon" {
                Get-NestedProperty -Object $script:GitSegment -PropertyPath "properties.branch_gone_icon" | Should -Be "🚫"
            }
            
            It "Should have tag icon" {
                Get-NestedProperty -Object $script:GitSegment -PropertyPath "properties.tag_icon" | Should -Be "🏷️ "
            }
        }
        
        Context "Fetch Status Configuration" {
            It "Should enable fetch status" {
                Get-NestedProperty -Object $script:GitSegment -PropertyPath "properties.fetch_status" | Should -Be $true
            }
            
            It "Should enable fetch upstream icon" {
                Get-NestedProperty -Object $script:GitSegment -PropertyPath "properties.fetch_upstream_icon" | Should -Be $true
            }
        }
        
        Context "Workflow State Icons" {
            It "Should have rebase icon" {
                Get-NestedProperty -Object $script:GitSegment -PropertyPath "properties.rebase_icon" | Should -Be "🔄 "
            }
            
            It "Should have cherry pick icon" {
                Get-NestedProperty -Object $script:GitSegment -PropertyPath "properties.cherry_pick_icon" | Should -Be "🍒 "
            }
            
            It "Should have revert icon" {
                Get-NestedProperty -Object $script:GitSegment -PropertyPath "properties.revert_icon" | Should -Be "↩️ "
            }
            
            It "Should have merge icon" {
                Get-NestedProperty -Object $script:GitSegment -PropertyPath "properties.merge_icon" | Should -Be "🔗 "
            }
            
            It "Should have no commits icon" {
                Get-NestedProperty -Object $script:GitSegment -PropertyPath "properties.no_commits_icon" | Should -Be "🆕 "
            }
        }
        
        Context "Status Icons" {
            It "Should have added status icon" {
                Get-NestedProperty -Object $script:GitSegment -PropertyPath "properties.status.added" | Should -Be "➕"
            }
            
            It "Should have copied status icon" {
                Get-NestedProperty -Object $script:GitSegment -PropertyPath "properties.status.copied" | Should -Be "📋"
            }
            
            It "Should have deleted status icon" {
                Get-NestedProperty -Object $script:GitSegment -PropertyPath "properties.status.deleted" | Should -Be "🗑️"
            }
            
            It "Should have modified status icon" {
                Get-NestedProperty -Object $script:GitSegment -PropertyPath "properties.status.modified" | Should -Be "📝"
            }
            
            It "Should have moved status icon" {
                Get-NestedProperty -Object $script:GitSegment -PropertyPath "properties.status.moved" | Should -Be "📦"
            }
            
            It "Should have renamed status icon" {
                Get-NestedProperty -Object $script:GitSegment -PropertyPath "properties.status.renamed" | Should -Be "📛"
            }
            
            It "Should have staged status icon" {
                Get-NestedProperty -Object $script:GitSegment -PropertyPath "properties.status.staged" | Should -Be "🎯"
            }
            
            It "Should have unmerged status icon" {
                Get-NestedProperty -Object $script:GitSegment -PropertyPath "properties.status.unmerged" | Should -Be "⚠️"
            }
            
            It "Should have untracked status icon" {
                Get-NestedProperty -Object $script:GitSegment -PropertyPath "properties.status.untracked" | Should -Be "❓"
            }
            
            It "Should have ignored status icon" {
                Get-NestedProperty -Object $script:GitSegment -PropertyPath "properties.status.ignored" | Should -Be "🙈"
            }
        }
    }
    
    Context ".NET Segment" -Tag "Validation", "Segments" {
        BeforeAll {
            $script:DotNetSegment = $script:Theme.blocks[2].segments | Where-Object { $_.type -eq "dotnet" }
        }
        
        It "Should exist in theme" {
            $script:DotNetSegment | Should -Not -BeNullOrEmpty
        }
        
        It "Should have .NET prefix with icon" {
            Get-NestedProperty -Object $script:DotNetSegment -PropertyPath "properties.prefix" | Should -Be "🔷 .NET "
        }
        
        It "Should display version information" {
            Get-NestedProperty -Object $script:DotNetSegment -PropertyPath "properties.display_version" | Should -Be $true
        }
        
        It "Should have context display mode" {
            Get-NestedProperty -Object $script:DotNetSegment -PropertyPath "properties.display_mode" | Should -Be "context"
        }
        
        It "Should have empty missing command text for graceful fallback" {
            Get-NestedProperty -Object $script:DotNetSegment -PropertyPath "properties.missing_command_text" | Should -Be ""
        }
    }
    
    Context "Performance Tests" -Tag "Performance" {
        BeforeAll {
            # Load performance thresholds from config or use defaults
            $script:MaxSegmentsPerBlock = 15
            $script:MaxTotalSegments = 45
            
            if ($script:Config -and $script:Config.performance_tests.segment_count.max_segments_per_block) {
                $script:MaxSegmentsPerBlock = $script:Config.performance_tests.segment_count.max_segments_per_block
                $script:MaxTotalSegments = $script:MaxSegmentsPerBlock * 3
            }
        }
        
        It "Should not exceed maximum segments per block" {
            foreach ($block in $script:Theme.blocks) {
                if ($block.segments) {
                    $block.segments.Count | Should -BeLessOrEqual $script:MaxSegmentsPerBlock -Because "Block has too many segments which may impact performance"
                }
            }
        }
        
        It "Should not exceed total segment count across all blocks" {
            $totalSegments = ($script:Theme.blocks.segments | Measure-Object).Count
            $totalSegments | Should -BeLessOrEqual $script:MaxTotalSegments -Because "Total segment count may impact prompt performance"
        }
        
        It "Should complete segment count analysis" {
            $totalSegments = 0
            $blockIndex = 0
            
            foreach ($block in $script:Theme.blocks) {
                if ($block.segments) {
                    $blockSegmentCount = $block.segments.Count
                    $totalSegments += $blockSegmentCount
                    $blockIndex++
                    
                    Write-Host "Block $blockIndex segments: $blockSegmentCount" -ForegroundColor Cyan
                }
            }
            
            Write-Host "Total segments: $totalSegments (max recommended: $script:MaxTotalSegments)" -ForegroundColor Cyan
            $totalSegments | Should -BeGreaterThan 0 -Because "Theme should have at least one segment"
        }
    }
    
    Context "Accessibility Tests" -Tag "Accessibility" {
        It "Should not have identical foreground and background colors" {
            $colorIssues = @()
            
            foreach ($block in $script:Theme.blocks) {
                if ($block.segments) {
                    foreach ($segment in $block.segments) {
                        if ($segment.foreground -eq $segment.background) {
                            $colorIssues += "Segment '$($segment.type)' has identical foreground and background colors"
                        }
                    }
                }
            }
            
            $colorIssues | Should -BeNullOrEmpty -Because "Segments with identical foreground and background colors are not accessible"
        }
        
        It "Should have foreground colors defined for all segments" {
            foreach ($block in $script:Theme.blocks) {
                if ($block.segments) {
                    foreach ($segment in $block.segments) {
                        $segment.foreground | Should -Not -BeNullOrEmpty -Because "Segment '$($segment.type)' should have a foreground color defined"
                    }
                }
            }
        }
        
        It "Should have background colors or templates defined for powerline segments" {
            foreach ($block in $script:Theme.blocks) {
                if ($block.segments) {
                    foreach ($segment in $block.segments) {
                        if ($segment.style -eq "powerline") {
                            ($segment.background -or $segment.background_templates) | Should -Be $true -Because "Powerline segment '$($segment.type)' should have background color or templates defined"
                        }
                    }
                }
            }
        }
    }
    
    Context "Prerequisites Check" -Tag "Prerequisites" {
        It "Should have PowerShell 7+ available" {
            $PSVersionTable.PSVersion.Major | Should -BeGreaterOrEqual 7 -Because "PowerShell 7+ provides better performance and compatibility"
        }
        
        It "Should be able to locate Oh My Posh executable" {
            $ompVersion = try { oh-my-posh version 2>$null } catch { $null }
            $ompVersion | Should -Not -BeNullOrEmpty -Because "Oh My Posh should be installed and accessible in PATH"
        }
    }
} 
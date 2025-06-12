# Oh My Posh Theme Testing Framework

This testing framework provides comprehensive validation for the enhanced Solarized Dark Oh My Posh theme, ensuring all new segments work correctly and maintain high quality standards.

## 🧪 Test Coverage

### New Segments Tested
- **Session Segment** - SSH/remote context awareness
- **Execution Time Segment** - Build/test performance monitoring  
- **Status Segment** - Command success/failure feedback
- **Azure Segment** - Cloud development integration
- **Enhanced Git Segment** - Detailed workflow status
- **Enhanced .NET Segment** - C# development optimizations

### Test Categories

#### 1. **Functional Tests** (`test_theme_validation.ps1`)
- ✅ Segment existence and structure
- ✅ Icon validation and consistency
- ✅ Threshold configurations
- ✅ Conditional logic (success/error states)
- ✅ Property validation
- ✅ Color scheme compliance

#### 2. **Performance Tests**
- ✅ Segment count optimization
- ✅ Template complexity analysis
- ✅ Rendering efficiency checks

#### 3. **Accessibility Tests**
- ✅ Color contrast validation
- ✅ Icon fallback handling
- ✅ WCAG compliance checks

#### 4. **Integration Tests**
- ✅ Terminal compatibility
- ✅ Oh My Posh version requirements
- ✅ CLI tool availability

## 🚀 Quick Start

### Run All Tests
```powershell
.\run-theme-tests.ps1
```

### Run Specific Validation
```powershell
.\test_theme_validation.ps1
```

### CI/CD Integration
```powershell
.\run-theme-tests.ps1 -CIMode -OutputFormat junit
```

## 📋 Test Details

### Session Segment Tests
- **SSH Icon**: Validates 🌐 icon for remote sessions
- **User Separator**: Confirms @ separator format
- **Color Scheme**: Red background for elevated/remote context
- **Positioning**: First segment for immediate visibility

### Execution Time Tests
- **Threshold**: 500ms minimum for build performance monitoring
- **Icon**: ⏱️ time-related visual indicator
- **Style**: "roundrock" format for readability
- **Placement**: Right-aligned to minimize interference

### Status Segment Tests
- **Success State**: ✅ icon with green background (#2aa198)
- **Error State**: ❌ icon with red background (#dc322f)
- **Conditional Logic**: `{{ if gt .Code 0 }}` template validation
- **Always Enabled**: Ensures constant feedback
- **Priority**: First segment in main prompt

### Azure Segment Tests
- **Cloud Icon**: ☁️ prefix validation
- **Context Awareness**: `display_mode: "context"` setting
- **Graceful Fallback**: Empty `missing_command_text`
- **Color Scheme**: Azure blue theme compliance

### Enhanced Git Tests
- **Branch Icons**: 🔀 branch, 📝 commit, 🏷️ tag indicators
- **Status Icons**: Complete coverage (➕ added, 📝 modified, 🎯 staged, etc.)
- **Upstream Tracking**: ⬆️ ahead, ⬇️ behind, 🚫 gone indicators
- **Workflow States**: 🔄 rebase, 🍒 cherry-pick, 🔗 merge support

### Enhanced .NET Tests
- **Version Display**: `display_version: true` validation
- **Context Awareness**: Only shows in .NET projects
- **Icon Prefix**: 🔷 .NET branding
- **Missing CLI**: Graceful handling of missing dotnet command

## 🎯 Test Configuration

### Test Config File (`theme-test-config.json`)
Defines expected values, validation rules, and test parameters:

```json
{
    "theme_tests": {
        "session_segment": {
            "required": true,
            "expected_properties": { ... },
            "validation_rules": [ ... ]
        }
    }
}
```

### Performance Thresholds
- **Max Segments**: 15 per block
- **Max Emoji**: 2 per segment
- **Max Conditions**: 3 per template

### Accessibility Standards
- **Color Contrast**: 4.5:1 minimum ratio (WCAG AA)
- **Icon Fallbacks**: Required for all segments
- **Font Compatibility**: Unicode emoji support

## 🔧 Usage Examples

### Local Development
```powershell
# Run all tests with verbose output
.\run-theme-tests.ps1 -Verbose

# Test specific theme file
.\run-theme-tests.ps1 -ThemeFile "my-custom-theme.omp.json"

# Export results for analysis
.\run-theme-tests.ps1 -OutputFormat json
```

### Continuous Integration
```yaml
# GitHub Actions example
- name: Test Oh My Posh Theme
  run: |
    .\run-theme-tests.ps1 -CIMode -OutputFormat junit
  shell: pwsh
```

### Azure DevOps
```yaml
# Azure Pipelines example
- task: PowerShell@2
  displayName: 'Validate Theme'
  inputs:
    targetType: 'filePath'
    filePath: '.\run-theme-tests.ps1'
    arguments: '-CIMode -OutputFormat junit'
```

## 📊 Test Output Formats

### Console Output (Default)
- Colored status indicators
- Real-time progress updates
- Summary statistics

### JSON Output
```json
{
    "timestamp": "2024-01-15T10:30:00Z",
    "duration_ms": 1250,
    "theme_file": "solarized_dark.omp.json",
    "results": [...],
    "summary": {
        "total": 25,
        "passed": 23,
        "failed": 2
    }
}
```

### JUnit XML Output
Compatible with most CI/CD systems for test result integration.

## 🛠️ Troubleshooting

### Common Issues

**Test Failures**
- Check segment positioning in theme blocks
- Verify property spelling and casing
- Ensure all required properties are present

**Performance Warnings**
- Reduce segment count if > 20 total
- Simplify conditional templates
- Optimize icon usage

**Accessibility Issues**
- Check color contrast ratios
- Ensure emoji/icon fallbacks
- Test with different font configurations

### Debug Mode
```powershell
.\test_theme_validation.ps1 -Verbose
```

## 📝 Adding New Tests

### For New Segments
1. Add segment definition to `theme-test-config.json`
2. Create test cases in `test_theme_validation.ps1`
3. Update validation rules and expected properties
4. Run tests to ensure coverage

### Test Function Template
```powershell
function Test-NewSegment {
    $segment = $theme.blocks[X].segments | Where-Object { $_.type -eq "newsegment" }
    $testResults += Test-SegmentExists -Theme $theme -SegmentType "newsegment" -TestName "NewSegment-Exists"
    # Add property validations...
}
```

## 🎖️ Quality Gates

All tests must pass before:
- ✅ Merging theme changes
- ✅ Creating release versions
- ✅ Deploying to production environments

The testing framework ensures:
- **Functional Correctness**: All segments work as designed
- **Performance Standards**: Theme remains responsive
- **Accessibility Compliance**: Usable by all developers
- **Integration Compatibility**: Works across development environments

## 📞 Support

For test-related issues:
1. Check test output for specific failures
2. Review validation rules in config file
3. Ensure Oh My Posh version compatibility
4. Verify theme JSON structure

The testing framework is designed to catch issues early and ensure a high-quality developer experience with the enhanced theme. 
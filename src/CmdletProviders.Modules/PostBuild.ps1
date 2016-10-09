param (
  [string]$TargetDir,
  [string]$TargetName,
  [string]$ProjectDir
)

Write-Host "`nRemoving Module artifacts..`n"

@("$TargetDir\$targetName.dll", "$TargetDir\$targetName.pdb") | Remove-Item -Force -Verbose;

Write-Host "`nModule artifacts removed.`n"

If (Get-Module -ListAvailable -Name PSSCriptAnalyzer) {
  $script = "$($ProjectDir)DynamicsCRM-Automation.ps1";
  $report = @();

  Try {
    $report = Invoke-ScriptAnalyzer -Severity Error -Path $script;
    $report | Format-Table;
  }
  Catch {
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Write-Error "Failed to analyze scripts. Failed on $FailedItem. The error message was $ErrorMessage"
    $Host.SetShouldExit(1);
  }

  If ($report.Count -gt 0) {
    Write-Host "The PSScriptAnalyzer found one or more errors, i.e. quality gate not passed.";
    $Host.SetShouldExit(1);
  }
} 
Else {
  Write-Host "Please install PSSCriptAnalyzer in order to verify script quality.";
  $Host.SetShouldExit(1);
}
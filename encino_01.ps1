<#
.Synopsis
   Short description
.DESCRIPTION
   Long description
.EXAMPLE
   .\encino_01.ps1 fage_ovf_parms.pson
.EXAMPLE
   Another example of how to use this cmdlet
.INPUTS
   Inputs to this cmdlet (if any)
.OUTPUTS
   Output from this cmdlet (if any)
.NOTES
   General notes
.COMPONENT
   The component this cmdlet belongs to
.ROLE
   The role this cmdlet belongs to
.FUNCTIONALITY
   The functionality that best describes this cmdlet
#>
Param
    (
        # Param1 help description
        [Parameter(Mandatory=$true,
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        [Alias("parms")]
        $ParameterFile )

$Logfile = "c:\tmp\Encino_Log.md"
Add-Content $Logfile -Value "### Started Instance $((Get-Date -UFormat `"%Y-%b-%d_%R`").ToUpper())"
#  Test-Path .\fage_ovf_parms.pson
If (! $(Test-Path .\$ParameterFile )) { "Path $ParameterFile Not Found!"; Exit }
$P = Get-Content .\$ParameterFile | Out-String | Invoke-Expression

#$($P.Basis_Weeks | ForEach-Object {[string]::Concat([char]39,$_,[char]39)}) -Join [char]44

# Get an array of the Brands
[array]$aryBrand = $(ForEach ( $i in $P.Event.Keys ) { $P.Event.$i.Brand }) | Sort-Object -Unique

# Count by Type

[hashtable]$ScheduleSummary = @{}
$ScheduleSummary.Add( 'Brand' ,$aryBrand.Count )
$ScheduleSummary.Add( 'Event' ,$P.Event.Count )
$ScheduleSummary.Add( 'Item'  ,
($( ForEach ( $i in $P.Event.Keys ) { $P.Event.$i.Itemset.count } ) |
Group-Object | Measure-Object Name -Sum).Sum )

# Count Items for Each Brand

[hashtable]$BrandSummary = @{}
ForEach ( $j in $aryBrand ) {
$BrandSummary.Add( $j, ($(ForEach ( $i in $P.Event.Keys ) { If ( $j -contains $P.Event.$i.Brand )
 { $P.Event.$i.Itemset.count  } }) |  Group-Object | Measure-Object Name -Sum).Sum ) }

$strBanner = @"
 __        __              ___ ___  ___  __
|__)  /\  |__)  /\   |\/| |__   |  |__  |__)
|    /~~\ |  \ /~~\  |  | |___  |  |___ |  \
    __                         __
   /__`` |  |  |\/|  |\/|  /\  |__) \ /
   .__/ \__/  |  |  |  | /~~\ |  \  |
"@
$strBanner
$ScheduleSummary | Format-Table @{Label=’Type’;Expression={$_.Name}},@{Label=’Count’;Expression={$_.Value}}  -AutoSize
$BrandSummary | Format-Table @{Label=’Brand’;Expression={$_.Name}},@{Label=’Item.Count’;Expression={$_.Value}}  -AutoSize

Add-Content $Logfile -Value "### Script End $((Get-Date -UFormat `"%Y-%b-%d_%R`").ToUpper())"
#### KTHXBYE ####

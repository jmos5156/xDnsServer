$script:dscModuleName = 'xDnsServer'
$script:dscResourceName = 'MSFT_xDnsServerDiagnostics'

function Invoke-TestSetup
{
    try
    {
        Import-Module -Name DscResource.Test -Force -ErrorAction 'Stop'
    }
    catch [System.IO.FileNotFoundException]
    {
        throw 'DscResource.Test module dependency not found. Please run ".\build.ps1 -Tasks build" first.'
    }

    $script:testEnvironment = Initialize-TestEnvironment `
        -DSCModuleName $script:dscModuleName `
        -DSCResourceName $script:dscResourceName `
        -ResourceType 'Mof' `
        -TestType 'Unit'

    Import-Module (Join-Path -Path $PSScriptRoot -ChildPath 'Stubs\DnsServer.psm1') -Force
}

function Invoke-TestCleanup
{
    Restore-TestEnvironment -TestEnvironment $script:testEnvironment
}

Invoke-TestSetup

try
{
    InModuleScope $script:dscResourceName {
        #region Pester Test Initialization
        $testParameters = [PSCustomObject]@{
            Name                                 = 'xDnsServerDiagnostics_Integration'
            Answers                              = $true
            EnableLogFileRollover                = $true
            EnableLoggingForLocalLookupEvent     = $true
            EnableLoggingForPluginDllEvent       = $true
            EnableLoggingForRecursiveLookupEvent = $true
            EnableLoggingForRemoteServerEvent    = $true
            EnableLoggingForServerStartStopEvent = $true
            EnableLoggingForTombstoneEvent       = $true
            EnableLoggingForZoneDataWriteEvent   = $true
            EnableLoggingForZoneLoadingEvent     = $true
            EnableLoggingToFile                  = $true
            EventLogLevel                        = 4
            FilterIPAddressList                  = "192.168.1.1","192.168.1.2"
            FullPackets                          = $true
            LogFilePath                          = 'C:\Windows\System32\DNS\DNSDiagnostics.log'
            MaxMBFileSize                        = 500000000
            Notifications                        = $true
            Queries                              = $true
            QuestionTransactions                 = $true
            ReceivePackets                       = $true
            SaveLogsToPersistentStorage          = $true
            SendPackets                          = $true
            TcpPackets                           = $true
            UdpPackets                           = $true
            UnmatchedResponse                    = $true
            Update                               = $true
            UseSystemEventLog                    = $true
            WriteThrough                         = $true
        }

        $mockGetDnsServerDiagnostics = [PSCustomObject]@{
            Name                                 = 'xDnsServerDiagnostics_Integration'
            Answers                              = $true
            EnableLogFileRollover                = $true
            EnableLoggingForLocalLookupEvent     = $true
            EnableLoggingForPluginDllEvent       = $true
            EnableLoggingForRecursiveLookupEvent = $true
            EnableLoggingForRemoteServerEvent    = $true
            EnableLoggingForServerStartStopEvent = $true
            EnableLoggingForTombstoneEvent       = $true
            EnableLoggingForZoneDataWriteEvent   = $true
            EnableLoggingForZoneLoadingEvent     = $true
            EnableLoggingToFile                  = $true
            EventLogLevel                        = 4
            FilterIPAddressList                  = "192.168.1.1","192.168.1.2"
            FullPackets                          = $true
            LogFilePath                          = 'C:\Windows\System32\DNS\DNSDiagnostics.log'
            MaxMBFileSize                        = 500000000
            Notifications                        = $true
            Queries                              = $true
            QuestionTransactions                 = $true
            ReceivePackets                       = $true
            SaveLogsToPersistentStorage          = $true
            SendPackets                          = $true
            TcpPackets                           = $true
            UdpPackets                           = $true
            UnmatchedResponse                    = $true
            Update                               = $true
            UseSystemEventLog                    = $true
            WriteThrough                         = $true
        }

        $commonParameters += [System.Management.Automation.PSCmdlet]::CommonParameters
        $commonParameters += [System.Management.Automation.PSCmdlet]::OptionalCommonParameters

        $mockParameters = @{
            Verbose             = $true
            Debug               = $true
            ErrorAction         = 'stop'
            WarningAction       = 'Continue'
            InformationAction   = 'Continue'
            ErrorVariable       = 'err'
            WarningVariable     = 'warn'
            OutVariable         = 'out'
            OutBuffer           = 'outbuff'
            PipelineVariable    = 'pipe'
            InformationVariable = 'info'
            WhatIf              = $true
            Confirm             = $true
            UseTransaction      = $true
            Name                = 'DnsServerDiagnostic'
        }
        #endregion Pester Test Initialization

        #region Example state 1
        Describe 'The system is not in the desired state' {
            Mock -CommandName Assert-Module

            Context 'Get-TargetResource' {
                It "Get method returns 'something'" {
                    Mock -CommandName Get-DnsServerDiagnostics -MockWith {$mockGetDnsServerDiagnostics}
                    $getResult = Get-TargetResource -Name 'DnsServerDiagnostic'

                    foreach ($key in $getResult.Keys)
                    {
                        if ($null -ne $getResult[$key] -and $key -ne 'Name')
                        {
                            $getResult[$key] | Should be $mockGetDnsServerDiagnostics.$key
                        }
                    }
                }

                It 'Get throws when DnsServerDiagnostics is not found' {
                    Mock -CommandName Get-DnsServerDiagnostics -MockWith {throw 'Invalid Class'}

                    {Get-TargetResource -Name 'DnsServerDiagnostics'} | should throw 'Invalid Class'
                }
            }

            Context 'Test-TargetResource' {
                $falseParameters = @{Name = 'DnsServerDiagnostic'}

                foreach ($key in $testParameters.Keys)
                {
                    if ($key -ne 'Name')
                    {
                        $falseTestParameters = $falseParameters.Clone()
                        $falseTestParameters.Add($key,$testParameters[$key])
                        It "Test method returns false when testing $key" {
                            Mock -CommandName Get-TargetResource -MockWith {$mockGetDnsServerDiagnostics}
                            Test-TargetResource @falseTestParameters | Should be $false
                        }
                    }
                }
            }

            Context 'Error handling' {
                It 'Test throws when DnsServerDiagnostics is not found' {
                    Mock -CommandName Get-DnsServerDiagnostics -MockWith {throw 'Invalid Class'}

                    {Get-TargetResource -Name 'xDnsServerSetting_Integration'} | should throw 'Invalid Class'
                }
            }

            Context 'Set-TargetResource' {
                It 'Set method calls Set-CimInstance' {
                    Mock -CommandName Get-DnsServerDiagnostics -MockWith {$mockGetDnsServerDiagnostics}
                    Mock -CommandName Set-DnsServerDiagnostics {}

                    Set-TargetResource @testParameters

                    Assert-MockCalled Set-DnsServerDiagnostics -Exactly 1
                }
            }
        }
        #endregion Example state 1

        #region Example state 2
        Describe 'The system is in the desired state' {

            Context 'Test-TargetResource' {

                Mock -CommandName Get-TargetResource -MockWith { $mockGetDnsServerDiagnostics }

                $trueParameters = @{ Name = 'xDnsServerDiagnostics_Integration' }

                foreach ($key in $testParameters.Keys)
                {
                    if ($key -ne 'Name')
                    {
                        $trueTestParameters = $trueParameters.Clone()

                        $trueTestParameters.Add($key,$mockGetDnsServerDiagnostics.$key)

                        It "Test method returns true when testing $key" {
                            $result = Test-TargetResource @trueTestParameters
                            $result | Should be $true
                        }
                    }
                }

            }
        }
        #endregion Example state 2

        #region Non-Exported Function Unit Tests

        Describe 'Private functions' {
            Context 'Remove-CommonParameters' {
                It 'Should not contain any common parameters' {
                    $removeResults = Remove-CommonParameter $mockParameters

                    foreach ($key in $removeResults.Keys)
                    {
                        $commonParameters -notcontains $key | should be $true
                    }
                }
            }
        }
        #endregion Non-Exported Function Unit Tests
    }
}
finally
{
    Invoke-TestCleanup
}

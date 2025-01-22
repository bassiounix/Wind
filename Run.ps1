Set-StrictMode -Version latest

Install-Module powershell-yaml

Import-Module powershell-yaml

function Install-WinGetPkg ([string]$pkg) {
    winget.exe install --exact --id $pkg --disable-interactivity --scope user --silent  --accept-package-agreements --location "$baseDir\winget-pkgs"
}

function Remove-WinGetPkg ([string]$pkg) {
    winget.exe uninstall --exact --id $pkg --force
}

function Install-WinGetPkgs ([System.Collections.ArrayList]$pkgs) {
    $total = $pkgs.count
    $i = 1
    $progPercent = "{0:n2}" -f ([math]::round($i / $total, 4) * 100)
    Write-Progress -Activity "Downloading Packages From WinGet" -Status "$i of $total - $progPercent% Complete:" -PercentComplete $progPercent
    foreach ($pkg in $pkgs) {
        $progPercent = "{0:n2}" -f ([math]::round($i / $total, 4) * 100)
        Write-Progress -Activity "Downloading [$pkg] From WinGet" -Status "$i of $total - $progPercent% Complete:" -PercentComplete $progPercent

        Install-WinGetPkg $pkg.ToString()

        $i++
    }
}

function Remove-BlacklistPkgs ([System.Collections.ArrayList]$blacklist) {
    $total = $blacklist.count
    $i = 1
    $progPercent = "{0:n2}" -f ([math]::round($i / $total, 4) * 100)
    Write-Progress -Activity "Deleting [$item] From WinGet Repo" -Status "$i of $total - $progPercent% Complete:" -PercentComplete $progPercent
    foreach ($item in $blacklist) {
        $progPercent = "{0:n2}" -f ([math]::round($i / $total, 4) * 100)
        Write-Progress -Activity "Deleting [$item] From WinGet Repo" -Status "$i of $total - $progPercent% Complete:" -PercentComplete $progPercent

        Remove-WinGetPkg $item
        
        $i++
    }
}

# Set-Content -Path $filePath -Value $variableContent

function Install-VCPkg ([string]$url, [string]$outDir) {
    git clone --depth=1 $url $outDir
}

function Write-ToFile ([string]$content, [string]$filePath) {
    Set-Content -Path $filePath -Value $content
}

function Install-VCPkgList ($pkgs) {
    $pkgs | Foreach-Object -ThrottleLimit 5 -Parallel {
        vcpkg.exe install $PSItem
    }
}

function Main () {
    Write-Host @'

            █     █░ ██▓ ███▄    █ ▓█████▄ 
           ▓█░ █ ░█░▓██▒ ██ ▀█   █ ▒██▀ ██▌
           ▒█░ █ ░█ ▒██▒▓██  ▀█ ██▒░██   █▌
           ░█░ █ ░█ ░██░▓██▒  ▐▌██▒░▓█▄   ▌
           ░░██▒██▓ ░██░▒██░   ▓██░░▒████▓ 
           ░ ▓░▒ ▒  ░▓  ░ ▒░   ▒ ▒  ▒▒▓  ▒ 
             ▒ ░ ░   ▒ ░░ ░░   ░ ▒░ ░ ▒  ▒ 
             ░   ░   ▒ ░   ░   ░ ░  ░ ░  ░ 
               ░     ░           ░    ░    
                                    ░      

'@

    Write-Host 'Reading [config.yaml] From Currnet Folder Path'
    $conf = Get-Content -Path .\conf.yaml -Raw

    $conf = ConvertFrom-Yaml $conf.ToString()

    $baseDir = $conf['base-dir'].ToString()

    if (-not (Test-Path -Path $baseDir)) {
        Write-Output "Creating Base Folder at $baseDir"
        New-Item -ItemType Directory -Path $baseDir
    }

    Write-Host 

    do {
        $input_num = Read-Host @'
[1] Bootstrap Wind.
[2] WinGet Pkgs.
[3] VCPKG.
|]> 
'@
    } while (-not (($input_num -as [int]) -and ($input_num -le 3) -and ($input_num -ge 0)))

    if ($input_num -eq 1) {
        $profile_string = Get-Content -Path .\Microsoft.PowerShell_profile.ps1 -Raw

        $profile_string = $profile_string -replace '\{baseDir\}', $baseDir

        Write-ToFile $profile_string "C:\Users\$($env:USERNAME)\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"

        $profile_string = Get-Content -Path .\Profile.ps1 -Raw

        $profile_string = $profile_string -replace '\{baseDir\}', $baseDir

        Write-ToFile $profile_string "$baseDir\Profile.ps1"
    }

    elseif ($input_num -eq 2) {
        
        $winget = $conf['winget']
        
        do {
            $input_winget = Read-Host @'
[1] Install WinGet Packages.
[2] Uninstall WinGet Packages From The Blacklist.
|]> 
'@
        } while (-not (($input_winget -as [int]) -and ($input_winget -le 2) -and ($input_winget -ge 0)))

        if ($input_winget -eq 1) {
            $pkgs = $winget['pkgs'].ToArray()
            Install-WinGetPkgs $pkgs
        }
        
        elseif ($input_winget -eq 2) {
            $blacklist = $winget['blacklist'].ToArray()
            Remove-WinGetPkg $blacklist
        }

        return
    }

    elseif ($input_num -eq 3) {        
        $vcpkg = $conf['vcpkg']

        do {
            $input_vcpkg = Read-Host @'
[1] Install VCPkg.
[2] Install VCPkg Packages.
|]> 
'@
        } while (-not (($input_vcpkg -as [int]) -and ($input_vcpkg -le 2) -and ($input_vcpkg -ge 0)))

        if ($input_vcpkg -eq 1) {
            Install-VCPkg $vcpkg['url'] "$baseDir\vcpkg"
            . "$baseDir\vcpkg\$($vcpkg['run'])" -disableMetrics
            vcpkg.exe integrate install
        }

        elseif ($input_vcpkg -eq 2) {
            Install-VCPkgList $vcpkg['pkgs']
        }

        return
    }
}

Main

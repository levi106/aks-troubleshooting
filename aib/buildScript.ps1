if (@(Get-WmiObject -Class Win32_Product | Where-Object { $_.Name -eq "Microsoft Azure CLI" }).Count -eq 0)
{
    $ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi; Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'; rm .\AzureCLI.msi
}

if (-not(Test-Path -Path "HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\Wireshark"))
{
    Invoke-WebRequest -Uri https://2.na.dl.wireshark.org/win64/Wireshark-win64-4.0.3.exe -OutFile .\Wireshark-win64-4.0.3.exe; Start-Process Wireshark-win64-4.0.3.exe -Wait -ArgumentList '/S /L*v ".\Wireshark-win64-4.0.3.log"'; rm .\Wireshark-win64-4.0.3.exe
}

$kubectlDir = "C:\bin\"
$kubectlPath = $kubectlDir+"kubectl.exe"
if (!(Test-Path $kubectlDir -PathType Container))
{
    New-Item -ItemType Directory -Force -Path $kubectlDir
}
if (!(Test-Path $kubectlPath -PathType Leaf))
{
    Invoke-WebRequest -Uri https://storage.googleapis.com/kubernetes-release/release/v1.26.0/bin/windows/amd64/kubectl.exe -OutFile $kubectlPath
}
$Path = (Get-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH).path
if ($Path -notlike "*$kubectlDir*")
{
    $Path = "$Path;$kubectlDir"
    Set-ItemProperty -Path 'Registry::HKEY_LOCAL_MACHINE\System\CurrentControlSet\Control\Session Manager\Environment' -Name PATH -Value $Path
}

 


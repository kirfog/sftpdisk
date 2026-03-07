# https://github.com/winfsp/winfsp
# https://github.com/winfsp/sshfs-win

$DriveLetter = "Z"
$RemotePath = "\\sshfs\sftp@11.22.33.44!2222"

if (Get-PSDrive -Name $DriveLetter -ErrorAction SilentlyContinue) {
    Write-Host "unmount $DriveLetter"
    $command = "net use $DriveLetter`: /delete /yes"
    Invoke-Expression $command
}
else {
    Write-Host "mount drive $DriveLetter to $RemotePath"
    $command = "net use $DriveLetter`:` $RemotePath /persistent:no"
    Invoke-Expression $command
}

# HardwareInfo.ps1
function RemoveAllChars {
    param  ([string]$string, [string]$delim)

    $output = [string]::Empty

    foreach ($s in $string.Split($delim)) {
        $output = $output + $s + " "
    }

    return $output.Trim()
}

echo --CPU--
Write-Output ("Name: " + (RemoveAllChars((gwmi Win32_Processor | Select-Object Name | Format-Table -HideTableHeaders | Out-String), "`n")))
Write-Output ("Speed: " + (RemoveAllChars((gwmi Win32_Processor | Select-Object MaxClockSpeed | Format-Table -HideTableHeaders | Out-String)), "`n") + " GHz")
Write-Output ("Socket: " + (RemoveAllChars((gwmi Win32_Processor | Select-Object SocketDesignation | Format-Table -HideTableHeaders | Out-String)), "`n"))

echo `n

echo --GPU--
Write-Output ("Card: " + (RemoveAllChars(gwmi Win32_VideoController | Select-Object Name | Format-Table -HideTableHeaders | Out-String), "`n"))

echo `n

echo --RAM--
#Total Installed Capacity
$capacity = 0
foreach($s in (gwmi win32_PhysicalMemory | Select-Object Capacity | Format-Table -HideTableHeaders | Out-String).Split("`n"))
{
    $temp = RemoveAllChars($s, " ")
    if(-not [string]::IsNullOrEmpty($temp))
    {
        
        $capacity += ([convert]::ToInt64($temp, 10) / 1024 / 1024 / 1024)
    }
}
Write-Output ("Total Capacity: " + $capacity + "GB")

#Counts how many slots are taken up
$slotcount = 0
foreach($s in (gwmi win32_PhysicalMemory | Select-Object Capacity | Format-Table -HideTableHeaders | Out-String).Split("`n"))
{
    $temp = RemoveAllChars($s, " ")
    if(-not [string]::IsNullOrEmpty($temp))
    {
        $slotcount += 1
        #Write-Output ([convert]::ToString([convert]::ToInt64($temp, 10) / 1024 / 1024 / 1024) + "GB")
    }
}
Write-Output ("Count: " + $slotcount)

#Stores RAM information
$ram = New-Object Collections.Generic.List[string]
for($i = 0; $i -lt $slotcount; $i++) {
    $ram.Add("")
}

#Slot iterator
$slot = 0

# Capacity
foreach($s in (gwmi win32_PhysicalMemory | Select-Object Capacity | Format-Table -HideTableHeaders | Out-String).Split("`n"))
{
    $temp = RemoveAllChars($s, " ")
    if(-not [string]::IsNullOrEmpty($temp))
    {
        $ram[$slot] += ([convert]::ToString([convert]::ToInt64($temp, 10) / 1024 / 1024 / 1024) + "GB") + " "
        $slot++
    }
}

$slot = 0

# Type
foreach($s in (gwmi win32_PhysicalMemory | Select-Object SMBIOSMemoryType | Format-Table -HideTableHeaders | Out-String).Split("`n"))
{
    $temp = RemoveAllChars($s, " ")
    if(![string]::IsNullOrEmpty($temp))
    {
        if($temp -eq "26")
        {
            $ram[$slot] += "DDR4"
        }
        elseif($temp -eq "25")
        {
            $ram[$slot] += "DDR3"
        }
        elseif($temp -eq "24")
        {
            $ram[$slot] += "DDR2-FB DIMM"
        }
        elseif($temp -eq "22")
        {
            $ram[$slot] += "DDR2"
        }

        $ram[$slot] += " "
        $slot++
    }
}

$slot = 0

# Speed
foreach($s in (gwmi win32_PhysicalMemory | Select-Object Speed | Format-Table -HideTableHeaders | Out-String).Split("`n"))
{
    $temp = RemoveAllChars($s, " ")
    if(![string]::IsNullOrEmpty($temp))
    {
        $ram[$slot] += [convert]::ToString([convert]::ToInt64($temp, 10))
        $slot++
    }
}

#Write Output
for($slot = 0; $slot -lt $ram.Count; $slot++) {
    Write-Output ("Slot " + $slot + ": " + $ram[$slot])
}

echo `n

echo --MOBA--
Write-Output ("Manufacturer: " + (RemoveAllChars((gwmi win32_BaseBoard | Select-Object Manufacturer | Format-Table -HideTableHeaders | Out-String), "`n")))
Write-Output ("Chipset: " + (RemoveAllChars((gwmi win32_BaseBoard | Select-Object Product | Format-Table -HideTableHeaders | Out-String), "`n")))

# Get-Exif, version 4 30.01.2025

# This is an experiment aimed at demonstrating the use value of AI generated code.
# The tool used was GitHub Copilot, a VS Code extension that uses OpenAI's GPT-3 
# model to generate code.

# The developer assistant managed to generate a script that reads EXIF data from 
# JPEG image file).
# The objective was, however, to extract GPS data from the file and copilot didn't
# manage to achieve that. 

# The aim was achived by reading EXIF documetation published by Microsoft.
# Also browsed a couple of articles touching upon the topic. 
# This article was particularly helpful:

# 'Extracting GPS numerical values from byte array using PowerShell'
# https://stackoverflow.com/questions/45136895/extracting-gps-numerical-values-from-byte-array-using-powershell

# Updates:

# Version 2 
# Clean up the code comment lightly

# Version 3
# Retrieve EXIF and GPS version information
# Add a Windows file dialog (and later on some persistent file settings)

# Version 4
# Use an Ordered Dictionary instead of a hash table in the return object

# Version 5
# Add GPSSatellites and GPSImgDirection to the return object
# Add an error message if user declines to select a file

# Load the required image processing assembly
Add-Type -AssemblyName System.Drawing

# Function to convert GPS coordinates to decimal
function ConvertToDecimal {
    param (
        [double[]]$coordinate,
        [string]$ref
    )
    $decimal = $coordinate[0] + ($coordinate[1] / 60) + ($coordinate[2] / 3600)
    if ($ref -eq "S" -or $ref -eq "W") {
        $decimal = -$decimal
    }
    return $decimal
}

# Function to get EXIF data
function Get-ExifData 
    {
    param ([string]$filePath)

    $image = [System.Drawing.Image]::FromFile($filePath)
    $propertyItems = $image.PropertyItems

    Write-Host "`nEXIF GPS coordinates in $($filepath):`n"

    # Initialize the EXIF data object to be returned
    # Was: $exifData = @{}
    $exifData = [Ordered]@{}

    foreach ($property in $propertyItems) 
        {
        $id = $property.Id
        # $type = $property.Type
        $value = $property.Value

        # Let's decode interesting camera and GPS EXIF id's
        switch ($id) 
            {
            0x9000 { $exifData.ExifVersion = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            0x010F { $exifData.Manufacturer = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            0x0110 { $exifData.Model = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            0x8827 { $exifData.ISO = [BitConverter]::ToUInt16($value, 0) }
# NB Consider using GPS timing instead or alongside the camera's DateTaken Id
            0x9003 { $exifData.DateTaken = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            0x0008 { $exifData.GPSSatellites = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }             
            0x0011 { 
                     [double]$ImgDirection = (([System.BitConverter]::ToInt32( $value, 0)) / ([System.BitConverter]::ToInt32($value, 4)))
                     $exifData.GPSImgDirection = $ImgDirection
                        }
            0x0000 { $exifData.GPSVersionID = @($value[0], $value[1], $value[2], $value[3]) }
            0x0001 { $exifData.GPSLatitudeRef = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            0x0002 { 
                # Extract the GPS Latitude values: degrees, minutes, seconds
                # They are stored in the EXIF as 3 double floats
                [double]$LatDegrees = (([System.BitConverter]::ToInt32( $value, 0)) / ([System.BitConverter]::ToInt32($value, 4)))
                [double]$LatMinutes = ([System.BitConverter]::ToInt32( $value, 8)) / ([System.BitConverter]::ToInt32($value, 12))
                [double]$LatSeconds = ([System.BitConverter]::ToInt32( $value, 16)) / ([System.BitConverter]::ToInt32($value, 20))
    
                # Let's print the values on the operator's console
                Write-Host "EXIF GPSLatitude  (d, m, s.s): $LatDegrees $LatMinutes $LatSeconds"
    
                # Store the array of values in the returned latitude object
                $exifData.GPSLatitude = @($LatDegrees, $LatMinutes, $LatSeconds)
                $exifData.GPSLatitudeDecimal = ConvertToDecimal -coordinate $exifData.GPSLatitude -ref $exifData.GPSLatitudeRef
                }
            0x0003 { $exifData.GPSLongitudeRef = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            0x0004 { 
                # Extract the GPS Longitude values: degrees, minutes, seconds
                # They are stored in the EXIF as 3 double floats
                [double]$LongDegrees = (([System.BitConverter]::ToInt32( $value, 0)) / ([System.BitConverter]::ToInt32( $value, 4)))
                [double]$LongMinutes = ([System.BitConverter]::ToInt32( $value, 8)) / ([System.BitConverter]::ToInt32( $value, 12))
                [double]$LongSeconds = ([System.BitConverter]::ToInt32( $value, 16)) / ([System.BitConverter]::ToInt32( $value, 20))
    
                # Let's print the values on the operator's console
                Write-Host "EXIF GPSLongitude (d, m, s.s): $LongDegrees $LongMinutes $LongSeconds"
    
                # Store the array of values in the returned longitude object
                $exifData.GPSLongitude = @($LongDegrees, $LongMinutes, $LongSeconds)
                $exifData.GPSLongitudeDecimal = ConvertToDecimal -coordinate $exifData.GPSLongitude -ref $exifData.GPSLongitudeRef
                }

            # Extract other EXIF properties (e.g. altitude if needed)
            }
        }

    # At https://stackoverflow.com/questions/59498570/powershell-sorting-hash-table
    # You fundamentally cannot sort a hash table ([hashtable] instance) by its keys: 
    # the ordering of keys in a hash table is not guaranteed and cannot be changed.

    # To solve your problem, you need a specialized data type that combines 
    # the features of a hash table with maintaining the entry keys in sort order

    # We should instead use Ordered Dictionary $hash = [Ordered]@{} above

    # Ordered dictionaries differ from hash tables in that the keys always appear in 
    # the order in which you list them. The order of keys in a hash table is not determined.

    return $exifData
    }

Function Get-File
    {
    Param
        (
        [Parameter(Mandatory=$false)]
        [string]$Title = 'Open',

        [Parameter(Mandatory=$false)]
        [string]$Filter = '',

        [Parameter(Mandatory=$false)]
        [switch]$Multiselect = $false,

        [Parameter(Mandatory=$false)]
        [switch]$CheckFileExists = $false
        )

	Add-Type -AssemblyName System.Windows.Forms

    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog

    $OpenFileDialog.Title = $Title
    $OpenFileDialog.InitialDirectory = $Settings.InitialDir
    $OpenFileDialog.Filter = $Filter
    $OpenFileDialog.Multiselect = $Multiselect
    $OpenFileDialog.CheckFileExists = $CheckFileExists

    $DialogResult = $OpenFileDialog.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true}))

   	If ($DialogResult -eq [Windows.Forms.DialogResult]::OK)
        {
        $FileNames = $OpenFileDialog.FileNames
        # $InitialDir = Split-Path $FileNames[0] -Parent
        }
    Else
        {
        Write-Verbose -Message 'User canceled file selection'
        }

    return $filenames
    }

# Our test case

# $filePath = "C:\Users\pdonner\Pictures\geotagged_photo\geotag_oskar.jpg"

$filePath = Get-File -Title 'Open JPEG file' -Filter 'JPEG files (*.jpg)|*.jpg' 

If ($null -eq $filePath)
    {
    Write-Host "`nThe user didn't select any file.`n"
    }
Else
    {
    $exifData = Get-ExifData -filePath $filePath

    Write-Host "`nReturned EXIF object (GPS coordinates and some camera data):"
    $exifData | Format-List
    }

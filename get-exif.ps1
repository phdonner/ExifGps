# Get-Exif, version 5.2 02.02.2025

# This is a utility which is used to browse GPS values in the EXIF metadata
# of JPEG files.

# Dot-source this script and call the Main function with a file path as a parameter,
# like this: 

# . '.\get-exif.ps1'
# Main -Path 'C:\path\to\your\file.jpg'

# Or if you need rich output append -Verbose to the command:

# Main -Path 'C:\path\to\your\file.jpg' -Verbose

# This is also an experiment aimed at testing and demonstrating the use value of 
# AI generated code. The tool was partly generated GitHub Copilot, a VS Code extension 
# that uses OpenAI's GPT-3 model to generate code. 

# The developer's Copilot assistant managed to generate a script that reads EXIF data
#  from JPEG image file). The objective was, however, to extract GPS data from 
# the file and Copilot didn't manage to achieve that aim. 

# The aim was achived by reading EXIF documetation published by Microsoft and 
# the Association of Camera and imaging Products (CIPA).
# Also browsed a couple of articles touching upon the topic. 
# This article was particularly helpful:

# 'Extracting GPS numerical values from byte array using PowerShell'
# https://stackoverflow.com/questions/45136895/extracting-gps-numerical-values-from-byte-array-using-powershell

# Updates:

# Version 2 
# Clean up the code and comment it lightly

# Version 3
# Retrieve EXIF and GPS version information
# Add a Windows file dialog (and later on some persistent file settings)

# Version 4
# Use an Ordered Dictionary instead of a hash table in the return object

# Version 5
# Add GPSSatellites and GPSImgDirection to the return object
# Add an error message if user declines to select a file
# Improve documentation.

# Version 5.1
# Clean up comments and readme material
# Improve the readability of the code
# Smoothen parameter names

# Version 5.2
# Improve formatting of the output of GPS values to display 
# rich content by tuning CMDLETBINDING and Write-Verbose functionality
# Separate main script into a Main function

# ---------------------------------------------------------------------------

# Copilot generated code:
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

# Copilot generated code, with manual modifications allowing access to
# double float latitude and longitude values. Also added a couple of 
# EXIF properties to the return object.

# Function to get EXIF data
function Get-ExifData 
    {
    [CmdletBinding()]
    param ([string]$Path)

    $image = [System.Drawing.Image]::FromFile($Path)
    $propertyItems = $image.PropertyItems

    Write-Verbose "`nRetrieved EXIF GPS coordinates in $($Path):`n"

    # Initialize the EXIF data object to be returned
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

#           0x9201 ShutterSpeedValue SRATIONAL (1)
#           0x9202 ApertureValue     RATIONAL (1)       
           
# NB Consider using GPS timing instead or alongside the camera's DateTaken Id
            0x9003 { $exifData.DateTaken = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            # Never seen this Id
            0x0008 { $exifData.GPSSatellites = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            # Never seen this Id
            0x0011 { 
                [double]$ImgDirection = (([System.BitConverter]::ToInt32( $value, 0)) / ([System.BitConverter]::ToInt32($value, 4)))
                $exifData.GPSImgDirection = $ImgDirection
                }
            0x0000 { $exifData.GPSVersionID = @($value[0], $value[1], $value[2], $value[3]) }
            0x0001 { $exifData.GPSLatitudeRef = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            0x0002 { 
                # Extract the GPS Latitude values: degrees, minutes, seconds
                # They are stored in the EXIF as 3 double floats
                [double]$LatDegrees = ([System.BitConverter]::ToInt32( $value, 0))  / ([System.BitConverter]::ToInt32($value, 4))
                [double]$LatMinutes = ([System.BitConverter]::ToInt32( $value, 8))  / ([System.BitConverter]::ToInt32($value, 12))
                [double]$LatSeconds = ([System.BitConverter]::ToInt32( $value, 16)) / ([System.BitConverter]::ToInt32($value, 20))
    
                # Store the array of values in the returned latitude object
                $exifData.GPSLatitude = @($LatDegrees, $LatMinutes, $LatSeconds)
                $exifData.GPSLatitudeDecimal = ConvertToDecimal -coordinate $exifData.GPSLatitude -ref $exifData.GPSLatitudeRef
                
                # Let's display the values on the operator's console
                Write-Verbose "EXIF GPSLatitude  (d, m, s.s): $($LatDegrees), $($LatMinutes), $($LatSeconds) and GPSLatitudeDecimal (d.nnnn): $($exifData.GPSLATitudeDecimal)"
                }
            0x0003 { $exifData.GPSLongitudeRef = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            0x0004 { 
                # Extract the GPS Longitude values: degrees, minutes, seconds
                # They are stored in the EXIF as 3 double floats
                [double]$LongDegrees = ([System.BitConverter]::ToInt32( $value, 0))  / ([System.BitConverter]::ToInt32( $value, 4))
                [double]$LongMinutes = ([System.BitConverter]::ToInt32( $value, 8))  / ([System.BitConverter]::ToInt32( $value, 12))
                [double]$LongSeconds = ([System.BitConverter]::ToInt32( $value, 16)) / ([System.BitConverter]::ToInt32( $value, 20))
    
                # Store the array of values in the returned longitude object
                $exifData.GPSLongitude = @($LongDegrees, $LongMinutes, $LongSeconds)
                $exifData.GPSLongitudeDecimal = ConvertToDecimal -coordinate $exifData.GPSLongitude -ref $exifData.GPSLongitudeRef

                # Let's display the values on the operator's console
                Write-Verbose "EXIF GPSLongitude (d, m, s.s): $($LongDegrees), $($LongMinutes), $($LongSeconds) and GPSLongitudeDecimal (d.nnnn): $($exifData.GPSLongitudeDecimal)"
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

# A function to allow Windows users to select a file
Function Get-File
    {
    [CmdletBinding()]
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

    # Reference the Windows forms namespace and create the file dialog object

	Add-Type -AssemblyName System.Windows.Forms
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog

    # Initialize the file dialog object with the vital parameters

    $OpenFileDialog.Title = $Title
    $OpenFileDialog.InitialDirectory = $Settings.InitialDir
    $OpenFileDialog.Filter = $Filter
    $OpenFileDialog.Multiselect = $Multiselect
    $OpenFileDialog.CheckFileExists = $CheckFileExists

    # Ready for the user to select a file

    $DialogResult = $OpenFileDialog.ShowDialog((New-Object System.Windows.Forms.Form -Property @{TopMost = $true}))

    If ($DialogResult -eq [Windows.Forms.DialogResult]::OK)
        {
        $FileNames = $OpenFileDialog.FileNames
        # $InitialDir = Split-Path $FileNames[0] -Parent
        }
    Else
        {
        Write-Debug -Message 'User canceled file selection'
        }

    return $filenames
    }

# Our Windows enabled test script:
Function Main
    {
    [CmdletBinding()]
    param (
        [string]$Path)

    # Load the required image processing assembly
    Add-Type -AssemblyName System.Drawing

    If ('' -eq $Path)
        {
        Write-Verbose "`nNo file path was provided as a command line argument.`n"

        # Let's present a Windows file dialog to the user

        $Path = Get-File -Title 'Select JPEG file' -Filter 'JPEG files (*.jpg)|*.jpg' 

        If ('' -eq $Path)
            {
            Write-Verbose "`nUser didn't select any file.`n"

            # Still no file reference. We are done here
            Exit
            }
        }
    
    # Let's check if the user submitted file exists

    If (Test-Path -Path $Path -PathType leaf)
        {
        $exifData = Get-ExifData -Path $Path

        $FileName = Split-Path -Path $Path -Leaf
        Write-Verbose "`nReturned EXIF object (some camera data and GPS coordinates) for $($FileName):"
        $exifData
        }
    else 
        {
        Write-Error "Invalid file reference: $Path"
        }
    }

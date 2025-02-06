# Get-Exif, version 6.2 04.02.2025

# This is a utility which is used to browse GPS values in the EXIF metadata
# of JPEG files.

# Dot-source this script and call the Main function with a file path as a parameter,
# like this: 

# . '.\get-exif.ps1'
# Main -Path 'C:\path\to\your\file.jpg'

# If you need rich output, append -Verbose to the command:

# Main -Path 'C:\path\to\your\file.jpg' -Verbose

# This is also an experiment aimed at testing and demonstrating the use value of 
# AI generated code. The tool was partly generated GitHub Copilot, a VS Code extension 
# that uses OpenAI's GPT-3 model to generate code. 

# The developer's Copilot assistant managed to generate a script that reads EXIF data
# from JPEG image file). The objective was, however, to extract GPS data from 
# the file and Copilot didn't manage to achieve that end. 

# The aim was achived by reading EXIF documetation published by Microsoft and 
# the Association of Camera and imaging Products (CIPA).
# Also browsed a couple of articles touching upon the topic. 
# This article was particularly helpful:

# 'Extracting GPS numerical values from byte array using PowerShell'
# https://stackoverflow.com/questions/45136895/extracting-gps-numerical-values-from-byte-array-using-powershell

# Updates:

# Version 1
# Initial Copilot genereated code with some manual modifications

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
# Improve documentation

# Version 5.1
# Clean up comments and readme material
# Improve the readability of the code
# Smoothen parameter names

# Version 5.2
# Improve formatting of the output of GPS values to display 
# rich content by tuning CMDLETBINDING and Write-Verbose functionality
# Separate main script into a Main function

# Version 5.3
# Add GPSMeasureMode, GPSTrackRef, GPSTrack, GPSImgDirectionRef, 
# GPSSpeedRef, GPSSpeed, GPSDestDistanceRef, GPSDestDistance
# GPSTimeStamp, GPSDOP, GPSMapDatum to the return object

# Version 6
# Serve Linux and Apple users by adding a Read-Host prompt for 
# the file path parameter

# Version 6.1
# Add a prompt argument to force the user to fill in the path
# on the command line or at the Read-Host command prompt
# Tell user when there is no Exif in the JPEG picture
# Make verbose output more informative

# Version 6.2
# Include *.jpeg in the Windows file filter
# Add the EXIF GPS IDs: GPSAltitudeRef, GPSaltitude

# Version 6.3
# Correct Copilot-generated divide by zero error in GPSLatitude and GPSLongitude

# Version 6.4
# Add missing EXIF GPS related IDs:
# Image.GPSTag, GPSProcessingMethod, GPSAreaInformation, 
# GPSDateStamp, GPSDifferential, GPSHPositioningError

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

    If ($propertyItems.Count -eq 0)
        {
        Write-Verbose "No EXIF records found in $($Path).`n"
        return
        }

    Write-Verbose "Retrieved $($propertyItems.Count) EXIF records in $($Path):`n"
   
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
            # Photo section:
            0x5090 { $exifData.LuminanceTable = 'n.a.' }
            0x5091 { $exifData.ChrominanceTable = 'n.a.' }

            0x9000 { $exifData.ExifVersion  = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
           
            # Image section:
            0x010E { $exifData.ImageDescription = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            0x010F { $exifData.Make             = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            0x0110 { $exifData.Model            = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            0x8769 { $exifData.ExifTag          = [BitConverter]::ToUInt32($value, 0) }
            0x8822 { $exifData.ExposureTime     = [BitConverter]::ToUInt16($value, 0) }
            0x8824 { $exifData.ExposureProgram  = [BitConverter]::ToUInt16($value, 0) }
            0x8825 { $exifData.ISOSpeedRatings  = [BitConverter]::ToUInt16($value, 0) }
            0x8827 { $exifData.ISO              = [BitConverter]::ToUInt16($value, 0) }
            # NB Consider using GPS timing instead or alongside the camera's DateTaken Id
            0x9003 { $exifData.DateTaken        = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
#           0x9201 ShutterSpeedValue SRATIONAL (1)
#           0x9202 ApertureValue     RATIONAL (1)       
            0x9286  { $exifData.UserComment     = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }

            # GPSInfo section:
            0x0000 { $exifData.GPSVersionID = @($value[0], $value[1], $value[2], $value[3]) }
            0x0001 { $exifData.GPSLatitudeRef = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            0x0002 { 
                # Extract the GPS Latitude values: degrees, minutes, seconds
                # They are stored in the EXIF as 3 double floats
                $LatDegrees = $null
                $LatMinutes = $null
                $LatSeconds = $null

                If (0 -eq ([System.BitConverter]::ToInt32($value, 4)))
                    {
                    Write-Verbose "No GPS Latitude data found in $($Path).`n"
                    }
                Else
                    {
                    [double]$LatDegrees = ([System.BitConverter]::ToInt32( $value, 0))  / ([System.BitConverter]::ToInt32($value, 4))
                    [double]$LatMinutes = ([System.BitConverter]::ToInt32( $value, 8))  / ([System.BitConverter]::ToInt32($value, 12))
                    [double]$LatSeconds = ([System.BitConverter]::ToInt32( $value, 16)) / ([System.BitConverter]::ToInt32($value, 20))
    
                    # Store the array of values in the returned latitude object
                    $exifData.GPSLatitude = @($LatDegrees, $LatMinutes, $LatSeconds)

                    # Not an EXIF id. This Conversion was supplied by Copilot. The format is easier to read and use
                    $exifData.GPSLatitudeDecimal = ConvertToDecimal -coordinate $exifData.GPSLatitude -ref $exifData.GPSLatitudeRef
                
                    # Display the values on the operator's console
                    Write-Verbose "EXIF GPSLatitude  (d, m, s.s): $($LatDegrees), $($LatMinutes), $($LatSeconds) and GPSLatitudeDecimal (d.nnnn): $($exifData.GPSLATitudeDecimal)"
                    }
                }
            0x0003 { $exifData.GPSLongitudeRef = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            0x0004 { 
                # Extract the GPS Longitude values: degrees, minutes, seconds
                # They are stored in the EXIF as 3 double floats

                $LongDegrees = $null
                $LongMinutes = $null
                $LongSeconds = $null

                If (0 -eq ([System.BitConverter]::ToInt32($value, 4)))
                    {
                    Write-Verbose "No GPS Longitude data found in $($Path).`n"
                    }
                Else
                    {
                    [double]$LongDegrees = ([System.BitConverter]::ToInt32( $value, 0))  / ([System.BitConverter]::ToInt32( $value, 4))
                    [double]$LongMinutes = ([System.BitConverter]::ToInt32( $value, 8))  / ([System.BitConverter]::ToInt32( $value, 12))
                    [double]$LongSeconds = ([System.BitConverter]::ToInt32( $value, 16)) / ([System.BitConverter]::ToInt32( $value, 20))

                    # Store the array of values in the returned longitude object
                    $exifData.GPSLongitude = @($LongDegrees, $LongMinutes, $LongSeconds)

                    # Not an EXIF id. This Conversion was supplied by Copilot. The format is easier to read and use
                    $exifData.GPSLongitudeDecimal = ConvertToDecimal -coordinate $exifData.GPSLongitude -ref $exifData.GPSLongitudeRef

                    # Display the values on the operator's console
                    Write-Verbose "EXIF GPSLongitude (d, m, s.s): $($LongDegrees), $($LongMinutes), $($LongSeconds) and GPSLongitudeDecimal (d.nnnn): $($exifData.GPSLongitudeDecimal)"
                    }
                }
            0x0005 { $exifData.GPSAltitudeRef = $value[0] }
            0x0006 { [double]$exifData.GPSAltitude  = ([System.BitConverter]::ToInt32( $value, 0))  / ([System.BitConverter]::ToInt32( $value, 4)) }
            0x0007 { 
                [int]$GPSTimeHours = ([System.BitConverter]::ToInt32( $value, 0))  / ([System.BitConverter]::ToInt32( $value, 4))
                [int]$GPSTimeMinutes = ([System.BitConverter]::ToInt32( $value, 8))  / ([System.BitConverter]::ToInt32( $value, 12))
                [double]$GPSTimeSeconds = ([System.BitConverter]::ToInt32( $value, 16)) / ([System.BitConverter]::ToInt32( $value, 20))
                $exifData.GPSTimeStamp = @($GPSTimeHours, $GPSTimeMinutes, $GPSTimeSeconds)
                }
            # Never seen this Id
            0x0008 { $exifData.GPSSatellites        = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            # Never seen this Id
            0x0009 { $exifData.GPSStatus            = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            # Never seen this Id
            0x000a { $exifData.GPSMeasureMode       = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            0x000b { [double]$exifData.GPSDOP       = (([System.BitConverter]::ToInt32( $value, 0)) / ([System.BitConverter]::ToInt32($value, 4))) }
            0x000c { $exifData.GPSSpeedRef          = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            0x000d { [double]$exifData.GPSSpeed     = (([System.BitConverter]::ToInt32( $value, 0)) / ([System.BitConverter]::ToInt32($value, 4))) }
            # Never seen this Id
            0x000e { $exifData.GPSTrackRef          = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            # Never seen this Id
            0x000f { [double]$exifData.GPSTrack     = (([System.BitConverter]::ToInt32( $value, 0)) / ([System.BitConverter]::ToInt32($value, 4))) }
            0x0010 { $exifData.GPSImgDirectionRef   = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            0x0011 { [double]$exifData.GPSImgDirection = (([System.BitConverter]::ToInt32( $value, 0)) / ([System.BitConverter]::ToInt32($value, 4))) }
            0x0012 { $exifData.GPSMapDatum         = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            0x0013 { $exifData.GPSDestLatitudeRef   = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            0x0014 { [double]$exifData.GPSDestLatitude = (([System.BitConverter]::ToInt32( $value, 0)) / ([System.BitConverter]::ToInt32($value, 4))) }
            0x0015 { $exifData.GPSDestLongitudeRef  = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            0x0016 { [double]$exifData.GPSDestLongitude = (([System.BitConverter]::ToInt32( $value, 0)) / ([System.BitConverter]::ToInt32($value, 4))) }
            0x0017 { $exifData.GPSDestBearingRef    = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            0x0018 { [double]$exifData.GPSDestBearing = (([System.BitConverter]::ToInt32( $value, 0)) / ([System.BitConverter]::ToInt32($value, 4))) }
            # Never seen this Id
            0x0019 { $exifData.GPSDestDistanceRef   = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            # Never seen this Id
            0x001a { [double]$exifData.GPSDestDistance = (([System.BitConverter]::ToInt32( $value, 0)) / ([System.BitConverter]::ToInt32($value, 4))) }
            # Never seen this Id
            0x001b { $exifData.GPSProcessingMethod  = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            # Never seen this Id
            0x001c { $exifData.GPSAreaInformation   = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            0x001d { $exifData.GPSDateStamp         = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            # Never seen this Id
            0x001e { $exifData.GPSDifferential      = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }
            0x001f { [double]$exifData.GPSHPositioningError = ([System.BitConverter]::ToInt32( $value, 0))  / ([System.BitConverter]::ToInt32( $value, 4)) }
            # Copilot generated code
            # 0x001f { $exifData.GPSHPositioningError = [System.Text.Encoding]::ASCII.GetString($value).Trim([char]0) }

<# 
        Cf. the recent document 
        'Standard Exif Tags' 'These are the Exif tags as defined in the Exif 2.3 standard'
        https://www.exiv2.org/tags.html
        There the values are also defined and explained in detail.

        GPS EXIF ids are enumerated in https://www.imo.universite-paris-saclay.fr/~thierry.bousch/exifdump.py

            GPS_TAGS = {
                0x0:	"GPSVersionID",
                0x1:	"GPSLatitudeRef",
                0x2:	"GPSLatitude",
                0x3:	"GPSLongitudeRef",
                0x4:	"GPSLongitude",
                0x5:	"GPSAltitudeRef",
                0x6:	"GPSAltitude",
                0x7:	"GPSTimeStamp",
                0x8:	"GPSSatellites",
                0x9:	"GPSStatus",
                0xA:	"GPSMeasureMode",
                0xB:	"GPSDOP",
                0xC:	"GPSSpeedRef",
                0xD:	"GPSSpeed",
                0xE:	"GPSTrackRef",
                0xF:	"GPSTrack",
                0x10:	"GPSImgDirectionRef",
                0x11:	"GPSImgDirection",
                0x12:	"GPSMapDatum",
                0x13:	"GPSDestLatitudeRef",
                0x14:	"GPSDestLatitude",
                0x15:	"GPSDestLongitudeRef",
                0x16:	"GPSDestLongitude",
                0x17:	"GPSDestBearingRef",
                0x18:	"GPSDestBearing",
                0x19:	"GPSDestDistanceRef",
                0x1A:	"GPSDestDistance",
                0x1B:	"GPSProcessingMethod",
                0x1C:	"GPSAreaInformation",
                0x1D:	"GPSDateStamp",
                0x1E:	"GPSDifferential"
            }
#>
            # Extract other EXIF properties (e.g. altitude if needed)
            }
        }

    # Comment at https://stackoverflow.com/questions/59498570/powershell-sorting-hash-table
    # You fundamentally cannot sort a hash table ([hashtable] instance) by its keys: 
    # the ordering of keys in a hash table is not guaranteed and cannot be changed.

    # To solve your problem, you need a specialized data type that combines 
    # the features of a hash table with maintaining the entry keys in sort order

    # We should instead use Ordered Dictionary $hash = [Ordered]@{} Cf. above

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

# Our test script. 

# Call
# Main -Path 'C:\path\to\your\file.jpg'
# or just Main and you will be prompted to provide a file path
# Main -Verbose will provide rich output

Function Main
    {
    [CmdletBinding()]
    param (
        [string]$Path)

    # Load the required image processing assembly
    Add-Type -AssemblyName System.Drawing

    # Let's have a look at what the user provided on the command line
    If ('' -eq $Path)
        {
        If ($IsWindows)
            {
            Write-Verbose "No file path was provided as a command line argument.`n"

            # Let's present a Windows file dialog to the user

            $Path = Get-File -Title 'Select JPEG file' -Filter 'JPEG files (*.jpg; *.jpeg)|*.jpg; *.jpeg' 

            If ('' -eq $Path)
                {
                Write-Verbose "User didn't select any file.`n"

                # Still no file reference. We are done here
                Exit
                }
            }
        else
            {
            # Let's prompt the user to provide a file path

            $Path = Read-Host -Prompt 'Please provide a file path to a JPEG file'
            }

        # Did we get a file path?

        If ('' -eq $Path)
            {
            Write-Verbose "User didn't provide a file path.`n"

            # Still no file reference. We are done here
            Exit
            }
        }
    
    # Let's check the the user submitted file exists
    # TODO Provide some more JPEG sanity checking as well

    If (Test-Path -Path $Path -PathType leaf)
        {
        $exifData = Get-ExifData -Path $Path

        $FileName = Split-Path -Path $Path -Leaf
        Write-Verbose "Returned EXIF object (some image, photo data and/or GPS Info) for $($FileName):"
        $exifData
        }
    else 
        {
        Write-Error "Invalid file reference: $Path"
        }
    }

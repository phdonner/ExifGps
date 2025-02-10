# ExifGps Changelog (2025-02-06)

All notable changes to this project will be documented in this file.

## [0.6.7] - 2025-02-10

### Updates ver. 6.7

- Exclude decimal conversions from return object
- Check all GPS parameter nemes from Exif standard 3.0

## [0.6.6] - 2025-02-07

### Minor updates ver. 6.6

- Organize comments and check return values
- Correct output of GPSLatitude and GPSLongitude zero values

## [0.6.5] - 2025-02-06

### Minor update ver. 6.5

- Make slight improvements in CHANGELOG.md

## [0.6.4] - 2025-02-06

### Add missing EXIF GPS related IDs ver. 6.4

- Add: Image.GPSTag, GPSProcessingMethod, GPSAreaInformation, GPSDateStamp, GPSDifferential, GPSHPositioningError
- Move update history to CHANGELOG.md

## [0.6.3] - 2025-02-05

### Tune script and README ver. 6.3

- Correct Copilot-generated divide by zero error in GPSLatitude and GPSLongitude

## [0.6.2] - 2025-02-04

### Tune script and README ver. 6.2

- Include *.jpeg in the Windows file filter
- Add EXIF GPS IDs: GPSAltitudeRef, GPSaltitude

## [0.6.1] - 2025-02-04

### ExifGps.ps1 updates ver. 6.1

- Add a prompt argument to force the user to fill in the path on the command line or at the Read-Host command prompt
- Tell user when there is no Exif in the JPEG picture
- Make verbose output more informative

## [0.6.0] - 2025-02-03

### ExifGps.ps1 ver. 6.0

- Serve Linux and Apple users by adding a Read-Host prompt for the file path parameter

## [0.5.3] - 2025-02-02

### Update script to ver. 5.3

- Add GPS IDs to the return object: MeasureMode, GPSTrackRef, GPSTrack, GPSImgDirectionRef, GPSSpeedRef, GPSSpeed, GPSDestDistanceRef, GPSDestDistance, GPSTimeStamp, GPSDOP, GPSMapDatum

## [0.5.2] - 2025-02-02

### Transfer rich console output to Write-Verbose commands

- Improve formatting of the output of GPS values to display rich content by tuning CMDLETBINDING and Write-Verbose functionality
- Separate main script into a Main function

## [0.5.1] - 2025-02-01

### Make another slight update of get-exif.ps1 ver. 5.1

- Clean up comments and readme material
- Improve the readability of the code
- Smoothen parameter names

## [0.5.0] - 2025-02-01

### Merge cleaned up file with main branch

- Add GPS IDs GPSSatellites and GPSImgDirection to the return object
- Add an error message if user declines to select a file
- Improve readme documentation

## [0.4.0] - 2025-01-31

### First commit

- Use an Ordered Dictionary instead of a hash table in the return object

## [0.3.0] - 2025-01-31

### Set up a GitHub.com repository

- Retrieve EXIF and GPS version information
- Add a Windows file dialog (and later on some persistent file settings)

## [0.2.0 ] - 2025-01-31

### Set up a Visual Studio workspace

- Clean up the Copilot generated code and comment it lightly

## [0.1.0] - 2025-01-27

### Create initial version

- Generate initial Copilot code
- Make some manual improvements

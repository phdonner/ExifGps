# ExifGps - A reader of EXIF GPS values in JPEG photographs

The ExifGps repository gives users the ability to read values of EXIF camera and GPS identifiers on PowerShell Windows hosts.

It is a utility which is meant to be used in developing a documentation system for village network construction. Eearthwork builders and telecom installators submit their geotagged photographs to the project coordinator. With this script the constructors and the administrator can verify that the image contains the vital date and location data. It also returns a PowerShell object which can be piped to GIS-capable software.

The ExifGps utility is hopefully helpful in integrating photo acquisiton with geotagged representation of images and related information in the open-source and free geographical information tool QGIS. The documentator integrates the images with map data in a QGIS ImportPhotos layer of QGIS. ImportPhotos is a plugin tool for QGIS. It can be used to import Geo-Tagged JPEG photos as points or any other marker on QGIS maps. The photos and metainformation can be viewed on a map layer of choice.

In QGIS, the ImportPhoto user is able to select a folder with photos and only geo-tagged photos will be imported. Then a layer will be created which will contain the name of the photograph, its directory, the date and time taken, altitude, longitude, latitude, azimuth, north, camera maker and model, title, user comment and relative path.

Limitations: The file open dialog is based on functionality which apparently is available only on Windows hosts. Some Read-Host functionality will carry out the same job on Apple and Linux systems.

Please note that [ExifTool by Phil Harvey](https://exiftool.org/) is another, extremly versatile tool for reading and editing of Exif information. It works on Windows, Linux and Apple platforms and it is capable of handling quite a number of image and document formats. ExifTool is also very well equipped in handling a multitude of languages. Unfortunately rich features come with a steeper learning curve. The following is a pointer to discussion of problems in integrating ExifTool with Powershell: [Running in Powershell function with exiftool if condition.](https://exiftool.org/forum/index.php?topic=15143.0)

# ExifGps - A reader of EXIF GPS values in JPEG photographs

The ExifGps repository gives users the ability to read values of the most important EXIF camera and GPS identifiers on PowerShell Windows hosts.

It is a utility which is being used in developing a documentation system for village network construction. Eearthwork builders and telecom installators submit their geotagged photographs to the project coordinator. With this script the administrator can control that the photographs contain the vital date and location data.

The coordinator integrates the images with map data in a QGIS ImportPhotos layer. ImportPhotos is plugin tool for the free and open-source QGIS geographical information system. ImportPhotos can be used to import Geo-Tagged JPEG photos as points to QGIS. The photos and metainformation can be viewed on a map layer in QGIS.

In QGIS the user is able to select a folder with photos and only the geo-tagged photos will be imported. Then a layer will be created which will contain the name of the picture, its directory, the date and time taken, altitude, longitude, latitude, azimuth, north, camera maker and model, title, user comment and relative path.

Limitations: The file open dialog is based on functionality which apparently is available only on Windows hosts.

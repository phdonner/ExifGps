# ExifGps - A PowerShell reader of EXIF GPS values in JPEG photographs

The ExifGps repository gives users the ability to read values of EXIF camera and GPS identifiers of JPEG photographs or images on any PowerShell host.

The GPSLongitudeDecimal and GPSLongitudeDecimal are not part of the Exif standard. There is no native way of representing the coordinates. Degrees with decimals as double floats is more flexible way to handle this identifiers in computer programs.

It is a utility which is meant to be used in developing a documentation system for village network construction. Earthwork builders and telecom technicians submit their geotagged photographs to the project coordinator. With this script the constructors and the administrator can verify that the image contains the vital date and location data. The script returns a PowerShell object which can be piped to GIS-capable software.

The ExifGps utility is hopefully helpful in integrating photo acquisition with geotagged representation of images and related information in the open-source and free geographical information tool QGIS. The documenter integrates the images with map data in a QGIS ImportPhotos layer of QGIS. ImportPhotos is a plugin tool for QGIS. It can be used to import geo-tagged JPEG photos as points or any other graphical marker on QGIS maps. The photo markers and metainformation can be viewed on a map layer of choice.

In QGIS, the ImportPhotos user is able to select a folder with photos and only geo-tagged photos will be imported. Then a layer will be created which will contain the name of the photograph, its directory, the date and time taken, altitude, longitude, latitude, azimuth, north, camera maker and model, title, user comment and relative path.

The file open dialog is based on functionality which is available only on Windows hosts. Linux and Apple
users can supply the file reference by supplying the command line argument or the Read-Host prompt.

Please, note that [ExifTool by Phil Harvey](https://exiftool.org/) is another extremely versatile tool for reading and editing of Exif information. The software works on Windows, Linux and Apple platforms and it is capable of handling quite a number of image and document formats. ExifTool is also very well equipped in handling a multitude of languages. Unfortunately, rich features come with a steeper learning curve. The following is a pointer to discussion of problems in integrating ExifTool with Powershell: [Running in Powershell function with exiftool if condition.](https://exiftool.org/forum/index.php?topic=15143.0)

## Call structurec

Our test script can be activated by calling:

```powershell
Main -Path 'C:\path\to\your\file.jpg'
```

You can alternatively just call Main and you will be prompted to provide a file path. The Verbose argument will provide some readible output about EXIF in the JPEG file.

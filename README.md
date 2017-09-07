# CALeDNA
Scripts associated with CALeDNA work

Tips for working with the Land Cover script:
For each input coordinate, the script will return multiple lines, depending on how many land cover types it detects (each line will also have a percentage).
Make sure to check the all caps parts to replace with your own file details as needed
 - "PATH TO FOLDER WITH RASTER IMG FILE"
 - "NLCD RASTER .IMG FILE"
 - "COORDS .CSV FILE"
 - "FINAL FILE NAME .XLSX"
Besides changing these, if Latitude and Longitude are not named "Latitude"/"Longitude", "latitude"/"longitude", or "x"/"y", make sure to change the names in your file to one of these or write in your own code to include your naming system.
You can change the buffer radius to whatever meter radius around the coordinate you want it to search. However, making it much lower than 30 will give an error or only give one land cover type. Look for buffer=30 in the file to find what to change if you want a custom radius.

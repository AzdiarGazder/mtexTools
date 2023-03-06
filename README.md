# [**mtexTools**](https://github.com/AzdiarGazder/mtexTools)
This is a collated library of additional MTEX functions and their demonstration scripts. The functions are directly incorporated into MTEX and can be seamlessly and readily used without modification. 

Visitors to this site may download and implement the entire library or may download individual scripts related to specific tools. Please report any issues with the scripts or webpage to the author (in your email program, please replace the dots in the author's email address to make it work).

---

## How to cite mtexTools
- If these scripts and tools prove useful and contributes to published works in any way, please consider an acknowledgement by citing the following reference:

**A.A. Gazder, mtexTools: A collated library of additional MTEX functions and their demonstration scripts, Github, accessed Date-Month-Year, <https://github.com/AzdiarGazder/mtexTools>.**

- If users wish to modify any of these scripts, they are welcome to do so. If modified software is redistributed, please include attribution(s) to the original author(s).

---
## Script library

## A
- [**align**](https://github.com/AzdiarGazder/mtexTools/tree/main/align): Align ebsd map data along a user-specified linear fiducial in case of drift caused by the thermal cycling of scanning coil electronics during acquisition. The linear fiducial may correspond to a twin boundary, stacking fault, or any linear-shaped deformation or phase transformation products. Instructions on script use are provided in the window titlebar.

## C
- [**crop**](https://github.com/AzdiarGazder/mtexTools/tree/main/crop): Crop, cut-out or make a subset of ebsd map data from within a user-specified rectangular, circular, polygonal or freehand area-based region of interest (ROI). Instructions on script use are provided in the window titlebar.

## E
- [**euclideanDistance**](https://github.com/AzdiarGazder/mtexTools/tree/main/euclideanDistance): Calculates the 2D Euclidean distance in pixels (default) or map scan units for supported distance methods for each pixel within a grain. The default 2D Euclidean distance measurement is from the grain center to the grain boundary in pixels or map scan units. The 2D Euclidean distance measurement from the grain boundary to the grain center is available but only when specified by the user. The values are returned within the 'ebsd.prop.euclid' structure variable.

## S
- [**split**](https://github.com/AzdiarGazder/mtexTools/tree/main/split): Splits or sub-divides an ebsd map into a regular, rectangular matrix of submaps with a user-specified number of rows and columns. Additional inputs include the ability to overlap a length fraction along both, horizontal and vertical submap directions. The submaps are returned to the main MATLAB workspace as individual ebsd variables. The location of each sub-map is denoted by the row and column number. For example: ebsd23 = sub-map from row 2, column 3 of the ebsd map.

- [**stitch**](https://github.com/AzdiarGazder/mtexTools/tree/main/stitch): Stitch, combine or merge two ebsd maps togther by defining a user-specified position (and offset) for map 2 relative to map 1.






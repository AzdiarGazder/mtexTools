# [**mtexTools**](https://github.com/AzdiarGazder/mtexTools)
[**MTEX**](https://mtex-toolbox.github.io/) is a free-to-download Matlab toolbox for analysing electron back-scattering diffraction (EBSD) map data. The toolbox is used by researchers from around the world who are interested in script-based microstructure and crystallographic analyses.

MTEX is fully capable of interrogating, processing, and manipulating EBSD map data obtained in several configurations from different OEM vendors. Perhaps its single most powerful attribute is that the toolbox itself is fully scriptable. This allows users to develop scripts (or codes or programs) to add functionality where needed. It enables a fully customisable analytical experience and unlike commercial OEM software suites, provides for an ever-evolving library of niche capabilities.

This [**mtexTools**](https://github.com/AzdiarGazder/mtexTools) webpage is a collated library of additional MTEX functions and their demonstration scripts. The functions are directly incorporated into the latest version of MTEX and can be seamlessly and readily used without modification. 

---

## How to use [**mtexTools**](https://github.com/AzdiarGazder/mtexTools)
Visitors to this webpage may download and implement the entire library or individual scripts related to specific tools. Please report any issues with the scripts or webpage to the author using the discussion section or directly via email (for a valid email address, please replace the word "dots" with periods).

---

## How to cite [**mtexTools**](https://github.com/AzdiarGazder/mtexTools)
- If these scripts and tools prove useful and contributes to published works in any way, please consider an acknowledgement by citing the following reference:

**A.A. Gazder, mtexTools: A collated library of additional MTEX functions and their demonstration scripts, Github, accessed Date-Month-Year, <https://github.com/AzdiarGazder/mtexTools>.**

- If users wish to modify any of these scripts, they are welcome to do so. If modified scripts are redistributed, please include attribution(s) to the original author(s) as a courtesy within the acknowledgements section of the script.

---
## Alphabetical list of scripts in the [**mtexTools**](https://github.com/AzdiarGazder/mtexTools) library

## A
- [**align**](https://github.com/AzdiarGazder/mtexTools/tree/main/align): Align ebsd map data along a user-specified linear fiducial in case of drift caused by the thermal cycling of scanning coil electronics during acquisition. The linear fiducial may correspond to a twin boundary, stacking fault, or any linear-shaped deformation or phase transformation products. Instructions on script use are provided in the window titlebar.



## C
- [**crop**](https://github.com/AzdiarGazder/mtexTools/tree/main/crop): Crop, cut-out or make a subset of ebsd map data from within a user-specified rectangular, circular, polygonal or freehand area-based region of interest (ROI). Instructions on script use are provided in the window titlebar.

- [**currentFolder**](https://github.com/AzdiarGazder/mtexTools/tree/main/currentFolder): Change MATLAB's current folder to the folder containing this function and add all of its sub-folders to the work path.



## E
- [**euclideanDistance**](https://github.com/AzdiarGazder/mtexTools/tree/main/euclideanDistance): Calculates the 2D Euclidean distance in pixels (default) or map scan units for supported distance methods for each pixel within a grain. The default 2D Euclidean distance measurement is from the grain center to the grain boundary in pixels or map scan units. The 2D Euclidean distance measurement from the grain boundary to the grain center is available but only when specified by the user. The values are returned within the 'ebsd.prop.euclid' structure variable.



## F
- [**fibreMaker**](https://github.com/AzdiarGazder/mtexTools/tree/main/fibreMaker): Creates an ideal crystallographic fibre ODF with a user specified half-width and exports the data as a VPSC file for later use.


## O

- [**orientationMaker**](https://github.com/AzdiarGazder/mtexTools/tree/main/orientationMaker): Creates an ideal crystallographic orientation with a user specified half-width and exports the data as a VPSC file for later use.



## R
- [**recolor**](https://github.com/AzdiarGazder/mtexTools/tree/main/recolor): Recolor phases using the ebsd or grains variables interactively via a GUI or via scripting.

- [**rename**](https://github.com/AzdiarGazder/mtexTools/tree/main/rename): Rename phases using the ebsd or grains variables interactively via a GUI or via scripting.



## S
- [**setLabels2Latex**](https://github.com/AzdiarGazder/mtexTools/tree/main/setLabels2Latex): Changes all MATLAB text interpreters from 'tex' to 'latex' in all subsequent figures, plots, and graphs.

- [**setLabels2Tex**](https://github.com/AzdiarGazder/mtexTools/tree/main/setLabels2Tex): Changes all MATLAB text interpreters from 'latex' to 'tex' in all subsequent figures, plots, and graphs.

- [**split**](https://github.com/AzdiarGazder/mtexTools/tree/main/split): Splits or sub-divides an ebsd map into a regular, rectangular matrix of submaps with a user-specified number of rows and columns. Additional inputs include the ability to overlap a length fraction along both, horizontal and vertical submap directions. The submaps are returned to the main MATLAB workspace as individual ebsd variables. The location of each submap is denoted by the row and column number. For example: ebsd23 = a submap from row 2, column 3 of the ebsd map.

- [**stitch**](https://github.com/AzdiarGazder/mtexTools/tree/main/stitch): Stitch, combine or merge two ebsd maps together into one map by defining a user-specified position and offset/overlay for map 2 relative to map 1.






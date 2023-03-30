## ANNOUNCEMENTS

**BUG FIX**
**[MTEX Versions 5.9 and higher = use ebsd.extent]** 
**[MTEX Versions 5.8 and lower = use ebsd.extend]** 

---



# [**mtexTools**](https://github.com/AzdiarGazder/mtexTools)
[**MTEX**](https://mtex-toolbox.github.io/) is a free-to-download [**Matlab**](https://au.mathworks.com/products/matlab.html) toolbox for analysing electron back-scattering diffraction (EBSD) map data. The toolbox is used by researchers from around the world who are interested in script-based microstructure and crystallographic analyses.

MTEX is fully capable of interrogating, processing, and manipulating EBSD map data obtained in several configurations from different OEM vendors. Perhaps its single most powerful characteristic is that the toolbox itself is fully scriptable. This allows users to develop scripts (or codes or programs) to add functionality where needed. It enables a fully customisable analytical experience and unlike commercial OEM software suites, provides for an ever-evolving library of niche capabilities.

This [**mtexTools**](https://github.com/AzdiarGazder/mtexTools) webpage is a collated library of additional MTEX functions and their demonstration scripts. Some are original scripts by this author whereas others were gleaned and/or put together from various sources. In the latter case, and while concurrently choosing not to re-invent the wheel, the scripts were modified to either improve on their logic and efficiency or increase their general functionality and usability within MTEX/Matlab. For all such scripts, attributions to the original author are stated in the acknowledgements section of the relevant function. Regardles of their antecedent(s), all scripts in the mtexTools library are directly incorporated into the latest version of MTEX and can be seamlessly and readily used without modification. 

---

## How to use [**mtexTools**](https://github.com/AzdiarGazder/mtexTools)
Visitors to this webpage may download and implement the entire library or individual scripts related to specific tools. Please report any issues with the scripts or webpage to the author using the discussion section or directly via email (for a valid email address, please replace the word "dots" with periods).

The recommended method, which helps keep all mtexTools functions and scripts up-to-date, is as follows: 
1. Download and install the [**GitHub Desktop**](https://desktop.github.com/).
2. Within the GitHub Desktop, click on **Files -> Clone a repository -> URL**.
3. In the **"Repository URL or GitHub username and repository"** dialog, type in "https://github.com/AzdiarGazder/mtexTools" (without quotes).
4. In the **"Local path"** dialog, specify a local subfolder within your Matlab work path (usually "C:\Users\userName\Documents\MATLAB\GitHub" (without quotes)).
5. Click **"Clone"**. All files in this repository will then be available within the local subfolder "C:\Users\userName\Documents\MATLAB\GitHub\MtexTools".
6. Add the local subfolder in pt. 5 (and its subfolders) to your Matlab work path. 
7. Restart Matlab. All functions in the mtexTools library will now be available for use.
8. Remember to return to the GitHub Desktop on a weekly/monthly basis and click on **"Fetch origin"** to pull any updates/edits/changes from the repository to your local subfolder. 

---

## How to cite [**mtexTools**](https://github.com/AzdiarGazder/mtexTools)
- If these scripts and tools prove useful and contribute to published works in any way, please consider an acknowledgement by citing the following reference:

**A.A. Gazder, mtexTools: A collated library of additional MTEX functions and their demonstration scripts, Github, accessed Date-Month-Year, <https://github.com/AzdiarGazder/mtexTools>.**

- If users wish to modify any of these scripts, they are welcome to do so. If modified scripts are redistributed, please include attribution(s) to the original author(s) as a courtesy within the acknowledgements section of the script.

---
## Alphabetical list of scripts in the [**mtexTools**](https://github.com/AzdiarGazder/mtexTools) library



## A
- [**align**](https://github.com/AzdiarGazder/mtexTools/tree/main/align): Align ebsd map data along a user-specified linear fiducial in case of drift caused by the thermal cycling of scanning coil electronics during acquisition. The linear fiducial may correspond to a twin boundary, stacking fault, or any linear-shaped deformation or phase transformation products. Instructions on script use are provided in the window titlebar.



## C
- [**calcGrainsFFT**](https://github.com/AzdiarGazder/mtexTools/tree/main/calcGrainsFFT): Returns the Fast Fourier Transforms (FFTs) of individual grains. Unless
specified otherwise, the FFTs are calculated after padding each grayscale/binary grain map to its nearest square. The FFTs from grayscale and binary data are returned in grid format within the 'grains.prop.fftGray' and 'grains.prop.fftBinary' structure variables.

- [**calcStepSize**](https://github.com/AzdiarGazder/mtexTools/tree/main/calcStepSize): Calculates the step size of the ebsd map. This function also re-calculates the x and y grid values as multiples of the step size to mitigate any rounding-off errors during subsequent gridding operations. To enable the re-calculation of the x and y grid values, the ebsd variable must be outputted from the function.

- [**crop**](https://github.com/AzdiarGazder/mtexTools/tree/main/crop): Crop, cut-out or make a subset of ebsd map data from within a user-specified rectangular, circular, polygonal or freehand area-based region of interest (ROI). Instructions on script use are provided in the window titlebar.

- [**currentFolder**](https://github.com/AzdiarGazder/mtexTools/tree/main/currentFolder): Change MATLAB's current folder to the folder containing this function and add all of its sub-folders to the work path.



## D
- [**dilate**](https://github.com/AzdiarGazder/mtexTools/tree/main/dilate): Dilates the ebsd data surrounding individual, multiple contiguous or multiple discrete grains of interest by one pixel.



## E
- [**ebsd2binary**](https://github.com/AzdiarGazder/mtexTools/tree/main/ebsd2binary): Converts ebsd data of a single grain to a grid of binary ones or zeros.

- [**erode**](https://github.com/AzdiarGazder/mtexTools/tree/main/erode): Erodes the ebsd data surrounding individual grains of interest by one pixel.



- [**euclideanDistance**](https://github.com/AzdiarGazder/mtexTools/tree/main/euclideanDistance): Calculates the 2D Euclidean distance in pixels (default) or map scan units for supported distance methods for each pixel within a grain. The default 2D Euclidean distance measurement is from the grain center to the grain boundary in pixels or map scan units. The 2D Euclidean distance measurement from the grain boundary to the grain center is available but only when specified by the user. The values are returned within the 'ebsd.prop.euclid' structure variable.



## F
- [**fibreMaker**](https://github.com/AzdiarGazder/mtexTools/tree/main/fibreMaker): Creates an ideal crystallographic fibre with a user specified half-width and exports the data as a VPSC file for later use.



## L
- [**lineProfile**](https://github.com/AzdiarGazder/mtexTools/tree/main/lineProfile): Interactively plots an EBSD map property (numeric, logical, or misorientation) profile along a user specified line or linear fiducial.



## O
- [**orientationMaker**](https://github.com/AzdiarGazder/mtexTools/tree/main/orientationMaker): Creates an ideal crystallographic orientation from a unimodal ODF with a user specified half-width and exports the data as a VPSC file for later use.



## P
- [**pad**](https://github.com/AzdiarGazder/mtexTools/tree/main/pad): Pads a binary map with ones or zeros. Options include: (i) Padding to a size based on a user specified [1 x 2] padding array. The padding array defines the number of rows and columns to add to the [(top & bottom) , (left & right)], respectively, of the input map. (ii) Paddding to the nearest square. (iii) Padding automatcially to a size that prevents map data from getting clipped during subsequent map rotation.



## R
- [**recolor**](https://github.com/AzdiarGazder/mtexTools/tree/main/recolor): Recolor phases using the ebsd or grains variables interactively via a GUI or via scripting.

- [**rename**](https://github.com/AzdiarGazder/mtexTools/tree/main/rename): Rename phases using the ebsd or grains variables interactively via a GUI or via scripting.



## S
- [**saveImage**](https://github.com/AzdiarGazder/mtexTools/tree/main/saveImage): Saves all open figures that are located either in separate GUI windows or grouped togther in tabs. The user inputs a file name and the program automatically adds a "__XX_" suffix comprising an underscore symbol and the figure number while saving the various figure(s). 

- [**setInterp2Latex**](https://github.com/AzdiarGazder/mtexTools/tree/main/setInterp2Latex): Changes all MATLAB text interpreters from 'tex' to 'latex' in all subsequent figures, plots, and graphs.

- [**setInterp2Tex**](https://github.com/AzdiarGazder/mtexTools/tree/main/setInterp2Tex): Changes all MATLAB text interpreters from 'latex' to 'tex' in all subsequent figures, plots, and graphs.

- [**split**](https://github.com/AzdiarGazder/mtexTools/tree/main/split): Splits or sub-divides an ebsd map into a regular, rectangular matrix of submaps with a user-specified number of rows and columns. Additional inputs include the ability to overlap a length fraction along both, horizontal and vertical submap directions. The submaps are returned to the main MATLAB workspace as individual ebsd variables. The location of each submap is denoted by the row and column number. For example: ebsd23 = a submap from row 2, column 3 of the ebsd map.

- [**stitch**](https://github.com/AzdiarGazder/mtexTools/tree/main/stitch): Stitch, combine or merge two ebsd maps together into one map by defining a user-specified position and offset/overlay for map 2 relative to map 1.






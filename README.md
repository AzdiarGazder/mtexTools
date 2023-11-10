## UPDATE
![GitHub last commit (branch)](https://img.shields.io/github/last-commit/AzdiarGazder/mtexTools/main)  ![GitHub repo size](https://img.shields.io/github/repo-size/AzdiarGazder/mtexTools)  ![GitHub Discussions](https://img.shields.io/github/discussions/AzdiarGazder/mtexTools)  ![GitHub issues](https://img.shields.io/github/issues/AzdiarGazder/mtexTools)

**For MTEX Version 6.2 (released in September 2023):**
- All scripts are fully functional.
- In case of any errors, please [submit a bug report](https://github.com/AzdiarGazder/mtexTools/issues/new/choose) or [open a discussion](https://github.com/AzdiarGazder/mtexTools/discussions).
- For new function(s) and/or demonstration script(s), please [submit a feature request](https://github.com/AzdiarGazder/mtexTools/issues/new/choose).

---

# [**mtexTools**](https://github.com/AzdiarGazder/mtexTools)
![matlab compatible](https://img.shields.io/badge/matlab-compatible-lightgrey.svg)  ![GitHub top language](https://img.shields.io/github/languages/top/AzdiarGazder/mtexTools)

[**MTEX**](https://mtex-toolbox.github.io/) is a free-to-download [**Matlab**](https://au.mathworks.com/products/matlab.html) toolbox for analysing electron back-scattering diffraction (EBSD) map data. The toolbox is used by researchers from around the world who are interested in script-based microstructure and crystallographic analyses.

MTEX is fully capable of interrogating, processing, and manipulating EBSD map data obtained in several configurations from different OEM vendors. Perhaps its single most powerful characteristic is that the toolbox itself is fully scriptable. This allows users to develop scripts (or codes or programs) to add functionality where needed. It enables a fully customisable analytical experience and unlike commercial OEM software suites, provides for an ever-evolving library of niche capabilities.

This [**mtexTools**](https://github.com/AzdiarGazder/mtexTools) webpage is a collated library of additional MTEX functions and demonstration scripts. Some are original scripts by this author whereas others were gleaned and/or put together from various sources. In the latter case, and while concurrently choosing not to re-invent the wheel, the scripts were modified to either improve on their logic and efficiency or increase their general functionality and usability within MTEX/Matlab. For all such scripts, attributions to the original author are stated in the acknowledgements section of the relevant function. Regardless of their antecedent(s), all scripts in the mtexTools library are directly incorporated into the latest version of MTEX and can be seamlessly and readily used without modification. 

---

## How to cite [**mtexTools**](https://github.com/AzdiarGazder/mtexTools)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.8343432.svg)](https://doi.org/10.5281/zenodo.8343432)  ![GitHub contributors](https://img.shields.io/github/contributors/AzdiarGazder/mtexTools) 

- If these scripts and tools prove useful and contribute to published works in any way, please consider an acknowledgement by citing the following reference:

**A.A. Gazder, mtexTools: A collated library of additional MTEX functions and demonstration scripts, Github, accessed Date-Month-Year, <https://github.com/AzdiarGazder/mtexTools>.**

- If users wish to modify any of these scripts, they are welcome to do so. If modified scripts are redistributed, please include attribution(s) to the original author(s) as a courtesy within the acknowledgements section of the script.

---

## Collaborators
![Static Badge](https://img.shields.io/badge/Collaborators-Welcome!-8A2BE2)

[**Dr Manasij Kumar Yadava**](https://github.com/manasijy) - calcLankford and calcYieldLocus

---

## How to use [**mtexTools**](https://github.com/AzdiarGazder/mtexTools)
![GitHub forks](https://img.shields.io/github/forks/AzdiarGazder/mtexTools)  ![GitHub Repo stars](https://img.shields.io/github/stars/AzdiarGazder/mtexTools)  ![GitHub watchers](https://img.shields.io/github/watchers/AzdiarGazder/mtexTools)  ![GitHub followers](https://img.shields.io/github/followers/AzdiarGazder)  

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

## Alphabetical list of scripts in the [**mtexTools**](https://github.com/AzdiarGazder/mtexTools) library
Labels: ![Static Badge](https://img.shields.io/badge/F-FF0000) = function;  ![Static Badge](https://img.shields.io/badge/D-0000FF) = demonstration script;  ![Static Badge](https://img.shields.io/badge/T-FAAE11) = toolbox; ![Static Badge](https://img.shields.io/badge/M-00FFFF) = MTEX modification; ![Static Badge](https://img.shields.io/badge/C-00FF00) = collaboration

## A
- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**align**](https://github.com/AzdiarGazder/mtexTools/tree/main/align): Align ebsd map data along a user-specified linear fiducial in case of drift caused by the thermal cycling of scanning coil electronics during acquisition. The linear fiducial may correspond to a twin boundary, stacking fault, or any linear-shaped deformation or phase transformation products. Instructions on script use are provided in the window titlebar.



## B
- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**binaryTable**](https://github.com/AzdiarGazder/mtexTools/tree/main/binaryTable): Returns a variable containing all logical combinations for a given number of variables.



## C
- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**calcEaring**](https://github.com/AzdiarGazder/mtexTools/tree/main/calcEaring): This function calculates the height (h) at each peripheral position of a cup drawn from a polycrystalline bcc metal sheet. In the analytical treatment, the polycrystalline sheet is assumed to be an aggregate of single crystals (grains) with various orientations. In the original paper, an orientation distribution function (ODF) contructed from texture data was used to calculate the weight of each single crystal. In this function, ebsd or grain data can be used. For ebsd data, an ODF is first calculated. Following that, there are 2 options: (1) Calculate ODF components & volume fractions using MTEX-default functions, or (2) Calculate the volume fractions of a discretised ODF. For both options, the volume fraction is used as the weight. Alternatively, for grain data, weights are computed using the grain area fraction. The ear may be calculated crystallographically by considering both, restricted glide and pencil glide; with the former returning better predictions in the original paper.

- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**calcGrainsFFT**](https://github.com/AzdiarGazder/mtexTools/tree/main/calcGrainsFFT): Returns the Fast Fourier Transforms (FFTs) of individual grains. The FFTs are calculated after padding each grayscale/binary grain map to its nearest square. The FFTs from grayscale and binary data are returned in grid format within the 'grains.prop.fftGray' and 'grains.prop.fftBinary' structure variables.

- ![Static Badge](https://img.shields.io/badge/F-FF0000) ![Static Badge](https://img.shields.io/badge/C-00FF00) [**calcLankford**](https://github.com/AzdiarGazder/mtexTools/tree/main/calcLankford): This function calculates the minimum Taylor factor (M) and the Lankford coefficient or plastic anisotropy ratio (R-value or r-value) as a function of the angle to the tensile direction (theta). The R-value, is the ratio of the true width strain to the true thickness strain at a particular value of length strain. The normal anisotropy ratio (Rbar, or Ravg, or rm) defines the ability of the metal to deform in the thickness direction relative to deformation in the plane of the sheet. For Rbar values >= 1, the sheet metal resists thinning, improves cup drawing, hole expansion, and other forming modes where metal thinning is detrimental. For Rbar < 1, thinning becomes the preferential metal flow direction, increasing the risk of failure in drawing operations. A related parameter is the planar anisotropy parameter (deltaR) which is an indicator of the ability of a material to demonstrate non-earing behavior. A deltaR value = 0 is ideal for can-making or deep drawing of cylinders, as this indicates equal metal flow in all directions; thus eliminating the need to trim ears during subsequent processing.

- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**calcModelTexture**](https://github.com/AzdiarGazder/mtexTools/tree/main/calcModelTexture): Returns a model ODF based on a user specified number of ideal orientations used as seeds.

- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**calcODFIntensity**](https://github.com/AzdiarGazder/mtexTools/tree/main/calcODFIntensity): Returns the ODF intensity (f(g)) in user-defined steps using Bunge's notation to the variable 'odf.opt.intensity'.

- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**calcStepSize**](https://github.com/AzdiarGazder/mtexTools/tree/main/calcStepSize): Calculates the step size of the ebsd map. This function can also be used in conjunction with the regrid.m script.

- ![Static Badge](https://img.shields.io/badge/F-FF0000) ![Static Badge](https://img.shields.io/badge/C-00FF00) [**calcYieldLocus**](https://github.com/AzdiarGazder/mtexTools/tree/main/calcYieldLocus): This script calculates the yield locus of an orientation set using the equality of external work done with the virtual work via the Taylor model (default and works for all crystal systems), and the Bishop-Hill analysis (works for cubic systems with 24 slip systems only). In the case of the Taylor model, Mtf is calculated as the work done (i.e.- it is the sum of all shears normalised by norm(strainTensor)). Thereafter, for the yield locus, normalisation with the e_11 component is required. In the case of Bishop-Hill (BH) analysis, the script calculates the most appropriate BH stress states for a given external strain using the maximum work principle. The  output M is the maximum work normalised with e_XX. The priniciple of equivalence of external work to the virtual work is utilised to determine the yield locus sections. For e.g. - to determine the sigmaXX - sigmaYY section (where sigmaZZ = 0), the external work is (sigmaXX * eXX) + (sigmaYY * eYY) while the virtual work is W determined from the Taylor or Bishop-Hill methods. Equating both gives equations of straight lines with slopes depending on rho values. The yield locus is the inner envelop of these lines.

- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**checkMTEXVersion**](https://github.com/AzdiarGazder/mtexTools/tree/main/checkMTEXVersion): Compare versions of the current MTEX toolbox to a user-specified version string of the form 'majorVersion.minorVersion.revisionVersion'. Returns true if the current toolbox version is less than the user-specified version string. Returns false if the current toolbox version is greater than the user-specified version string.

- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**crop**](https://github.com/AzdiarGazder/mtexTools/tree/main/crop): Crop, cut-out or make a subset of ebsd map data from within a user-specified rectangular, circular, polygonal or freehand area-based region of interest (ROI). Instructions on script use are provided in the window titlebar.

- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**currentFolder**](https://github.com/AzdiarGazder/mtexTools/tree/main/currentFolder): Change MATLAB's current folder to the folder containing this function and add all of its sub-folders to the work path.



## D
- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**dilate**](https://github.com/AzdiarGazder/mtexTools/tree/main/dilate): Dilates the ebsd data surrounding individual, multiple contiguous or multiple discrete grains of interest by one pixel.

- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**discreteColormap**](https://github.com/AzdiarGazder/mtexTools/tree/main/discreteColormap): Sub-divides a default colormap palette into a user specified number of discrete colors to improve on the visual distinction between bins/levels.



## E
- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**ebsd2binary**](https://github.com/AzdiarGazder/mtexTools/tree/main/ebsd2binary): Converts ebsd data of a single grain to a grid of binary ones or zeros.

- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**erode**](https://github.com/AzdiarGazder/mtexTools/tree/main/erode): Erodes the ebsd data surrounding individual grains of interest by one pixel.

- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**euclideanDistance**](https://github.com/AzdiarGazder/mtexTools/tree/main/euclideanDistance): Calculates the 2D Euclidean distance in pixels (default) or map scan units for supported distance methods for each pixel within a grain. The default 2D Euclidean distance measurement is from the grain center to the grain boundary in pixels or map scan units. The 2D Euclidean distance measurement from the grain boundary to the grain center is available but only when specified by the user. The values are returned within the 'ebsd.prop.euclid' structure variable.

- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**exportCRC**](https://github.com/AzdiarGazder/mtexTools/tree/main/exportCRC): Exports input EBSD map orientation data in any vendor format to proprietary Oxford Instruments HKL Channel 5 *.cpr and *.crc output file format.



## F
- ![Static Badge](https://img.shields.io/badge/D-0000FF) [**ferriteQuantifier**](https://github.com/AzdiarGazder/mtexTools/tree/main/ferriteQuantifier): This script demonstrates how to automatically segment and quantify the area fractions of various ferrite microconstituents in EBSD maps of steel grades produced by the CASTRIP(R) process. The three ferrite microconstituents namely, (1) acicular ferrite, (2) polygonal ferrite and (3) bainite, significantly influence the mechanical properties of steel. They are distinguished using the grain aspect ratio, grain boundary misorientation angle, grain average misorientation and grain size criteria.

- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**fibreMaker**](https://github.com/AzdiarGazder/mtexTools/tree/main/fibreMaker): Creates an ideal crystallographic fibre with a user specified half-width and exports the data as a lossless MATLAB *.mat* file object for later use.

- ![Static Badge](https://img.shields.io/badge/D-0000FF) [**fibreOrientations**](https://github.com/AzdiarGazder/mtexTools/tree/main/fibreOrientations): This script demonstrates how to obtain and plot orientations from a crystallographic fibre.



## G
- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**GAM**](https://github.com/AzdiarGazder/mtexTools/tree/main/GAM): By modifying MTEX's in-built KAM script, this function calculates the intragranular grain average misorientation. The first neighbour kernal average misorientation is averaged to return a single value per grain.

- ![Static Badge](https://img.shields.io/badge/D-0000FF) [**grainGrowth_phaseField**](https://github.com/AzdiarGazder/mtexTools/tree/main/grainGrowth_phaseField): This phase-field simulation script demonstrates 2D grain growth using the Allen-Cahn equation for non-conserved order parameters based on a continuum field model by Fan and Chen.

- ![Static Badge](https://img.shields.io/badge/T-FAAE11) [**grainSizeToolbox**](https://github.com/AzdiarGazder/mtexTools/tree/main/grainSizeToolbox): GrainSizeTools is a free, open-source, cross-platform script written in Python and maintained by Dr Marco A. Lopez-Sanchez. This toolbox replicates the data analysis and plots in GrainSizeTools for a MATLAB and MTEX -based environmment by providing tools for: (1) describing and visualising grain size populations, and (2) applying stereology methods to approximate the 3D distribution of grain size from thin sections.


## H
- ![Static Badge](https://img.shields.io/badge/D-0000FF) [**hex2Square**](https://github.com/AzdiarGazder/mtexTools/tree/main/hex2Square): This script demonstrates how to automatically convert from a hexagonal grid ebsd map in TSL OIM's *.ang format to a square grid ebsd map in Oxford Instruments HKL Channel-5 *.cpr and *.crc format.



## I
- ![Static Badge](https://img.shields.io/badge/D-0000FF) [**idealFibres**](https://github.com/AzdiarGazder/mtexTools/tree/main/idealFibres): This script demonstrates how to plot user-defined pole figures and orientation distribution function sections (and 3D ODFs) of common ideal fibres for bcc, fcc and hcp materials.

- ![Static Badge](https://img.shields.io/badge/D-0000FF) [**idealOrientations**](https://github.com/AzdiarGazder/mtexTools/tree/main/idealOrientations): This script demonstrates how to plot user-defined pole figures and orientation distribution function sections of common ideal orientations for bcc, fcc and hcp materials.
 
- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**imageResize**](https://github.com/AzdiarGazder/mtexTools/tree/main/imageResize): Interactively resize an image. This function may be used in conjunction with ebsd map data to correct for drift during map acquisition.

- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**imageTransform**](https://github.com/AzdiarGazder/mtexTools/tree/main/imageTransform): Interactively projective or affine transform an image. This function may be used in conjunction with ebsd map data to correct for drift during map acquisition.



## J
- ![Static Badge](https://img.shields.io/badge/D-0000FF) [**jeolOI2Mtex**](https://github.com/AzdiarGazder/mtexTools/tree/main/jeolOI2Mtex): A set of three scripts to be run successively that enables novice users to find the settings needed to successfully and routinely import thair ebsd map data (collected using a combination of a JEOL scanning electron microscope (SEM) and Oxford Instruments (OI) EBSD(+EDS) system) into MTEX. This tool enables users to plot the ebsd orientation + spatial data and crystallographic texture in Mtex in formats that exactly match the output from OI Channel-5 and Aztec Crystal.



## K
- ![Static Badge](https://img.shields.io/badge/D-0000FF) [**kamSegmenter**](https://github.com/AzdiarGazder/mtexTools/tree/main/kamSegmenter): This script demonstrates how to automatically segment and quantify the area fractions of granular bainite and polygonal ferrite in EBSD maps of steel grades using the critical kernel average misorientation (KAM) criterion.



## L
- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**lineProfile**](https://github.com/AzdiarGazder/mtexTools/tree/main/lineProfile): Interactively plots an EBSD map property (numeric, logical, or misorientation) profile along a user specified line or linear fiducial.



## M
- ![Static Badge](https://img.shields.io/badge/D-0000FF) [**mergeTwins**](https://github.com/AzdiarGazder/mtexTools/tree/main/mergeTwins): This script demonstrates how to correctly separate grains with and without twins and how to correctly merge grains containing twins.

- ![Static Badge](https://img.shields.io/badge/M-00FFFF) [**mtexStatistics**](https://github.com/AzdiarGazder/mtexTools/tree/main/mergeTwins): This script modifies the MTEX distribution to return the mean, median and mode values for all classes and object types.



## N
- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**nestedLoopCounter**](https://github.com/AzdiarGazder/mtexTools/tree/main/nestedLoopCounter): Returns the current count (or specifically, the row index) for a series of running nested loops. The function currently employs two and three nested loops but can be extended to multiple nested loops.


## O
- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**orientationMaker**](https://github.com/AzdiarGazder/mtexTools/tree/main/orientationMaker): Creates an ideal crystallographic orientation from a unimodal ODF with a user specified half-width and exports the data as a lossless MATLAB *.mat* file object for later use.



## P
- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**pad**](https://github.com/AzdiarGazder/mtexTools/tree/main/pad): Pads a binary map with ones or zeros. Options include: (i) Padding to a size based on a user specified [1 x 2] padding array. The padding array defines the number of rows and columns to add to the [(top & bottom) , (left & right)], respectively, of the input map. (ii) Paddding to the nearest square. (iii) Padding automatcially to a size that prevents map data from getting clipped during subsequent map rotation.

- ![Static Badge](https://img.shields.io/badge/D-0000FF) [**plotCAxis**](https://github.com/AzdiarGazder/mtexTools/tree/main/plotCAxis): This script demonstrates how to plot the angle between the c-axis of the hexagonal unit cell and a macroscopic specimen axis.

- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**plotHODF**](https://github.com/AzdiarGazder/mtexTools/tree/main/plotHODF): Plots orientation distribution function phi2 sections in publication-ready format.

- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**plotHPF**](https://github.com/AzdiarGazder/mtexTools/tree/main/plotHPF): Plots pole figures in publication-ready format.

- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**plotMarker**](https://github.com/AzdiarGazder/mtexTools/tree/main/plotMarker): Plots a line-plot using customisable markers. The function uses line plotting options similar to MATLAB's "plot" command but applies custom patches instead of MATLAB's in-built marker set.

- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**plotScatter**](https://github.com/AzdiarGazder/mtexTools/tree/main/plotScatter):  Creates a scatter plot coloured by density.



## R
- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**randomEuler**](https://github.com/AzdiarGazder/mtexTools/tree/main/randomEuler): Generate uniformly distributed random Euler angles (φ1, φ, φ2) in the form of orientations, quaternions or rotation matrices.

- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**recolor**](https://github.com/AzdiarGazder/mtexTools/tree/main/recolor): Recolor phases using the ebsd or grains variables interactively via a GUI or via scripting.

- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**regrid**](https://github.com/AzdiarGazder/mtexTools/tree/main/regrid): Re-calculates the x and y grid values as multiples of the step size to mitigate any rounding-off errors during subsequent gridding operations. This function can be used in conjunction with the calcStepSize.m script.

- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**rename**](https://github.com/AzdiarGazder/mtexTools/tree/main/rename): Rename phases using the ebsd or grains variables interactively via a GUI or via scripting.

- ![Static Badge](https://img.shields.io/badge/F-FF0000) ![Static Badge](https://img.shields.io/badge/M-00FFFF) [**replaceText**](https://github.com/AzdiarGazder/mtexTools/tree/main/replaceText): Enables users to edit by replacing or changing the first or all instances of a full line of text in a text-based file. This is especially useful if small changes are needed on-the-fly to function files in publicly released toolboxes (like MTEX).



## S
- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**saveImage**](https://github.com/AzdiarGazder/mtexTools/tree/main/saveImage): Saves all open figures that are located either in separate GUI windows or grouped togther in tabs. The user inputs a file name and the program automatically adds a "__XX_" suffix comprising an underscore symbol and the figure number while saving the various figure(s). 

- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**setInterp2Latex**](https://github.com/AzdiarGazder/mtexTools/tree/main/setInterp2Latex): Changes all MATLAB text interpreters from 'tex' to 'latex' in all subsequent figures, plots, and graphs.

- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**setInterp2Tex**](https://github.com/AzdiarGazder/mtexTools/tree/main/setInterp2Tex): Changes all MATLAB text interpreters from 'latex' to 'tex' in all subsequent figures, plots, and graphs.

- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**split**](https://github.com/AzdiarGazder/mtexTools/tree/main/split): Splits or sub-divides an ebsd map into a regular, rectangular matrix of submaps with a user-specified number of rows and columns. Additional inputs include the ability to overlap a length fraction along both, horizontal and vertical submap directions. The submaps are returned to the main MATLAB workspace as individual ebsd variables. The location of each submap is denoted by the row and column number. For example: ebsd23 = a submap from row 2, column 3 of the ebsd map.

- ![Static Badge](https://img.shields.io/badge/F-FF0000) [**stitch**](https://github.com/AzdiarGazder/mtexTools/tree/main/stitch): Stitch, combine or merge two ebsd maps together into one map by defining a user-specified position and offset/overlay for map 2 relative to map 1.






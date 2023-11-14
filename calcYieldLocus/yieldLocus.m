% Yield locus:
% A yield locus, in the context of materials science, crystallography, and
% crystal plasticity, is a graphical representation that defines the stress 
% states at which an alloy undergoes plastic deformation. It provides 
% critical information on the alloy's mechanical behavior by cataloging how
% different grain orientations within a polycrystalline material respond 
% various external loading conditions.
% 
% Mathematically, the yield locus is defined in terms of the stress 
% components acting on the material. For a typical three-dimensional stress
% space (σ₁, σ₂, σ₃), the yield condition can be expressed as an 
% inequality:
% f(σ₁, σ₂, σ₃) ≤ 0
% where 'f' is a yield function that encapsulates the material's behavior. 
%
% To determine the yield locus experimentally, several tests are typically 
% required. The position of tests on the yield locus is determined by the
% specific stress or strain conditions imposed, the magnitude of the 
% applied stress or strain tensors relative to the crystallographic axes or
% other reference frames, and the crystallographic orientations 
% of the underlying material. For example:
% * Uniaxial tension or compression: This test applies a uniaxial tensile 
% or compressive load along one axis but in opposite directions. 
% Consequently, on the yield locus, uniaxial tension and compression are 
% located at 0 and 180 degrees, respectively.
%
% * Simple shear: This test involves applying shear stresses along one axis
% while keeping the other axes stress-free. It is located at 45, 135, 225 
% and 315 degrees (counter-clockwise) on the yield locus.
%
% * Biaxial tension or compression: These tests involve applying loads 
% along two orthogonal axes. On the yield locus, they are located at 
% specific intersections corresponding to the combination of tension and 
% compression directions. The applied stress tensors are more complex 
% compared to uniaxial tests, leading to different positions on the yield 
% locus.To provide an example, on the yield locus, the equibiaxial tension 
% and compression tests are located at the intersection of the tension or 
% compression axes (at 0 and 180 degrees, respectively) and the shear axes 
% (at 45, 135, 225 and 315 degrees).
%
% * Plane strain compression: Here the applied stress tensor accounts for 
% both, compression and shear components. On the yield locus, this test is 
% located between uniaxial compression at 180 degrees and simple shear at 
% 135 and 225 degrees (counter-clockwise). 
%
% * Axial torsion: This test combines axial tension with torsional loading.
% It is located in the tension-shear region, not on the primary axes of the
% yield locus. The applied stress tensor has components in both tension and
% shear directions.
%
% The yield locus can be modelled using various methods as follows:
% * Analytical models: These include: (i) von Mises and (ii) Tresca 
% yield criteria. The von Mises yield criterion assumes that yielding 
% occurs when the von Mises equivalent stress exceeds a critical value and 
% is applied to isotropic materials. ​The Tresca yield criterion is also 
% known as the maximum shear stress criterion, posits that yielding occurs 
% when the maximum shear stress exceeds a critical value. 
% 
% * Polycrystal plasticity models: These include: (i) crystal plasticity - 
% finite element (CPFEM), and (ii) viscoplastic self-consistent (VPSC)
% models. CPFEM modelling combines the finite element method with crystal 
% plasticity theory by discretising a polycrystalline material into smaller
% elements, with each element representing a single grain or crystal. The 
% orientation and deformation of each crystal is subsequently tracked to 
% predict overall macroscopic behaviour via single crystal constituive or 
% homogenisation approaches. The VPSC model considers the interactions 
% between individual grains or crystals and a homologous effective medium 
% (comprising all other grains in the polycrystalline aggregate) subjected 
% to an externally imposed load, to calculate the effective behavior of 
% the material.
%
% * Texture-based models: These include: (i) Taylor modelling, and (ii) 
% Hill's yield function. Based on Taylor's assumption of ideal plastic 
% behaviour, the Taylor model provides a framework for predicting yield 
% behaviour based on crystallographic texture. Conseuqently, it relates the 
% macroscopic behavior of a polycrystalline material to the distribution of
% individual constituent grain orientations. Hill's yield function is an 
% extension of the von Mises criterion for anisotropic materials. It 
% incorporates the effects of texture and anisotropy in predicting 
% yielding.
%
% With respect to MTEX, the Taylor model is used to model the yield locus.
% In this regard, the Taylor factor (M) represents the ease with which 
% deformation proceeds along a specific crystallographic direction. 
% It is nominally defined as the ratio of the actual plastic work done to 
% the work done if the material deformed in an ideal isotropic manner.
% In the context of the yield locus, M is calculated as the work done 
% (i.e.- it is the sum of all shears normalised by norm(strainTensor)). 
% Thereafter, for the yield locus, M is normalised with the ε11 component. 
% The latter normalisation in the context of the Taylor model is done to 
% ensure that the yield locus is independent of the overall scale of 
% deformation. It ensures:
% * Consistency in deformation measures: Normalising by ε11​ ensures that 
% the Taylor factor remains dimensionless, is consistent with the 
% definition of strain in the material and is directly interpretable in 
% terms of strain with respect to shape changes.
% 
% * Scale-invariance of the yield locus: The yield locus is guaranteed to 
% be independent of the overall scale of deformation applied to a material.
% 
% * Comparability across different materials and loading conditions: 
% Normalising by ε11​ enables meaningful comparisons of the yield loci 
% between different materials, regardless of their specific mechanical 
% properties or initial states.
% 
% * Physical interpretability: Normalising by ε11​​ provides a clear physical
% interpretation representing the specific resistance to deformation along 
% a particular crystallographic direction, relative to the overall strain
% applied to a material.

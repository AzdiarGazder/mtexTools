home; close all; clear variables;

%% Demo PAG recontruction script downloaded from: https://mtex-toolbox.github.io/GrainGraphBasedReconstruction.html
% load the data
mtexdata martensite
plotx2east

% grain reconstruction
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'), 'angle', 3*degree);
% remove small grains
ebsd(grains(grains.grainSize < 3)) = [];
% re-identify grains with small grains removed:
[grains,ebsd.grainId] = calcGrains(ebsd('indexed'),'angle',3*degree);
grains = smooth(grains,5);

% set up the job
job = parentGrainReconstructor(ebsd,grains);
% initial guess for the parent-child orientation relationship
job.p2c = orientation.KurdjumovSachs(job.csParent, job.csChild)
% optimizing the parent-child orientation relationship
job.calcParent2Child

% compute the misfit for all child to child grain neighbours
[fit,c2cPairs] = job.calcGBFit;
% select grain boundary segments by grain ids
[gB,pairId] = job.grains.boundary.selectByGrainId(c2cPairs);

% graph based parent grain reconstruction
job.calcGraph('threshold',2.5*degree,'tolerance',2.5*degree);
% cluster the graph into components using the Markovian clustering algorithm
job.clusterGraph('inflationPower',1.6)
% compute parent orientations
job.calcParentFromGraph

% calcParentFromGraph has two additional outputs. 
% 1. job.grains.fit = The misorientation angle between the reconstructed 
% parent orientation of each child grain and the mean parent orientation of
% the corresponding parent grain.
% 2. job.grains.clusterSize = the size of each cluster.
% Use these properties to revert poorly reconstructed parent grains
job.revert(job.grains.fit > 5*degree | job.grains.clusterSize < 15)

% to fill the holes corresponding to the remaining child grains created by 
% the previous step, use the misorientations to already reconstructed 
% neighbouring parent grains. Each of these misorientations, a vote is 
% assigned for a certain parent orientation. 
% Choose the parent orientation that gets the most votes. 
for k = 1:3 % do this three times
  % compute votes
  job.calcGBVotes('p2c','threshold', k * 2.5*degree);
  % compute parent orientations from votes
  job.calcParentFromVote
end


% merge grains with similar orientation
job.mergeSimilar('threshold',7.5*degree);
% merge small inclusions
job.mergeInclusions('maxSize',50);
%%


pcGrainSizes = nan(1,2);
for ii = 1:max(job.parentGrains.id)

    % Define the parent grain
    pGrain = job.parentGrains(job.parentGrains.id == ii);
    % Define the child grain(s)
    clusterGrains = job.grainsPrior(job.mergeId == ii);
    cGrains = clusterGrains(job.csChild);

    if ~isempty(pGrain)
        pcGrainSizes = [pcGrainSizes; [repmat(pGrain.grainSize,size(cGrains.grainSize)), cGrains.grainSize]];
    end
end
pcGrainSizes(1,:) = [];


figure;
h1 = plotScatter(pcGrainSizes(:,1),10.^(pcGrainSizes(:,2)/256),'log','bins',[100 10],'type','contour','filled','linewidth',1.5);
h1_xLim = h1.XLim; h1_yLim = h1.YLim;
hold all;
h2 = plotScatter(pcGrainSizes(:,1),10.^(pcGrainSizes(:,2)/256),'log','bins',[100 10],'type','scatter','MarkerFaceColor',[0.67 0.67 0.67],'linewidth',1);
xlim(h1_xLim); ylim(h1_yLim);
hold off;
xlabel('Parent Grains [um]'); ylabel('Child grains [um]');

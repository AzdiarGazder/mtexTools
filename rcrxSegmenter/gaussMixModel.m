function out = gaussMixModel(inData,varargin)

numClusters = get_option(varargin,'clusters',2);
type = get_option(varargin,'type','hard');
threshold = get_option(varargin,'threshold',[0.4 0.6]);
flagPlot = check_option(varargin,'plot');

if size(threshold,2) ~= 2
    error('Incorrect threshold specified. [1 x 2] @double is required.');
end

% set the random seed for data reproducibility
rng(3);

% Define the size of the data
[n,p] = size(inData);

switch(type)
    case 'hard'
        % ------
        % HARD CLUSTERING
        % https://au.mathworks.com/help/stats/cluster-data-from-mixture-of-gaussian-distributions.html
        options = statset('MaxIter',1E3);
        gm = fitgmdist(inData,numClusters,'Start','plus','Options',options);

        % Partition the data into clusters by passing the fitted GMM and
        % the data to cluster
        % The "cluster" function implements "hard clustering", a method
        % that assigns each data point to exactly one cluster (or mixture
        % components in the GMM).
        % The center of each cluster is the corresponding mixture component
        % mean.
        idx = cluster(gm,inData);
        for ii = 1:numClusters
            field = ['cluster',num2str(ii)];
            out.(field) = (idx == ii); % assign logical matrices to
            % cluster membership
        end

        % Assign cluster membership posterior probabilities for each point
        out.prob = posterior(gm,inData);
        % ------

    case 'soft'
        %% ------
        % SOFT CLUSTERING
        % https://au.mathworks.com/help/stats/cluster-gaussian-mixture-data-using-soft-clustering.html
        options = statset('MaxIter',1E3);
        gm = fitgmdist(inData,numClusters,'Start','plus','Options',options);

        % Estimate component-member posterior probabilities for all data
        % points using the fitted GMM gm. These represent cluster
        % membership scores.
        P = posterior(gm,inData);

        % For each cluster, rank the membership scores for all data points
        [~,order] = sort(P(:,1));

        if flagPlot
            figure
            legendText = {};
            ax = nexttile;
            for ii = 1: numClusters
                plot(1:n, P(order,ii),'-','lineWidth',2);
                hold all;
                legendText{ii} = ['cluster',num2str(ii)];
            end
            hold off;
            C = colororder;
            legend(legendText,'Location','best');
            ylabel('Cluster membership score');
            xlabel('Point ranking');
            title('GMM with full unshared covariances');
        end

        % Identify points that could be in either cluster
        idx = cluster(gm,inData);
        idxBoth = find(P(:,1) >= threshold(1) & P(:,1) <= threshold(2));
        numInBoth = numel(idxBoth);


        % Using the score threshold interval, several data points can be
        % in either cluster.
        %
        % Soft clustering using a GMM is similar to fuzzy k-means
        % clustering, which also assigns each point to each cluster with a
        % membership score.
        %
        % The fuzzy k-means algorithm assumes that clusters are roughly
        % spherical in shape, and all of roughly equal size.
        %
        % This is comparable to a Gaussian mixture distribution with a
        % single covariance matrix that is shared across all components,
        % and is a multiple of the identity matrix.
        %
        % In contrast, gmdistribution allows you to specify different
        % covariance structures.
        %
        % The default is to estimate a separate, unconstrained covariance
        % matrix for each component. A more restricted option, closer to
        % k-means, is to estimate a shared, diagonal covariance matrix.

        % Fit a GMM to the data, but specify that the components share the
        % same diagonal covariance matrix.
        %
        % This specification is similar to implementing fuzzy k-means
        % clustering, but provides more flexibility by allowing unequal
        % variances for different variables.
        gmSharedDiag = fitgmdist(inData,numClusters,'CovType','Diagonal', ...
            'SharedCovariance',true');

        % Estimate component-member posterior probabilities for all data
        % points using the fitted GMM gmSharedDiag
        % Estimate soft cluster assignments
        [idxSharedDiag,~,PSharedDiag] = cluster(gmSharedDiag, inData);
        idxBothSharedDiag = find(PSharedDiag(:,1)>=threshold(1) & ...
            PSharedDiag(:,1)<=threshold(2));
        numInBoth = numel(idxBothSharedDiag);

        % Assuming shared, diagonal covariances among components, numInBoth number
        % of data points could be in either cluster.
        % For each cluster:
        % - Rank the membership scores for all data points.
        % - Plot each data points membership score with respect to its ranking
        %   relative to all other data points.
        [~,orderSharedDiag] = sort(PSharedDiag(:,1));

        if flagPlot
            figure
            legendText = {};
            ax = nexttile;
            for ii = 1: numClusters
                plot(1:n, PSharedDiag(orderSharedDiag,ii),'-','lineWidth',2);
                hold all;
                legendText{ii} = ['cluster',num2str(ii)];
            end
            hold off;
            colororder(ax,C);
            legend(legendText,'Location','best');
            ylabel('Cluster membership score');
            xlabel('Point ranking');
            title('GMM with full unshared covariances');
        end

        for ii = 1:numClusters
            field = ['cluster',num2str(ii)];
            out.(field) = (idxSharedDiag == ii); % assign logical matrices
            % to cluster membership
        end

        % Assign a logical matrix to values common to all clusters
        out.common = false(size(inData,1),1);
        out.common(idxBothSharedDiag) = true;

        % Assign cluster membership posterior probabilities for each point
        out.prob = P;

    otherwise
        error('Incorrect clustering method specified. Options are: ''hard'' or ''soft''.');

end

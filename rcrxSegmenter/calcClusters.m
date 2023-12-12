function out = calcClusters(inData,varargin)
%% Function description:
% This function is a simple implementation of Gaussian Mixture Modelling 
% used for hard clustering. 
%
%% Modified by:
% Dr. Azdiar Gazder, 2023, azdiaratuowdotedudotau
%
%% Author: 
% Dr. George Azzopardi
% University of Malta
% CSA3220 - Machine Learning, Expert Systems, & Fuzzy Logic
% For the script published in the MATLAB file exchange:
% https://au.mathworks.com/matlabcentral/fileexchange/54568-clustering-with-gaussian-mixture-models-gmms
%
%% Syntax:
%  calcClusters(data)
%
%% Input:
%  data         - @double, a n x 1 array
%
%% Options:
%  'clusters'   - @double, defines the number of clusters
%  'tolerance'  - @char, defines the error tolerance for convergence
%
%%


numClusters = get_option(varargin,'clusters',2);
errTol = get_option(varargin,'tolerance',1E-6);


[ro, col] = size(inData); % size of the input data array

%% Step 1 - initialise the mean(s) with k-means
[labels,mu] = kmeans(inData,numClusters);

% Compute weights and covariance matrices using maximum likelihood
% estimation (MLE)
% weight = zeros(numClusters); sigma = cell(numClsuters);
for kk = 1:numClusters
    weight(kk) = sum(labels == kk) / ro;
    sigma{kk} = cov(inData(labels == kk, :));
end


post = zeros(ro,numClusters);
t = 1; convergence = 0;

while t == 1 || ~convergence % convergence criteria
    %% Step 2: Expectation - Compute posteriors of each cluster
    for nn = 1:ro
        for kk = 1:numClusters
            post(nn,kk) = weight(kk) * mvnpdf(inData(nn,:), mu(kk,:), sigma{kk}); % calculate posterior
        end
        post(nn,:) = post(nn,:)./ sum(post(nn,:));
    end

    %% Step 3: Maximisation - Update model parameters (means, covariance
    % matrices and weights
    for kk = 1:numClusters
        % Update the means
        sp(kk) = sum(post(:,kk));
        mu(kk,:) = sum(bsxfun(@times, post(:,kk), inData)) / sp(kk);

        % Update the covariance matrices
        sigma{kk} = zeros(col,col);
        for nn = 1:ro
            sigma{kk} = sigma{kk} + post(nn,kk) *...
                (inData(nn,:) - mu(kk,:))' *...
                (inData(nn,:) - mu(kk,:));
        end
        sigma{kk} = sigma{kk}./sp(kk);
    end
    
    % Update the weights
    weight = sp./sum(sp);

    %% Step 4: Evaluation - Compute log likelihood
    llh(t) = 0;
    for ii = 1:ro
        innerTerm = 0;
        for kk = 1:numClusters
            innerTerm = innerTerm + (weight(kk) * mvnpdf(inData(ii,:), mu(kk,:), sigma{kk}));
        end
        llh(t) = llh(t) + log(innerTerm);
    end
    llh(t) = llh(t) / ro;

    if t > 1
        convergence = (llh(t) - llh(t-1)) < errTol;
    end
    t = t + 1;
end

%% Step 5: Assemble the output
out.model.means = mu;
out.model.covariances = sigma;
out.model.weights = weight;
out.model.prob = post;

% Assign cluster membership to posterior probabilities for each point
[~,labels] = max(post,[],2);
for ii = 1:numClusters
    field = ['c',num2str(ii)];
    out.cluster.(field) = (labels == ii); % assign logical matrices to
                                          % cluster membership
end
% ------

end
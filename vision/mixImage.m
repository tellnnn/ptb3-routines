function img = mixImage(X, Y, params)
% mixImage mix two images.
%  img = mixImage(X, Y, [name-value pairs])
%    mix two images with specified parameters.
%
%  Input:
%    X: one image with values between -1 and 1 in size (res, res)
%    Y: one image with values between -1 and 1 in size (res, res)
%    params: name-value pairs
%      - weight: mixing ratio (0 to 1: default 0.5)
%      - method: mixing method ('replace', 'weighed': default 'replace')
%          With 'replace', a certain number of pixels in X are replaced with Y.
%          With 'weighted', X and Y are mixed with the specified weight.
%      - mask: mask image (default: a logical image of the same size as X and Y)
%          Only for 'replace' method.
%          If mask is not specified, all pixels are subject to replacement.
%          If mask is specified, only the pixels in the mask are subject to replacement.
%
%  Output:
%    img: mixed image with values between -1 and 1 in size (res, res)
%
%  Example:
%    img = mixImage(X, Y);
%    img = mixImage(X, Y, 'weight', 0.7);
%    img = mixImage(X, Y, 'method', 'weighted');

arguments (Input)
    X (:,:) double {mustBeInRange(X, -1, 1)} % image to be mixed
    Y (:,:) double {mustBeInRange(Y, -1, 1)} % image to be mixed
    params.weight (1,1) double {mustBeInRange(params.weight, 0, 1)} = 0.5 % mixing ratio (0 to 1: default 0.5)
    params.method (1,1) string {mustBeMember(params.method, {'replace', 'weighted'})} = 'replace' % mixing method (default: 'replace')
    params.mask (:,:) logical = [] % mask image (default: [])}
end

arguments (Output)
    img (:,:) double {mustBeInRange(img, -1, 1)} % mixed image with values between -1 and 1 in the same size as X and Y
end


assert(all(size(X) == size(Y)), 'Image X and Y must be in the same size');

switch params.method
    case 'replace'
        % If mask is not specified, create a logical image of the same size as X and Y
        % with all pixels set to true.
        if isempty(params.mask)
            params.mask = true(size(X));
        end
        
        ind = find(params.mask); % linear index of pixels can be replaced

        n = numel(ind); % the number of pixels can be replaced
        m = round(n * (1 - params.weight)); % the number of pixels to be replaced
        ind = ind(randperm(n, m)); % linear index of pixels to be replaced
        img = X;
        img(ind) = Y(ind);
    case 'weighted'
        img = params.weight * X + (1 - params.weight) * Y;
end

end
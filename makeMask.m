function img = makeMask(params)
% makeMask creates a mask image.
%  img = makeMask([name-value pairs])
%    creates a mask image with specified parameters.
%
%  Input:
%    params: name-value pairs
%      - res: resolution of the image (default 256)
%      - type: type of mask ('ramp', 'circle', 'gauss': default 'gauss')
%      - radius: radius of the mask in fraction of the image size (default 1.0)
%          Only for 'circle' type.
%          If the output image is supposed to be presented as 10-degree image,
%          the radius in degrees will be 'radius' x 10.
%      - sigma: standard deviation of the Gaussian in fraction of the image size (default 0.3)
%          Only for 'gauss' type.
%          If the output image is supposed to be presented as 10-degree image,
%          the sigma in degrees will be 'sigma' x 10.
%
%  Output:
%    img: mask image with values between 0 and 1 in size (res, res)
%
%  Example:
%    img = makeMask('type', 'ramp');
%    img = makeMask('type', 'circle', 'radius', 0.5);
%    img = makeMask('type', 'gauss', 'sigma', 0.3);
%    
%  History:
%    2025-04-26: Created by Teruaki Kido under MATLAB R2024b.

arguments (Input)
    params.res (1,1) double {mustBePositive} = 256 % resolution of the image (default 256)
    params.type (1,1) string {mustBeMember(params.type, {'ramp', 'circle', 'gauss'})} = 'gauss' % type of mask (default 'gauss')
    params.radius (1,1) double {mustBeInRange(params.radius, 0, 1)} = 1.0 % radius of the mask in fraction of the image size (default 1.0)
    params.sigma (1,1) double {mustBePositive} = 0.3 % standard deviation of the Gaussian in fraction of the image size (default 0.3)
end

arguments (Output)
    img (:,:) double {mustBeInRange(img, 0, 1)} % mask image with values between 0 and 1 in size (res, res)
end

res = params.res;

[x, y] = meshgrid(1:res, 1:res);
% center the origin
x = x - (res+1)/2;
y = y - (res+1)/2;
% normalize to [-1, 1]
x = x / ((res-1)/2);
y = y / ((res-1)/2);
% calculate distance from center (0,0)
D = sqrt(x.^2 + y.^2);

switch params.type
    case 'ramp'
        img = 1 - D;
        img(D > 1) = 0;
    case 'circle'
        img = double(D <= params.radius);
    case 'gauss'
        img = exp(- D.^2 / (2 * params.sigma^2));
end

end
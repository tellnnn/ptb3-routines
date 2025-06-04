function img = makeGabor(res, gratingParams, maskParams)
% makeGabor creates a Gabor image by combining a grating and a mask.
%  img = makeGabor(res, [name-value pairs])
%    creates a Gabor image with specified grating and mask parameters.
%
%  Input:
%    res: resolution of the image (default 256)
%    gratingParams: see makeGrating function for details
%    maskParams: see makeMask function for details
%
%  Output:
%    img: Gabor image with values between -1 and 1 in size (res, res)
%
%  Example:
%    img = makeGabor;
%    img = makeGabor(512);
%    img = makeGabor(512, 'ori', -45);
%    
%    diameter = 10; % diameter of Gabor in degree 
%    freq = 1; % spatial frequency in degree
%    sigma = 2.5; % standard deviation of Gaussian window in degree
%    img = makeGabor('freq', freq * diameter, 'sigma', sigma / diameter);
%
%  History:
%    2025-04-26: Created by Teruaki Kido under MATLAB R2024b.

arguments (Input)
    res (1,1) double {mustBePositive} = 256 % resolution of the image (default 256)

    gratingParams.ori (1,1) double = 0 % orientation in degrees (0 indicates vertical: default 0)
    gratingParams.freq (1,1) double {mustBePositive} = 1 % frequency in cycles per degree (default 1)
    gratingParams.phase (1,1) double = 0 % phase in degrees (default 0)
    gratingParams.contrast (1,1) double {mustBeInRange(gratingParams.contrast, 0, 1)} = 1 % contrast (0 to 1: default 1)

    maskParams.type (1,1) string {mustBeMember(maskParams.type, {'ramp', 'circle', 'gauss'})} = 'gauss' % type of mask (default 'gauss')
    maskParams.radius (1,1) double {mustBeInRange(maskParams.radius, 0, 1)} = 1.0 % radius of the mask in fraction of the image size (default 1.0)
    maskParams.sigma (1,1) double {mustBePositive} = 0.3 % standard deviation of the Gaussian in fraction of the image size (default 0.3)
end

arguments (Output)
    img (:,:) double {mustBeInRange(img, -1, 1)} % Gabor image with values between -1 and 1 in size (res, res)
end

ori = gratingParams.ori;
freq = gratingParams.freq;
phase = gratingParams.phase;
contrast = gratingParams.contrast;
grating = makeGrating('res', res, 'ori', ori, 'freq', freq, 'phase', phase, 'contrast', contrast);

type = maskParams.type;
radius = maskParams.radius;
sigma = maskParams.sigma;
gauss = makeMask('res', res, 'type', type, 'radius', radius, 'sigma', sigma);

img = grating .* gauss;

end
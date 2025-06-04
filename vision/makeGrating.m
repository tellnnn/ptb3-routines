function img = makeGrating(params)
% makeGrating creates a sinusoidal grating image.
%  img = makeGrating([name-value pairs])
%    creates a sinusoidal grating image
%    with specified resolution and parameters.
%
%  Input:
%    params: name-value pairs
%      - res: resolution of the image (default 256)
%      - ori: orientation in degrees (0 indicates vertical: default 0)
%      - freq: spatial frequency in cycles per image (default 1)
%          Note that the frequency is defined in cycles per image, not per degree.
%          This means that if the output image is 10 degree and freq = 1,
%          the spatial frequency will be 0.1 cycles per degree.
%          In order to control the spatial frequency in cycles per degree,
%          you need to multiply the input frequency by the image size in degrees.
%      - phase: phase in degrees (default 0)
%      - contrast: contrast (0 to 1: default 1)
%  
%  Output:
%    img: grating image with values between -1 and 1 in size (res, res)
%  
%  Example:
%    img = makeGrating;
%    img = makeGrating('res', 512);
%    img = makeGrating('ori', -45);

arguments (Input)
    params.res (1,1) double {mustBePositive} = 256 % resolution of the image (default 256)
    params.ori (1,1) double = 0 % orientation in degrees (0 indicates vertical: default 0)
    params.freq (1,1) double {mustBePositive} = 1 % frequency in cycles per degree (default 1)
    params.phase (1,1) double = 0 % phase in degrees (default 0)
    params.contrast (1,1) double {mustBeInRange(params.contrast, 0, 1)} = 1 % contrast (0 to 1: default 1)
end

arguments (Output)
    img (:,:) double {mustBeInRange(img, -1, 1)} % grating image with values between -1 and 1 in size (res, res)
end

ori = deg2rad(params.ori);
phase = deg2rad(params.phase);

f2p = params.freq * 2 * pi;
step = f2p / params.res;
[x, y] = meshgrid(0:step:(f2p-step), 0:step:(f2p-step));
img = params.contrast * sin(x * cos(ori) + y * sin(ori) + phase);

end
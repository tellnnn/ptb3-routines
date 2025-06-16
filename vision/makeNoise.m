function img = makeNoise(params)
% makeNoise creates a noise image.
%  img = makeNoise([name-value pairs])
%    creates a noise image with specified parameters.
%
%  Input:
%    params: name-value pairs
%      - res: resolution of the image (default 256)
%      - type: type of noise ('none', 'uniform', 'normal', 'sinusoidal': default 'uniform')
%      - contrast: contrast (0 to 1: default 1)
%
%  Output:
%    img: noise image with values between -1 and 1 in size (res, res)
%
%  Example:
%    img = makeNoise;
%    img = makeNoise('res', 512);
%    img = makeNoise('type', 'normal', 'contrast', 0.5);

arguments (Input)
    params.res (1,1) double {mustBePositive} = 256 % resolution of the image (default 256)
    params.type (1,1) string {...
        mustBeMember(params.type, {'none', 'uniform', 'normal', 'sinusoidal'})...
    } = 'uniform' % type of noise (default 'uniform')
    params.contrast (1,1) double {mustBeInRange(params.contrast, 0, 1)} = 1.0 % contrast (0 to 1: default 1)
end

arguments (Output)
    img (:,:) double {mustBeInRange(img, -1, 1)} % noise image with values between -1 and 1 in size (res, res)
end

switch params.type
    case 'none'
        img = ones(params.res);
    case 'uniform'
        img = rand(params.res, params.res);
        % normalize to [-1, 1]
        img = 2 * img - 1;
        img = params.contrast * img;
    case 'normal'
        img = randn(params.res, params.res); 
        % mute pixels with values of more than 3SD
        img(img >  3) = 0.0;
        img(img < -3) = 0.0;
        % normalize to [-1, 1]
        img = img / 3.0;
        img = params.contrast * img;
    case 'sinusoidal'
        f = rand(params.res, params.res);
        img = params.contrast * sin(2 * pi * f);
end

end
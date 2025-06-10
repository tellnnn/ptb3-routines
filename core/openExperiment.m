function [Exp, win, aud] = openExperiment(Exp, param)
% openExperiment open an experiment.
%   [Exp, win, aud] = openExperiment(Exp, param)
%
%   Input:
%     Exp: struct containing experiment parameters
%     param: name-value pair for experiment parameters
%       - screen: struct containing screen parameters
%       - window: struct containing window parameters (optional)
%       - audio: struct containing audio parameters (optional)
%       - mode: string specifying the mode ('demo' or 'test': default 'test')
%
%   Output:
%     Exp: updated struct with experiment parameters
%     win: updated struct with window parameters
%     aud: updated struct with audio parameters
%
%   Example:
%     % with screen (width = 28 cm, viewing distance = 57.7 cm)
%     scr = struct('ptr', 0, 'width', 28, 'dist', 57.7);
%     [Exp, win, ~] = openExperiment(Exp, 'screen', scr, 'mode', 'demo'); % demo mode
%     [Exp, win, ~] = openExperiment(Exp, 'screen', scr); % test mode
%
%     % specify window parameters
%     win = struct('color', 0); % black background
%     [Exp, win, ~] = openExperiment(Exp, 'screen', scr, 'window', win);
%
%     % specify audio parameters
%     devices = PsychPortAudio('GetDevices');
%     device = devices(1); % get the first audio device
%     aud = struct('device', device); % get default audio device
%     [Exp, win, aud] = openExperiment(Exp, 'screen', scr, 'audio', aud);

arguments
    Exp (1,1) struct
    param.screen (1,1) struct
    param.window (1,1) struct = struct(...
        'color', 127, 'rect', [],...
        'text', struct('size', 28, 'style', 0, 'family', 'Noto Sans', 'color', 255))
    param.audio (1,1) struct = struct()
    param.mode (1,1) string {mustBeMember(param.mode, {'demo','test'})} = 'test'
end

scr = param.screen;
win = param.window;
aud = param.audio;
mode = param.mode;

% validate screen parameters
if ~isfield(scr, 'ptr'), error('Screen pointer is not specified.'); end
if ~isfield(scr, 'width'), error('Screen width is not specified.'); end
if ~isfield(scr, 'dist'), error('Screen viewding distance is not specified.'); end

% validate window parameters
% if text parameters in win are specified, fill non-specified parameters with defaults
if isfield(win, 'text')
    if ~isfield(win.text, 'size'), win.text.size = 28; end
    if ~isfield(win.text, 'style'), win.text.style = 0; end
    if ~isfield(win.text, 'family'), win.text.family = 'Noto Sans'; end
    if ~isfield(win.text, 'color'), win.text.color = 255; end
end


try
    %% Random Number Generator
    Exp.startDatetime = now_iso8601();
    Exp.rngSeed = seconds(timeofday(Exp.startDatetime));
    rng(Exp.rngSeed);


    %% Warm-Up Psychtoolbox
    % perform standard setup for Psychtoolbox
    %   - set colormode clamped: [0–1] range
    %   - reset KbName mappings & KbName('UnifyKeyNames')
    %   - assert OpenGL
    PsychDefaultSetup(2);

    GetSecs();
    WaitSecs(0.1);
    KbCheck();
    InitializePsychSound();
    

    %% Visual
    switch mode
        case 'demo'
            Screen('Preference', 'SkipSyncTests', 1);
            Screen('Preference', 'VisualDebugLevel', 4);
        case 'test'
            Screen('Preference', 'SkipSyncTests', 0);
            Screen('Preference', 'VisualDebugLevel', 4);
        otherwise
            error('PTB3-ROUTINES:UnknownExpMode', 'Unknown mode: %s', mode);
    end

    % open window
    [win.ptr, win.rect] = Screen('OpenWindow', scr.ptr, win.color, win.rect);
    
    % spatial properties of window
    [win.center(1), win.center(2)] = RectCenter(win.rect);
    [win.width, win.height] = Screen('WindowSize', win.ptr);
    win.ppd = pi * win.width / atan(scr.width/scr.dist/2) / 360;

    % temporal properties of window
    win.fps = Screen('FrameRate', win.ptr);
    win.ifi = Screen('GetFlipInterval', win.ptr);
    if win.fps == 0, win.fps = 1/win.ifi; end

    % text properties of window
    Screen('TextSize',  win.ptr, win.text.size);
    Screen('TextStyle', win.ptr, win.text.style);
    Screen('TextFont',  win.ptr, win.text.family);
    Screen('TextColor', win.ptr, win.text.color);
    
    % color properties of window
    BackupCluts();
    if isfield(win, 'clut'), Screen('LoadNormalizedGammaTable', win.ptr, win.clut); end
    Screen('BlendFunction', win.ptr, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA); 


    %% Audio
    if isfield(aud, 'device')
        aud.handle = PsychPortAudio('Open', aud.device.DeviceIndex, 1, 1, aud.device.DefaultSampleRate, aud.device.NrOutputChannels);
        aud.index = aud.device.DeviceIndex;
        aud.sampleRate = aud.device.DefaultSampleRate;
        aud.nrchannels = aud.device.NrOutputChannels;
    end


    %% I/O
    [keyIsDown, ~, keyCode, ~] = KbCheck();
    if keyIsDown
        DisableKeysForKbCheck(find(keyCode));
        warning('PTB3-ROUTINES:DisabledKeys', 'Following keys are pressed at the start of the experiment and disabled hereafter.\n');
        cellfun(@(x) fprintf('  - %s\n', x), KbName(keyCode));
    end


    %% Open
    switch mode
        case 'demo'
            ListenChar(0);
        case 'test'
            ListenChar(2);
            HideCursor();
            Priority(MaxPriority(win.ptr));
        otherwise
            error('PTB3-ROUTINES:UnknownExpMode', 'Unknown mode: %s', mode);
    end

catch err

    closeExperiment(Exp, err);
    save(sprintf('error_%s.mat', datetime('now', 'Format', 'uuuuMMdd''T''HHmmss')));
    rethrow(err);

end
end
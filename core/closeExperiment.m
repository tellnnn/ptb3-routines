function closeExperiment(Exp, err)
% closeExperiment close an experiment.
%   loseExperiment(Exp, err)
%
%   Input:
%     Exp: struct containing experiment parameters
%     err: error message (optional)
%
%   Example:
%     closeExperiment(Exp); % without error

arguments
    Exp (1,1) struct
    err (1,:) = []
end

Priority(0);
ShowCursor();
ListenChar();

DisableKeysForKbCheck([]);

RestoreCluts();

PsychPortAudio('Close');
Screen('CloseAll');

Exp.endDatetime = datetime('now', 'Format', 'uuuu-MM-dd''T''HH:mm:ss');

if isempty(err)
    Exp.endStatus = 1;
else
    Exp.endStatus = 0;
    Exp.error = err;
end
end
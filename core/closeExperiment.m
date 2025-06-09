function closeExperiment(Exp, err)
% closeExperiment close an experiment.
%   closeExperiment(Exp, err)
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

Exp.endDatetime = now_iso8601();

if isempty(err)
    Exp.endStatus = 1;
else
    Exp.endStatus = 0;
    Exp.error = err;
end
end
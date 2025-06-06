function writeParticipants(participants, bids)
% writeParticipants writes the participants table
%   writeParticipants(bids)
%
% Inputs:
%   bids: path to the BIDS directory (default: current working directory)
%
% Example:
%   writeParticipants(participants); % if you are in the BIDS directory
%   writeParticipants(participants, '/path/to/bids/dataset'); % if you are in a different directory

arguments
    participants table
    bids (1,:) char = pwd()
end

tblPath  = fullfile(bids, 'participants.tsv');

writetable(participants, tblPath, 'FileType', 'text', 'Delimiter', '\t', 'WriteVariableNames', true);

end
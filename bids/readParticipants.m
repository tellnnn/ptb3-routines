function participants = readParticipants(bids)
% readParticipants reads participants.
%  participants = readParticipants(bids)
%    reads the participants information from a BIDS dataset
%    and returns a table with the participants information.
%
%  Input:
%    bids: path to the BIDS dataset (default: current working directory)
%
%  Output:
%    participants: table with the participants information
%
%  Example:
%    participants = readParticipants; % reads from current working directory
%    participants = readParticipants('/path/to/bids/dataset'); % reads from specified path

arguments
    bids (1,:) char = pwd()
end

tblPath  = fullfile(bids, 'participants.tsv');
jsonPath = fullfile(bids, 'participants.json');

% assert that the participants file exists
assert(exist(tblPath, 'file'), 'PTB3-ROUTINES:ParticipantsFileNotFound', 'participants.tsv not found in %s', bids);
assert(exist(jsonPath, 'file'), 'PTB3-ROUTINES:ParticipantsFileNotFound', 'participants.json not found in %s', bids);

% read the participants table and json file
participants = readtable(tblPath, 'FileType', 'text', 'Delimiter', '\t', 'ReadVariableNames', true);
json = jsondecode(fileread(jsonPath));

% assert that the first column is participant_id
assert(strcmp(participants.Properties.VariableNames{1}, 'participant_id'), ...
    'PTB3-ROUTINES:ParticipantsFileInvalid', ...
    '1st column in participants.tsv must be "participant_id"');

% assert that the participants table has the same fields as the json file
assert(all(strcmp(participants.Properties.VariableNames(2:end), fieldnames(json)')),...
    'PTB3-ROUTINES:ParticipantsFileInvalid', ...
    'participants.tsv columns do not match participants.json fields');

% modify the participants table to match the json file specifications
participants.Properties.Description = 'Participants table';

for col = 1:numel(participants.Properties.VariableNames)
    name = participants.Properties.VariableNames{col};

    % convert the column to string if it is a cellstr
    if iscellstr(participants{:, col})
        participants.Properties.VariableTypes(col) = "string";
    end

    if strcmp(name, 'participant_id')
        % set descrition and units for participant_id
        participants.Properties.VariableDescriptions{col} = 'Participant identifier';
        participants.Properties.VariableUnits{col} = '';
    else
        % get the field from the json file
        spec = getfield(json, name);
        
        % set description for the column
        participants.Properties.VariableDescriptions{col} = getfield(spec, 'Description');

        % set units for the column
        if isfield(spec, 'Units')
            participants.Properties.VariableUnits{col} = getfield(spec, 'Units');
        else
            participants.Properties.VariableUnits{col} = '';
        end

        % convert the column to categorical if it has levels
        if isfield(spec, 'Levels')
            levels = fieldnames(getfield(spec, 'Levels'))';
            participants{:, col} = categorical(participants{:, col}, levels);
        end
    end
end

end
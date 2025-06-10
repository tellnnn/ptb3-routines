function t = now_iso8601(relativeDay)
    arguments
        relativeDay (1,:) char = 'now'
    end
    t = datetime(relativeDay, 'Format', 'uuuu-MM-dd''T''HH:mm:ss');
end
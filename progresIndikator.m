function progresIndikator(iteracija)
    % Calculate the current state of the dot sequence
    index = mod(iteracija, 4) + 1;
    sekvenca = {'.   ', '..  ', '... ', '....'};
    
    % Print the current dot sequence and overwrite the previous line
    fprintf('%s', sekvenca{index});
    pause(0.1); % Pause to simulate ongoing process
    fprintf('\b\b\b\b'); % Backspace to remove the previous dots
end
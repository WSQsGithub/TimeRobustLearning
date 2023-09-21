function [q_values, Q] = quiryQ(state, Q)
% return a list of q_values for all action at current state
    
% check if the state string is valid, if not print an error message
    if(~isValid(state))
        error("STATE INVALID:\t{%s}", state);
    end
% check if this state is visited already
    if(~isKey(Q,state))
        % adding new state to table
        % fprintf("Adding new state to table: %s\n", state);
        q_values = zeros(1,9);
        Q(state) = {q_values};
        return
    end
% return q_values from Q-table
    q_values = Q(state);
    q_values = q_values{1}; % unpack list from cell
end

function flag = isValid(state)
% TODO: in progress
    
    flag = 1;
end
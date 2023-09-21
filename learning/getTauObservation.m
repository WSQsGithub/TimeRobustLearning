function [reward, state_next,s_next] = getTauObservation(state, action, prob_right, delta, h,beta,task,problem)
    % Transition and reward in tau-MDP
    % eps is the greedy parameter
    % state is in string
    
    % state is in matrix form from now on
    s = unpackState(state); % s is in matrix form
    s_now = s(end,:); % current state of primal MDP
    s_next = getObservation(s_now,action,prob_right);
    
    state_next = [s(2:end,:);s_next];
    reward = getReward(state_next, delta, h,beta,task,problem);
    
    % convert state back to string from
    state_next = packState(state_next);

end

%%

function [state_next] = getObservation(state, action, p_right)
% Transition and reward in primal MDP
% eps is the greedy parameter
    global grid_size;
    
    dice = randn;
    
    action_uncertainty = [9,2,8; 1,3,9;2,4,9;
        3,5,9;4,6,9;6,7,9;
        7,9,1;9,9,1;9,9,9];
    
    if(dice>p_right)
        action = action_uncertainty(action,randi(3));
    end
    
    switch action
        case 1 
            state_next = state + [0,1];
        case 2
            state_next = state + [1,1];
        case 3
            state_next = state + [1,0];
        case 4
            state_next = state + [1,-1];
        case 5
            state_next = state + [0,-1];
        case 6
            state_next = state + [-1,-1];
        case 7
            state_next = state + [-1,0];
        case 8
            state_next = state + [-1,1];
        case 9
            state_next = state;
    end
    
    % stay if hitting the wall
    if(state_next(1)>=grid_size || state_next(1)<=0 ||state_next(2)>=grid_size||state_next(2)<=0) 
        state_next = state;
    end

end
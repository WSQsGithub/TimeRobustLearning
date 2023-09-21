function action = chooseAction(state, Q, eps)
% return an action either from Q-table or randomly depending on the greedy parameter eps 
% actions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW", "stay"]; % from action 1 - 9

    dice = rand;
    q_values = quiryQ(state,Q);
    if(dice>eps) 
        %fprintf('choosing the best option\n')
        action = find(q_values==max(q_values)); % choose that best action
        action = action(randi(length(action))); % randomly choose one if there are more than one best
    else 
        %fprintf('choosing randomly from unexplored options\n')
        action = find(q_values==0);
        if(~isempty(action))
            action = action(randi(length(action)));
        else
            action = randi(9);
        end
    end

end
function res = sat(state,task)
% given phi = G[0,h]psi
    if(task==1)
        res = min(state>[3,3] & state<[6,6]);
        res = min(res);
    elseif(task==2)

        % Phi = G[0,T](F[0,h] x in A and F[0,h] x in B
        A = [1 3;2 4]; B = [2 2;3 3];
        res1 = max(min(state>A(1,:),[],2) & min(state<A(2,:),[],2)); % whether it has been to A 
        res2 = max(min(state>B(1,:),[],2) & min(state<B(2,:),[],2)); % whether it has been to B
        res = min(res1,res2); % whether it has been to both A and B
    end

    if(res== 0)
        res = -1;
    end
    
end
function reward = getReward(state, delta, h,beta, task, problem)
    % return step reward 
    
    % state is in matrix form shape=tau*2
    if(problem==1) % maximizing time-robust probability 

        flag = zeros(delta+1,1);

        for d = 0:delta
            flag(d+1) = sat(state(end-d-h+1:end-d,:),task);
        end

        % check if state is robust to all delays 
        rb = min(flag);
        % given Phi = F[0,T)phi
        if(task==1)
            reward = scaleReward(rb,beta,100/exp(beta),-1);
        elseif(task==2)
            reward = scaleReward(rb,-beta,-100/exp(beta),10);
        end

    elseif(problem==2)
        % maximizing the worst-case robustness
        flag = zeros(delta+1,1);

        for d = 0:delta
            flag(d+1) = robustness(state(end-d-h+1:end-d,:),task);
        end
        % get the worst-case spatial robustness
        rb = min(flag);
        % given Phi = F[0,T)phi
        if(task==1)
            reward = scaleReward(rb,beta,100/exp(0.5*beta),-1);
        elseif(task==2)
            reward = rb-0.40;%scaleReward(rb,-beta,-100/exp(1.5*beta),100*(exp(-beta)-100*exp(-2*beta)));
        end
    end

end


function res = scaleReward(rb,beta,a,b)
% a simple transformation to scale reward and form negative reward
    res = a*exp(beta*rb)+b; 
end
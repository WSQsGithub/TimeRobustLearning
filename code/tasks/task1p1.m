% standard procedure for q-learning in grid world
latexscr; clear; clc; color;
%% q-learning parameters
alpha = 0.95; % learning rate
min_alpha = 0.0001;
max_eps = 0.999;  % exploration parameter
min_eps = 0.1;
eps_decay = 0.0001;
beta = 50; % LSE parameter
gamma = 0.9999; % discount factor

%% World parameters
global grid_size;
grid_size = 6; % grid size
display(['Size of the original state space : ', num2str(grid_size^2)]);

prob_right = 0.91; 
prob_wrong = (1-prob_right)/3; % transition uncertainty

%% Agent Initialization

task = 1; %'1: reachability, 2: patrolling'
problem = 1; % 1: maximize robust probability, 2: maximize worst case robustness


if(task == 1)
    T = 12; % Task horizon
    h = 2;  % sub-task horizon
    fprintf('Reachability Task: F[0,12)G[0,2)([6,6]>x>[3,3])');
elseif(task == 2)
    fprintf('Patrolling Task: G[0,12)(F[0,3) x in A and F[0,3) x in B)')
end


delta = 2; % time robustness requirement
tau = h+delta; % length of history

actions = ["N", "NE", "E", "SE", "S", "SW", "W", "NW", "stay"]; % from action 1 - 9

% tau-MDP state


% q-table is a dictionary, whose key is tau-state and value is a 9-entry
% long list consisting of q-value for all 9 actions correspondingly
% We use string to store tau-state, where "-1" is the placeholder state
%  ---------------------------------------------
%    tau-state  |   (action, Q-value)
%  -------------|-------------------------------
%   "e,e,e,s0"  |   [q1,q2,q3,q4,q5,q6,q7,q8,q9]

s_0 = [1.5 1.5];
s_tau_0=packState([s_0.*ones(tau-1,2);s_0]);
fprintf("Initial Q-table: "); 
Q = dictionary(s_tau_0, {zeros(1,9)});
display(Q);
%% a timer for message update
delete(timerfindall);
mytimer = timer('StartDelay',2,'TimerFcn',@TimerFunction,'Period',5,'ExecutionMode','fixedRate');

%% q-learning algorithm
checkpoint = 1; 
N_episode = 5000;
check_interval = 500;

Log.Reward = zeros(N_episode,1);
Log.Action = zeros(N_episode,T+h);
Log.State = zeros(T+h,2,N_episode);
Log.return = zeros(N_episode,T+h);
Log.step = zeros(N_episode,1);
Log.Results = zeros(N_episode,3);

figure(1); title('Reward Curve'); hold on; ylabel('Reward'); xlabel('\#Episode');
msg.index = 0;
msg.lenQ = 0;
mytimer.UserData=msg;
start(mytimer);

%start(mytimer,'UserData',msg);
for i = 1:N_episode

    s_tau = s_tau_0; % initialize s_tau
    s = s_0;
    R = 0;% initialize episodic return
    
    %index = max(mod(i,check_interval),mod(i,check_interval+1));
    index = i;
    Log.step(index) = i;

    
    eps = max((1-eps_decay)*eps,min_eps); % explore probability decay
    alpha = max(0.999*alpha,min_alpha);

    for k = 1:T+h
        
        a = chooseAction(s_tau, Q, eps);% choose a from s using policy derived from Q
        
        Log.Action(index,k) = a;
        Log.State(k,:,index) = s;

        [r, s_tau_next,s_next] = getTauObservation(s_tau, a, prob_right, delta, h,beta,task, problem);% take action a, observe r, s_tau_next
        Log.return(index,k) = r;
        R = R+r;

        [q, Q] = quiryQ(s_tau,Q); % draw state-action value from Q-table
        [q_next, Q] = quiryQ(s_tau_next,Q); 
        
        q(a) = q(a)+alpha*(r+gamma * max(q_next)-q(a)); % q-learning update rule for Q(s,a)

        Q(s_tau) = {q};% update Q
        s_tau = s_tau_next;% update state
        s = s_next;
    end

    Log.Reward(index) = R;
    Log.Results(index,:) = evaluate(Log.State(:,:,index), task, T, h); 
    
    msg.index = i; 
    msg.lenQ = Q.numEntries;
    mytimer.UserData=msg;

    if(~mod(index,check_interval)) % save data every check_interval steps
        fprintf("\n----------------------------------------------------------------------\n> Episode %d\n",i);
        fprintf("%d entries in the Q-table\n",Q.numEntries);
        pause(0.5);
        plot(Log.step,Log.Reward,'Color',[C.grey,0.1]); xlim([0,N_episode]); hold on;
        smoothreward = smooth(Log.Reward,100);
        plot(Log.step,smoothreward,'y','LineWidth',2,'Color',C.blue); hold off;
        pause(0.5);

        checkpoint_name = strcat(['checkpoint_log', num2str(checkpoint)]);
        %save(checkpoint_name,"Log","Q");

        checkpoint = checkpoint+1;
    end
    
    % early stopping condition

end
stop(mytimer);
delete(mytimer);
%% save training curve
close all;
smoothreward = smooth(Log.Reward,1000);
figure();  hold on;
title('Reward Learning Curve');
xlim([0,N_episode*0.8]); 
plot(Log.step,Log.Reward,'Color',[C.grey,0.2]); 
plot(Log.step,smoothreward,'Color',C.blue,'LineWidth',4);
ylabel('Episodic Reward');xlabel('\#Episode');


saveas(gcf,'results/task1p1_curve.fig','fig');
saveas(gcf,'results/task1p1_curve.png','png');
%% Evaluation 
rollout = 1000;
Evaluation.State = zeros(T+h,2,rollout);
Evaluation.Results = zeros(rollout,3); % first column is sat and second is spatial and third column is temporal
Evaluation.Reward = zeros(rollout,1);
Evaluation.Action = zeros(rollout,T+h);
Evaluation.return = zeros(rollout,T+h);
for i = 1:rollout
    s_tau = s_tau_0; % initialize s_tau
    s = s_0;
    R = 0;% initialize episodic return
    for t = 1:T+h
        Evaluation.State(t,:,i) = s;

        a = chooseAction(s_tau, Q, 0);

        [r, s_tau_next,s_next] = getTauObservation(s_tau, a, prob_right, delta, h,beta,task,problem);
        Evaluation.return(i,t) = r;
        Evaluation.Action(i,t) = a;
        
        s_tau = s_tau_next;% update state
        s = s_next;
        R = R+r;
    end
    Evaluation.Reward(i) = R;
    % Calculate robustness
    Evaluation.Results(i,:) = evaluate(Evaluation.State(:,:,i), task, T, h);
end    

% Evaluate Results
sat = Evaluation.Results(:,1);
srb = Evaluation.Results(:,2);
trb = Evaluation.Results(:,3);

fprintf("Satisfaction probability: %.3f, Time-Robust Probability: %.3f\n", mean(sat),mean(trb>delta));
fprintf("Average Spatial Robustness: %.3f, Average Time Robustness: %.3f\n", mean(srb),mean(trb));
%%
figure(); hold on;

subplot(211); title('Histogram of Spatial Robustness'); hold on;
[counts,bins] = hist(srb); %# get counts and bin locations
barh(bins,counts,'FaceColor',C.blue); 
plot([0,rollout],[mean(srb),mean(srb)],'--','Color',C.red,'LineWidth',2); 
text(rollout-150,mean(srb)-0.2,strcat(['Avg=' num2str(mean(srb))]));
text(rollout-150,mean(srb)-0.6,strcat(['Pr=' num2str(mean(sat))]));

subplot(212); title('Histogram of Temporal Robustness'); hold on; 
[counts,bins] = hist(trb); %# get counts and bin locations
barh(bins,counts,'FaceColor',C.blue); 
plot([0,rollout],[mean(trb),mean(trb)],'--','Color',C.red,'LineWidth',2);
text(rollout-150,mean(trb)-2,strcat(['Avg=' num2str(mean(trb))]));
text(rollout-150,mean(trb)-5,strcat(['Pr=' num2str(mean(trb>delta))]));
 

saveas(gcf,'results/task1p1_hist.fig','fig');
saveas(gcf,'results/task1p1_hist.png','png');

%% Choose an sample trajectory
[row, col] = find(Evaluation.Reward==max(Evaluation.Reward));

best_trace.id = row(randi(length(row)));
best_trace.Reward = Evaluation.Reward(best_trace.id);
best_trace.trace = Evaluation.State(:,:,best_trace.id);
best_trace.return =  Evaluation.return(best_trace.id,:);

figure(1);
clf;hold on; grid on; xlim([0,6]); ylim([0,6]);
plot(1.5,1.5,'Marker','p','MarkerSize',30,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',2);
rectangle('Position',[3,3,3,3],'edgecolor','k','facecolor','y','linewidth',1.8);  % mark goal
plot(best_trace.trace(:,1),best_trace.trace(:,2),"Color",C.red,"LineWidth",2,'Marker','o','MarkerFaceColor',C.red);

saveas(gcf,'results/task1p1_sample_trace.png','png');
saveas(gcf,'results/task1p1_sample_trace.fig','fig');

figure(2);
subplot(311); hold on; set(gca, 'XTick',0:T+h); plot(1:T+h,best_trace.trace(:,1),"LineWidth",2,"Color",C.blue); ylabel('x position'); 
subplot(312); hold on; set(gca, 'XTick',0:T+h); plot(1:T+h,best_trace.trace(:,2),"LineWidth",2,"Color",C.blue); ylabel('y position'); 
subplot(313); hold on; set(gca, 'XTick',0:T+h); plot(1:T+h,best_trace.return,"LineWidth",2,"Color",C.blue);ylabel('step reward'); 

saveas(gcf,'results/task1p1_sample_trace_xyr.png','png');
saveas(gcf,'results/task1p1_sample_trace_xyr.fig','fig');

%% 100 traces
figure(3);
grid on; xlim([0,6]); ylim([0,6]); hold on;
plot(1.5,1.5,'Marker','p','MarkerSize',30,'MarkerEdgeColor','k','MarkerFaceColor','y','LineWidth',2);
rectangle('Position',[3,3,3,3],'edgecolor','k','facecolor','y','linewidth',1.8);  % mark goal
for i = 1:100
    plot(Evaluation.State(:,1,i),Evaluation.State(:,2,i),"LineWidth",2,'Marker','.'); hold on;
end
saveas(gcf,'results/task1p1_100traces.png','png');
saveas(gcf,'results/task1p1_100traces.fig','fig');
%% save data
save('results/task1p1Data',"Q","Log","Evaluation");
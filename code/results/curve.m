% curve
clear all; color;
Data_task1p1 = load('task1p1Data.mat');
Data_task1p2 = load('task1p2Data.mat');
Data_task2p1 = load('task2p1Data.mat');
Data_task2p2 = load('task2p2Data.mat');


R11 = Data_task1p1.Log.Reward;
R11 = R11./max(abs(R11));

R12 = Data_task1p2.Log.Reward;
R12 = R12./max(abs(R12));

R21 = Data_task2p1.Log.Reward;
R21 = R21./max(abs(R21));

R22 = Data_task2p2.Log.Reward;
R22 = R22./max(abs(R22))+1;

step = Data_task2p1.Log.step;


%% Data Processing


%%
figure();
hold on;%set(gca,'yticklabel',[])
xlim([0,length(step)*0.99]); ylim([-0.01,inf]);
plot(step,R11,'Color',[C.brown,0.02]);
l11 = plot(step,smooth(R11,1000),'Color',[C.brown],'LineWidth',4);
legend(l11,'T1P1');

plot(step,R12,'Color',[C.red,0.02]);
l12 = plot(step,smooth(R12,1000),'Color',[C.red],'LineWidth',4);
legend(l12,'T1P2');

xlim([0,length(step)*0.99])
plot(step,R21,'Color',[C.purple,0.02]);
l21 = plot(step,smooth(R21,1000),'Color',[C.purple],'LineWidth',4);
legend(l21,'T2P1');

plot(step,R22,'Color',[C.green,0.02]);
l22 = plot(step,smooth(R22,1000),'Color',[C.green],'LineWidth',4);
legend([l11,l12,l21,l22],'T1P1','T1P2','T2P1','T2P2');

saveas(gcf,'./curves.png','png');
clc
clear all
%% Define problem variables
% Primal variable
P_existing_gen = sdpvar(2,2,'full'); % Generation
P_can_gen = sdpvar(2,2,'full'); % Candidate Generation
P_can_max = sdpvar(2,1,'full'); % Candidate Generation maximum
Pline = sdpvar(2,2,2,'full'); % Lines in the 3rd index
Del = sdpvar(2,2,2,'full'); % Nodes in the 3rd index
x_BS = binvar(2,1,'full'); % Prospective_branch_status
P_LS = sdpvar(2,2,'full'); % Load shedding amount
M=5000;

%% Building objective function
Objective= P_can_max(1,1)*140000+x_BS(1,1)*200000+P_can_max(2,1)*70000+x_BS(2,1)*100000+...
            6000*(35*P_existing_gen(1,1) + 25*P_can_gen(1,1)+80*P_LS(1,1))+...
            2760*(35*P_existing_gen(1,2) + 25*P_can_gen(1,2)+80*P_LS(1,2))+...
            6000*(35*P_existing_gen(2,1) + 25*P_can_gen(2,1)+80*P_LS(2,1))+...
            2760*(35*P_existing_gen(2,2) + 25*P_can_gen(2,2)+80*P_LS(2,2));

%% constraints
Constraints=[];
Constraints=[Constraints, 0<=sum(P_can_max(1:2,1))<=300];
Constraints=[Constraints, sum(x_BS(1:2,1))<=1];
Constraints=[Constraints, x_BS(1,1)*1000000<=2*1000000];
Constraints=[Constraints, P_can_max(1,1)*700000<=400*1000000];
Constraints=[Constraints, x_BS(2,1)*1000000<=2*1000000];
Constraints=[Constraints, P_can_max(2,1)*700000<=400*1000000];

%% time period 1,OpCon 1
Constraints=[Constraints, P_existing_gen(1,1)-Pline(1,1,1)-Pline(1,1,2)==0];
Constraints=[Constraints, P_can_gen(1,1)+Pline(1,1,1)+Pline(1,1,2)==246.5-P_LS(1,1)];    
Constraints=[Constraints, Pline(1,1,1)==500*(Del(1,1,1)-Del(1,1,2))];
Constraints=[Constraints, -200*x_BS(1,1)<=Pline(1,1,2)<=200*x_BS(1,1)];
Constraints=[Constraints, -(1-x_BS(1,1))*M<=Pline(1,1,2)-500*(Del(1,1,1)-Del(1,1,2))<=(1-x_BS(1,1))*M];
Constraints=[Constraints, -200<=Pline(1,1,1)<=200];
% Constraints=[Constraints, -200<=Pline(2,1)<=200];
Constraints=[Constraints, 0<=P_existing_gen(1,1)<=400];
Constraints=[Constraints, 0<=P_can_gen(1,1)<=P_can_max(1,1)];
Constraints=[Constraints, 0<=P_LS(1,1)<=246.5];
Constraints=[Constraints, -pi<=Del(1,1,2)<=pi];
Constraints=[Constraints, Del(1,1,1)==0];

%% time period 1,OpCon 2
Constraints=[Constraints, P_existing_gen(1,2)-Pline(1,2,1)-Pline(1,2,2)==0];
Constraints=[Constraints, P_can_gen(1,2)+Pline(1,2,1)+Pline(1,2,2)==467.5-P_LS(1,2)];    
Constraints=[Constraints, Pline(1,2,1)==500*(Del(1,2,1)-Del(1,2,2))];
Constraints=[Constraints, -200*x_BS(1,1)<=Pline(1,2,2)<=200*x_BS(1,1)];
Constraints=[Constraints, -(1-x_BS(1,1))*M<=Pline(1,2,2)-500*(Del(1,2,1)-Del(1,2,2))<=(1-x_BS(1,1))*M];
Constraints=[Constraints, -200<=Pline(1,2,1)<=200];
% Constraints=[Constraints, -200<=Pline(2,1)<=200];
Constraints=[Constraints, 0<=P_existing_gen(1,2)<=400];
Constraints=[Constraints, 0<=P_can_gen(1,2)<=P_can_max(1,1)];
Constraints=[Constraints, 0<=P_LS(1,2)<=467.5];
Constraints=[Constraints, -pi<=Del(1,2,2)<=pi];
Constraints=[Constraints, Del(1,2,1)==0];

%% time period 2, OpCon 1
Constraints=[Constraints, P_existing_gen(2,1)-Pline(2,1,1)-Pline(2,1,2)==0];
Constraints=[Constraints, P_can_gen(2,1)+Pline(2,1,1)+Pline(2,1,2)==290-P_LS(2,1)];    
Constraints=[Constraints, Pline(2,1,1)==500*(Del(2,1,1)-Del(2,1,2))];
Constraints=[Constraints, -200*sum(x_BS(1:2,1))<=Pline(2,1,2)<=200*sum(x_BS(1:2,1))];
Constraints=[Constraints, -(1-sum(x_BS(1:2,1)))*M<=Pline(2,1,2)-500*(Del(2,1,1)-Del(2,1,2))<=(1-sum(x_BS(1:2,1)))*M];
Constraints=[Constraints, -200<=Pline(2,1,1)<=200];
% Constraints=[Constraints, -200<=Pline(2,1)<=200];
Constraints=[Constraints, 0<=P_existing_gen(2,1)<=400];
Constraints=[Constraints, 0<=P_can_gen(2,1)<=sum(P_can_max(1:2,1))];
Constraints=[Constraints, 0<=P_LS(2,1)<=290];
Constraints=[Constraints, -pi<=Del(2,1,2)<=pi];
Constraints=[Constraints, Del(2,1,1)==0];

%% time period 2, OpCon 2
Constraints=[Constraints, P_existing_gen(2,2)-Pline(2,2,1)-Pline(2,2,2)==0];
Constraints=[Constraints, P_can_gen(2,2)+Pline(2,2,1)+Pline(2,2,2)==550-P_LS(2,2)];    
Constraints=[Constraints, Pline(2,2,1)==500*(Del(2,2,1)-Del(2,2,2))];
Constraints=[Constraints, -200*sum(x_BS(1:2,1))<=Pline(2,2,2)<=200*sum(x_BS(1:2,1))];
Constraints=[Constraints, -(1-sum(x_BS(1:2,1)))*M<=Pline(2,2,2)-500*(Del(2,2,1)-Del(2,2,2))<=(1-sum(x_BS(1:2,1)))*M];
Constraints=[Constraints, -200<=Pline(2,2,1)<=200];
% Constraints=[Constraints, -200<=Pline(2,1)<=200];
Constraints=[Constraints, 0<=P_existing_gen(2,2)<=400];
Constraints=[Constraints, 0<=P_can_gen(2,2)<=sum(P_can_max(1:2,1))];
Constraints=[Constraints, 0<=P_LS(2,2)<=550];
Constraints=[Constraints, -pi<=Del(2,2,2)<=pi];
Constraints=[Constraints, Del(2,2,1)==0];
%% finding optimal solution (optimal=building 290MW and line 2, cost 109.03M)
ops = sdpsettings('verbose',0,'debug',1);
Solution = optimize(Constraints,Objective,ops)

Total_cost=value(Objective)
x_BS=value(x_BS)
P_can_max=value(P_can_max)
P_existing_gen=value(P_existing_gen)
P_can_gen=value(P_can_gen)
P_LS=value(P_LS)



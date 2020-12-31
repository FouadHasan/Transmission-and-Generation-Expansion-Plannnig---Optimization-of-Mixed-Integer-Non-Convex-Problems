clc
clear classes

%% Read system input
p_cq=[0;100;200;300;400;500];
M = 5000;
investment_per_MW=70000;

%% Define problem variables % time period in row, op con in column 
%Primal variable
P_existing_gen = sdpvar(2,2,'full'); % Generation
P_can_gen = sdpvar(2,2,'full'); % Candidate Generation
P_can_max = sdpvar(2,1,'full'); % Candidate Generation maximum
%Dual variable
lamda=sdpvar(2,2,'full');
mu_ex_gen=sdpvar(2,2,'full');
mu_can_gen=sdpvar(2,2,'full');
%Binary variable
u_cq = binvar(6,2,'full');
z_cqo= binvar(6,4,'full');
z_cqo_cap= binvar(6,4,'full');

%% Building objective function 
Objective = P_can_max(1,1)*140000+P_can_max(2,1)*70000 +...
           6000*(35*P_existing_gen(1,1) + 25*P_can_gen(1,1)) + 2760*(35*P_existing_gen(1,2) + 25*P_can_gen(1,2))+... %time period 1
           6000*(35*P_existing_gen(2,1) + 25*P_can_gen(2,1)) + 2760*(35*P_existing_gen(2,2) + 25*P_can_gen(2,2))     %time period 2

%% constraints
Constraints = [];
Constraints=[Constraints, sum(u_cq(:,1).*p_cq) == P_can_max(1,1)];
Constraints=[Constraints, sum(u_cq(:,2).*p_cq) == P_can_max(2,1)];
Constraints=[Constraints, sum(u_cq(:,1)) == 1];
Constraints=[Constraints, sum(u_cq(:,2)) == 1];

%% Time period 1, Operating condition 1
Constraints=[Constraints, P_existing_gen(1,1) + P_can_gen(1,1) == 246.5];
Constraints=[Constraints, 0 <= P_existing_gen(1,1) <= 400];
Constraints=[Constraints, 0 <= P_can_gen(1,1) <= P_can_max(1,1)];
Constraints=[Constraints, 35-lamda(1,1)+mu_ex_gen(1,1)>=0];
Constraints=[Constraints, 25-lamda(1,1)+mu_can_gen(1,1)>=0];
Constraints=[Constraints, mu_ex_gen(1,1)>=0];
Constraints=[Constraints, mu_can_gen(1,1)>=0];

Constraints=[Constraints, 35*P_existing_gen(1,1) + 25*P_can_gen(1,1)==290*lamda(1,1)-400*mu_ex_gen(1,1)-sum(z_cqo(:,1))];
Constraints=[Constraints, z_cqo(:,1)== p_cq*mu_can_gen(1,1)-z_cqo_cap(:,1)];
Constraints=[Constraints, 0<=z_cqo(:,1)<=u_cq(:,1)*M];
Constraints=[Constraints, 0<=z_cqo_cap(:,1)<=(1-u_cq(:,1))*M];

%% Time period 1,Operating condition 2
Constraints=[Constraints, P_existing_gen(1,2) + P_can_gen(1,2) == 467.5];
Constraints=[Constraints, 0 <= P_existing_gen(1,2) <= 400];
Constraints=[Constraints, 0 <= P_can_gen(1,2) <= P_can_max(1,1)];
Constraints=[Constraints, 35-lamda(1,2)+mu_ex_gen(1,2)>=0];
Constraints=[Constraints, 25-lamda(1,2)+mu_can_gen(1,2)>=0];
Constraints=[Constraints, mu_ex_gen(1,2)>=0];
Constraints=[Constraints, mu_can_gen(1,2)>=0];

Constraints=[Constraints, 35*P_existing_gen(1,2)+25*P_can_gen(1,2)==550*lamda(1,2)-400*mu_ex_gen(1,2)-sum(z_cqo(:,2))];
% Constraints=[Constraints, z_cqo(:,2)== p_cq*mu_can_gen(1,2)-z_cqo_cap(:,2)];
% Constraints=[Constraints, 0<=z_cqo(:,2)<=u_cq(:,1)*M];
% Constraints=[Constraints, 0<=z_cqo_cap(:,2)<=(1-u_cq(:,1))*M];


%% Time period 2, Operating condition 1
Constraints=[Constraints, P_existing_gen(2,1) + P_can_gen(2,1) == 290];
Constraints=[Constraints, 0 <= P_existing_gen(2,1) <= 400];
Constraints=[Constraints, 0 <= P_can_gen(2,1) <= P_can_max(1,1) + P_can_max(2,1)];% sum of 'P_can_max' in two time period
Constraints=[Constraints, 35-lamda(2,1)+mu_ex_gen(2,1)>=0];
Constraints=[Constraints, 25-lamda(2,1)+mu_can_gen(2,1)>=0];
Constraints=[Constraints, mu_ex_gen(2,1)>=0];
Constraints=[Constraints, mu_can_gen(2,1)>=0];


Constraints=[Constraints, 35*P_existing_gen(2,1) + 25*P_can_gen(2,1)==290*lamda(2,1)-400*mu_ex_gen(2,1)-sum(z_cqo(:,3))];
Constraints=[Constraints, z_cqo(:,3)== p_cq*mu_can_gen(2,1)-z_cqo_cap(:,3)];
Constraints=[Constraints, 0<=z_cqo(:,3)<=u_cq(:,2)*M];
Constraints=[Constraints, 0<=z_cqo_cap(:,3)<=(1-u_cq(:,2))*M];

%% Time period 2,Operating condition 2
Constraints=[Constraints, P_existing_gen(2,2) + P_can_gen(2,2) == 550];
Constraints=[Constraints, 0 <= P_existing_gen(2,2) <= 400];
Constraints=[Constraints, 0 <= P_can_gen(2,2) <= P_can_max(1,1) + P_can_max(2,1)];% sum of 'P_can_max' in two time period
Constraints=[Constraints, 35-lamda(2,2)+mu_ex_gen(2,2)>=0];
Constraints=[Constraints, 25-lamda(2,2)+mu_can_gen(2,2)>=0];
Constraints=[Constraints, mu_ex_gen(2,2)>=0];
Constraints=[Constraints, mu_can_gen(2,2)>=0];

Constraints=[Constraints, 35*P_existing_gen(2,2)+25*P_can_gen(2,2)==550*lamda(2,2)-400*mu_ex_gen(2,2)-sum(z_cqo(:,4))];
% Constraints=[Constraints, z_cqo(:,4)== p_cq*mu_can_gen(2,2)-z_cqo_cap(:,4)];
% Constraints=[Constraints, 0<=z_cqo(:,4)<=u_cq(:,2)*M];
% Constraints=[Constraints, 0<=z_cqo_cap(:,4)<=(1-u_cq(:,2))*M];

%% finding optimal solution
ops = sdpsettings('verbose',0,'debug',1);
Solution = optimize(Constraints,Objective,ops)

P_can_max=value(P_can_max)
u_cq=value(u_cq)
P_existing_gen=value(P_existing_gen)
P_can_gen=value(P_can_gen)
lamda=value(lamda)
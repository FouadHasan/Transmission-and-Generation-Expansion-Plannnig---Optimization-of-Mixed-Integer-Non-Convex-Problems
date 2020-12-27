clc
clear classes

%% Read system input
p_cq=[0;100;200;300;400;500];
M = 5000;
investment_per_MW=70000;

%% Define problem variables
%Primal variable
P_existing_gen = sdpvar(1,2,'full'); % Generation
P_can_gen = sdpvar(1,2,'full'); % Candidate Generation
P_can_max = sdpvar(1,1,'full'); % Candidate Generation maximum
%Dual variable
lamda=sdpvar(1,2,'full');
mu_ex_gen=sdpvar(1,2,'full');
mu_can_gen=sdpvar(1,2,'full');
%Binary variable
u_cq = binvar(6,1,'full');
z_cqo= binvar(6,2,'full');
z_cqo_cap= binvar(6,2,'full');


%% Building objective function 
Objective= P_can_max*70000 + 6000*(35*P_existing_gen(1,1) + 25*P_can_gen(1,1)) + 2760*(35*P_existing_gen(1,2) + 25*P_can_gen(1,2));

%% constraints
Constraints = [];
Constraints=[Constraints, sum(u_cq.*p_cq) == P_can_max];
Constraints=[Constraints, sum(u_cq) == 1];

%% Operating condition 1
Constraints=[Constraints, P_existing_gen(1,1) + P_can_gen(1,1) == 290];
Constraints=[Constraints, 0 <= P_existing_gen(1,1) <= 400];
Constraints=[Constraints, 0 <= P_can_gen(1,1) <= P_can_max];
Constraints=[Constraints, 35-lamda(1,1)+mu_ex_gen(1,1)>=0];
Constraints=[Constraints, 25-lamda(1,1)+mu_can_gen(1,1)>=0];
Constraints=[Constraints, mu_ex_gen(1,1)>=0];
Constraints=[Constraints, mu_can_gen(1,1)>=0];

Constraints=[Constraints, 35*P_existing_gen(1,1) + 25*P_can_gen(1,1)==290*lamda(1,1)-400*mu_ex_gen(1,1)-sum(z_cqo(:,1))];
Constraints=[Constraints, z_cqo(:,1)== p_cq*mu_can_gen(1,1)-z_cqo_cap(:,1)];
Constraints=[Constraints, 0<=z_cqo(:,1)<=u_cq(:,1)*M];
Constraints=[Constraints, 0<=z_cqo_cap(:,1)<=(1-u_cq(:,1))*M];

%% Operating condition 2
Constraints=[Constraints, P_existing_gen(1,2) + P_can_gen(1,2) == 550];
Constraints=[Constraints, 0 <= P_existing_gen(1,2) <= 400];
Constraints=[Constraints, 0 <= P_can_gen(1,2) <= P_can_max];
Constraints=[Constraints, 35-lamda(1,2)+mu_ex_gen(1,2)>=0];
Constraints=[Constraints, 25-lamda(1,2)+mu_can_gen(1,2)>=0];
Constraints=[Constraints, mu_ex_gen(1,2)>=0];
Constraints=[Constraints, mu_can_gen(1,2)>=0];

Constraints=[Constraints, 35*P_existing_gen(1,2)+25*P_can_gen(1,2)==550*lamda(1,2)-400*mu_ex_gen(1,2)-sum(z_cqo(:,2))];
% Constraints=[Constraints, z_cqo(:,2)== p_cq*mu_can_gen(1,2)-z_cqo_cap(:,2)];
% Constraints=[Constraints, 0<=z_cqo(:,2)<=u_cq(:,1)*M];
% Constraints=[Constraints, 0<=z_cqo_cap(:,2)<=(1-u_cq(:,1))*M];

%% finding optimal solution
ops = sdpsettings('verbose',0,'debug',1);
Solution = optimize(Constraints,Objective,ops)

P_can_max=value(P_can_max)
u_cq=value(u_cq)
P_existing_gen=value(P_existing_gen)
P_can_gen=value(P_can_gen)
lamda=value(lamda)
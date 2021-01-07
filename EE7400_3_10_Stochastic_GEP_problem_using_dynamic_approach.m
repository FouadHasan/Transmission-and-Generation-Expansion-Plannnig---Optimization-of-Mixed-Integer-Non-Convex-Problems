clc
clear classes

%% Read system input
p_cq=[0;100;200;300;400;500];
M = 5000;
investment_per_MW=70000;

Demand=zeros(2,2,4);
Demand(:,:,1)=[212,402;214,407];
Demand(:,:,2)=[212,402;284,539];
Demand(:,:,3)=[281,533;284,539];
Demand(:,:,4)=[281,533;377,715];
%% Define problem variables % time period in row, op con in column
%Primal variable
P_existing_gen = sdpvar(2,2,4,'full'); % Generation
P_can_gen = sdpvar(2,2,4,'full'); % Candidate Generation
P_can_max = sdpvar(2,1,4,'full'); % Candidate Generation maximum
%Dual variable
lamda1=sdpvar(2,2,4,'full');
lamda2=sdpvar(2,2,4,'full');
mu_ex_gen=sdpvar(2,2,4,'full');
mu_can_gen=sdpvar(2,2,4,'full');
%Binary variable
u_cq = binvar(6,2,4,'full');
z_cqo= binvar(6,4,4,'full');
z_cqo_cap= binvar(6,4,4,'full');

%% Building objective function
Objective=0;
for w=1:4
    Objective = Objective + 0.25*[P_can_max(1,1,w)*140000+P_can_max(2,1,w)*70000+...
        6000*(35*P_existing_gen(1,1,w) + 25*P_can_gen(1,1,w)) + 2760*(35*P_existing_gen(1,2,w) + 25*P_can_gen(1,2,w))+... %time period 1
        6000*(35*P_existing_gen(2,1,w) + 25*P_can_gen(2,1,w)) + 2760*(35*P_existing_gen(2,2,w) + 25*P_can_gen(2,2,w))] ;    %time period 2
end
%% constraints
Constraints = [];
for w=1:4
    Constraints=[Constraints, sum(u_cq(:,1,w).*p_cq) == P_can_max(1,1,w)];
    Constraints=[Constraints, sum(u_cq(:,2,w).*p_cq) == P_can_max(2,1,w)];
    Constraints=[Constraints, sum(u_cq(:,1,w)) == 1];
    Constraints=[Constraints, sum(u_cq(:,2,w)) == 1];
end
Constraints=[Constraints,P_can_max(1,1,1)==P_can_max(1,1,2)];
Constraints=[Constraints,P_can_max(1,1,2)==P_can_max(1,1,3)];
Constraints=[Constraints,P_can_max(1,1,3)==P_can_max(1,1,4)];

Constraints=[Constraints,P_can_max(2,1,1)==P_can_max(2,1,2)];
Constraints=[Constraints,P_can_max(2,1,3)==P_can_max(2,1,4)];

for w=1:4
    %% Time period 1, Operating condition 1
    Constraints=[Constraints, P_existing_gen(1,1,w) + P_can_gen(1,1,w) == Demand(1,1,w)];
    Constraints=[Constraints, 0 <= P_existing_gen(1,1,w) <= 400];
    Constraints=[Constraints, 0 <= P_can_gen(1,1,w) <= P_can_max(1,1,w)];
    Constraints=[Constraints, 35-lamda1(1,1,w)+mu_ex_gen(1,1,w)>=0];
    Constraints=[Constraints, 25-lamda2(1,1,w)+mu_can_gen(1,1,w)>=0];
    Constraints=[Constraints, mu_ex_gen(1,1,w)>=0];
    Constraints=[Constraints, mu_can_gen(1,1,w)>=0];
    
    Constraints=[Constraints, 35*P_existing_gen(1,1,w) + 25*P_can_gen(1,1,w)==Demand(1,1,w)*lamda2(1,1,w)-400*mu_ex_gen(1,1,w)-sum(z_cqo(:,1,w))];
    Constraints=[Constraints, z_cqo(:,1,w)== p_cq*mu_can_gen(1,1,w)-z_cqo_cap(:,1,w)];
    Constraints=[Constraints, 0<=z_cqo(:,1,w)<=u_cq(:,1,w)*M];
    Constraints=[Constraints, 0<=z_cqo_cap(:,1,w)<=(1-u_cq(:,1,w))*M];
    
    %% Time period 1,Operating condition 2
    Constraints=[Constraints, P_existing_gen(1,2,w) + P_can_gen(1,2,w) == Demand(1,2,w)];
    Constraints=[Constraints, 0 <= P_existing_gen(1,2,w) <= 400];
    Constraints=[Constraints, 0 <= P_can_gen(1,2,w) <= P_can_max(1,1,w)];
    Constraints=[Constraints, 35-lamda1(1,2,w)+mu_ex_gen(1,2,w)>=0];
    Constraints=[Constraints, 25-lamda2(1,2,w)+mu_can_gen(1,2,w)>=0];
    Constraints=[Constraints, mu_ex_gen(1,2,w)>=0];
    Constraints=[Constraints, mu_can_gen(1,2,w)>=0];
    
    Constraints=[Constraints, 35*P_existing_gen(1,2,w)+25*P_can_gen(1,2,w)==Demand(1,2,w)*lamda2(1,2,w)-400*mu_ex_gen(1,2,w)-sum(z_cqo(:,2,w))];
%     Constraints=[Constraints, z_cqo(:,2)== p_cq*mu_can_gen(1,2)-z_cqo_cap(:,2)];
%     Constraints=[Constraints, 0<=z_cqo(:,2)<=u_cq(:,1)*M];
%     Constraints=[Constraints, 0<=z_cqo_cap(:,2)<=(1-u_cq(:,1))*M];
    
    
    %% Time period 2, Operating condition 1
    Constraints=[Constraints, P_existing_gen(2,1,w) + P_can_gen(2,1,w) == Demand(2,1,w)];
    Constraints=[Constraints, 0 <= P_existing_gen(2,1,w) <= 400];
    Constraints=[Constraints, 0 <= P_can_gen(2,1,w) <= P_can_max(1,1,w) + P_can_max(2,1,w)];% sum of 'P_can_max' in two time period
    Constraints=[Constraints, 35-lamda1(2,1,w)+mu_ex_gen(2,1,w)>=0];
    Constraints=[Constraints, 25-lamda2(2,1,w)+mu_can_gen(2,1,w)>=0];
    Constraints=[Constraints, mu_ex_gen(2,1,w)>=0];
    Constraints=[Constraints, mu_can_gen(2,1,w)>=0];
    
    
    Constraints=[Constraints, 35*P_existing_gen(2,1,w) + 25*P_can_gen(2,1,w)==Demand(2,1,w)*lamda2(2,1,w)-400*mu_ex_gen(2,1,w)-sum(z_cqo(:,3,w))];
    Constraints=[Constraints, z_cqo(:,3,w)== p_cq*mu_can_gen(2,1,w)-z_cqo_cap(:,3,w)];
    Constraints=[Constraints, 0<=z_cqo(:,3,w)<=u_cq(:,2,w)*M];
    Constraints=[Constraints, 0<=z_cqo_cap(:,3,w)<=(1-u_cq(:,2,w))*M];
    
    %% Time period 2,Operating condition 2
    Constraints=[Constraints, P_existing_gen(2,2,w) + P_can_gen(2,2,w) == Demand(2,2,w)];
    Constraints=[Constraints, 0 <= P_existing_gen(2,2,w) <= 400];
    Constraints=[Constraints, 0 <= P_can_gen(2,2,w) <= P_can_max(1,1,w) + P_can_max(2,1,w)];% sum of 'P_can_max' in two time period
    Constraints=[Constraints, 35-lamda1(2,2,w)+mu_ex_gen(2,2,w)>=0];
    Constraints=[Constraints, 25-lamda2(2,2,w)+mu_can_gen(2,2,w)>=0];
    Constraints=[Constraints, mu_ex_gen(2,2,w)>=0];
    Constraints=[Constraints, mu_can_gen(2,2,w)>=0];
    
    Constraints=[Constraints, 35*P_existing_gen(2,2,w)+25*P_can_gen(2,2,w)==Demand(2,2,w)*lamda2(2,2,w)-400*mu_ex_gen(2,2,w)-sum(z_cqo(:,4,w))];
%     Constraints=[Constraints, z_cqo(:,4,w)== p_cq*mu_can_gen(2,2,w)-z_cqo_cap(:,4,w)];
%     Constraints=[Constraints, 0<=z_cqo(:,4,w)<=u_cq(:,2,w)*M];
%     Constraints=[Constraints, 0<=z_cqo_cap(:,4,w)<=(1-u_cq(:,2,w))*M];
end
%% finding optimal solution
ops = sdpsettings('verbose',0,'debug',1);
Solution = optimize(Constraints,Objective,ops)

P_can_max=value(P_can_max)
u_cq=value(u_cq)
P_existing_gen=value(P_existing_gen)
P_can_gen=value(P_can_gen)
value(Objective)
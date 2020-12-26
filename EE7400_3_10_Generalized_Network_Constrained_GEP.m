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
Pline = sdpvar(2,2,4,'full');
Del1 = sdpvar(2,2,4,'full');
Del2 = sdpvar(2,2,4,'full');
%Dual variable
lamda1=sdpvar(2,2,4,'full');
lamda2=sdpvar(2,2,4,'full');
mu_ex_gen=sdpvar(2,2,4,'full');
mu_can_gen=sdpvar(2,2,4,'full');
mu_line=sdpvar(2,2,4,'full');
mu_line_max=sdpvar(2,2,4,'full');
mu_line_min=sdpvar(2,2,4,'full');
mu_del1_max=sdpvar(2,2,4,'full');
mu_del1_min=sdpvar(2,2,4,'full');
mu_del2_max=sdpvar(2,2,4,'full');
mu_del2_min=sdpvar(2,2,4,'full');
mu_del_ref=sdpvar(2,2,4,'full');
%Binary variable
u_cq = binvar(6,2,4,'full');
z_cqo= binvar(6,4,4,'full');
z_cqo_cap= binvar(6,4,4,'full');

sigma=[6000,2760];
inv_cost=[140000,70000];
%% Building objective function
Objective=0;
for w=1:4    
    for t=1:2
        Objective = Objective + 0.25*P_can_max(t,1,w)*inv_cost(t); % investment cost
        for op=1:2
            Objective=Objective+sigma(op)*0.25*(35*P_existing_gen(t,op,w) + 25*P_can_gen(t,op,w)); % operating cost
        end
    end
end 

%% constraints
Constraints = [];
Constraints=[Constraints,P_can_max(1,1,1)==P_can_max(1,1,2)];
Constraints=[Constraints,P_can_max(1,1,2)==P_can_max(1,1,3)];
Constraints=[Constraints,P_can_max(1,1,3)==P_can_max(1,1,4)];

Constraints=[Constraints,P_can_max(2,1,1)==P_can_max(2,1,2)];
Constraints=[Constraints,P_can_max(2,1,3)==P_can_max(2,1,4)];

for w=1:4
    for t=1:2
        Constraints=[Constraints, sum(u_cq(:,t,w).*p_cq) == P_can_max(t,1,w)];
        Constraints=[Constraints, sum(u_cq(:,t,w)) == 1];
        for op=1:2
            %% Scenario w, Time period t, Operating condition op
            Constraints=[Constraints, P_existing_gen(t,op,w) - Pline(t,op,w) == 0];
            Constraints=[Constraints, P_can_gen(t,op,w) + Pline(t,op,w) == Demand(t,op,w)];
            Constraints=[Constraints, Pline(t,op,w) == 500*(Del1(t,op,w)-Del2(t,op,w))];
            Constraints=[Constraints, -500 <= Pline(t,op,w) <= 500];
            Constraints=[Constraints, P_existing_gen(t,op,w) + P_can_gen(t,op,w) == Demand(t,op,w)];
            Constraints=[Constraints, 0 <= P_existing_gen(t,op,w) <= 400];
            Constraints=[Constraints, 0 <= P_can_gen(t,op,w) <= sum(P_can_max(1:t,1,w))];%%
            Constraints=[Constraints, -pi <= Del2(t,op,w) <= pi];
            Constraints=[Constraints, Del1(t,op,w) == 0];
            
            Constraints=[Constraints, 35-lamda1(t,op,w)+mu_ex_gen(t,op,w)>=0];
            Constraints=[Constraints, 25-lamda2(t,op,w)+mu_can_gen(t,op,w)>=0];            
            Constraints=[Constraints, lamda1(t,op,w)-lamda2(t,op,w)-mu_line(t,op,w)+mu_line_max(t,op,w)-mu_line_min(t,op,w)==0];
            Constraints=[Constraints, -500*mu_line(t,op,w)+mu_del2_max(t,op,w)-mu_del2_min(t,op,w)==0];
            Constraints=[Constraints, 500*mu_line(t,op,w)+ mu_del_ref(t,op,w)==0];
            
            Constraints=[Constraints, mu_ex_gen(t,op,w)>=0];
            Constraints=[Constraints, mu_can_gen(t,op,w)>=0];            
            Constraints=[Constraints, mu_line_max(t,op,w)>=0];
            Constraints=[Constraints, mu_line_min(t,op,w)>=0];
            Constraints=[Constraints, mu_del1_max(t,op,w)>=0];
            Constraints=[Constraints, mu_del1_min(t,op,w)>=0];
            
            Constraints=[Constraints, 35*P_existing_gen(t,op,w) + 25*P_can_gen(t,op,w)==Demand(t,op,w)*lamda2(t,op,w)-400*mu_ex_gen(t,op,w)-sum(z_cqo(:,2*t-2+op,w))-...
                500*(mu_line_max(t,op,w)+mu_line_min(t,op,w)) - pi*(mu_del2_max(t,op,w)+mu_del2_min(t,op,w))];
            
            Constraints=[Constraints, z_cqo(:,2*t-2+op,w)== p_cq*mu_can_gen(t,op,w)-z_cqo_cap(:,2*t-2+op,w)];
            Constraints=[Constraints, 0<=z_cqo(:,2*t-2+op,w)<=u_cq(:,t,w)*M];
            Constraints=[Constraints, 0<=z_cqo_cap(:,2*t-2+op,w)<=(1-u_cq(:,t,w))*M];            
        end
    end
end

%% finding optimal solution
ops = sdpsettings('verbose',0,'debug',1);
Solution = optimize(Constraints,Objective,ops)

P_can_max=value(P_can_max)
u_cq=value(u_cq)
P_existing_gen=value(P_existing_gen)
P_can_gen=value(P_can_gen)
value(Objective)
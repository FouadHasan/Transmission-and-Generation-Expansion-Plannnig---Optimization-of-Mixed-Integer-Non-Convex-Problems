clc
clear all

Demand=zeros(2,2,4);
Demand(:,:,1)=[212,402;214,407];
Demand(:,:,2)=[212,402;284,539];
Demand(:,:,3)=[281,533;284,539];
Demand(:,:,4)=[281,533;377,715];
%% Define problem variables
% Primal variable
P_existing_gen = sdpvar(2,2,4,'full'); % Generation
P_can_gen = sdpvar(2,2,4,'full'); % Candidate Generation
P_can_max = sdpvar(2,1,4,'full'); % Candidate Generation maximum
Pline = sdpvar(2,2,4,2,'full'); % Lines in the 3rd index
Del = sdpvar(2,2,4,2,'full'); % Nodes in the 3rd index
x_BS = binvar(2,1,4,'full'); % Prospective_branch_status
P_LS = sdpvar(2,2,4,'full'); % Load shedding amount
M=5000;

%% Building objective function
Objective=0;
% for w=1:4
%     Objective= 0.25*(P_can_max(1,1,w)*140000+x_BS(1,1,w)*200000+...    P_can_gen = sdpvar(1,2,2,'full'); 
%                      P_can_max(2,1,w)*70000+x_BS(2,1,w)*100000+...
%                      6000*(35*P_existing_gen(1,1,w)+25*P_can_gen(1,1,w)+80*P_LS(1,1,w))+...
%                      2760*(35*P_existing_gen(1,2,w)+25*P_can_gen(1,2,w)+80*P_LS(1,2,w))+...
%                      6000*(35*P_existing_gen(2,1,w)+25*P_can_gen(2,1,w)+80*P_LS(2,1,w))+...
%                      2760*(35*P_existing_gen(2,2,w)+25*P_can_gen(2,2,w)+80*P_LS(2,2,w)));
% end

sigma=[6000,2760];
gen_inv_cost=[140000,70000];
line_inv_cost=[200000,100000];
for w=1:4    
    for t=1:2
        Objective = Objective + 0.25*P_can_max(t,1,w)*gen_inv_cost(t)+0.25*x_BS(t,1,w)*line_inv_cost(t); % investment cost
        for op=1:2
            Objective=Objective+sigma(op)*0.25*(35*P_existing_gen(t,op,w) + 25*P_can_gen(t,op,w)+80*P_LS(t,op,w)); % operating cost
        end
    end
end

Constraints=[];
Constraints=[Constraints,P_can_max(1,1,1)==P_can_max(1,1,2)];
Constraints=[Constraints,P_can_max(1,1,2)==P_can_max(1,1,3)];
Constraints=[Constraints,P_can_max(1,1,3)==P_can_max(1,1,4)];
Constraints=[Constraints,P_can_max(2,1,1)==P_can_max(2,1,2)];
Constraints=[Constraints,P_can_max(2,1,3)==P_can_max(2,1,4)];

Constraints=[Constraints,x_BS(1,1,1)==x_BS(1,1,2)];
Constraints=[Constraints,x_BS(1,1,2)==x_BS(1,1,3)];
Constraints=[Constraints,x_BS(1,1,3)==x_BS(1,1,4)];
Constraints=[Constraints,x_BS(2,1,1)==x_BS(2,1,2)];
Constraints=[Constraints,x_BS(2,1,3)==x_BS(2,1,4)];


for w=1:4
    Constraints=[Constraints, 0<=sum(P_can_max(1:2,1,w))<=300];
    Constraints=[Constraints, sum(x_BS(1:2,1,w))<=1];
    Constraints=[Constraints, x_BS(1,1,w)*1000000<=2*1000000];
    Constraints=[Constraints, P_can_max(1,1,w)*700000<=400*1000000];
    Constraints=[Constraints, x_BS(2,1,w)*1000000<=2*1000000];
    Constraints=[Constraints, P_can_max(2,1,w)*700000<=400*1000000];
    
    for t=1:2
        for op=1:2
            Constraints=[Constraints, P_existing_gen(t,op,w)-Pline(t,op,w,1)-Pline(t,op,w,2)==0];
            Constraints=[Constraints, P_can_gen(t,op,w)+Pline(t,op,w,1)+Pline(t,op,w,2)==Demand(t,op,w)-P_LS(t,op,w)];
            Constraints=[Constraints, Pline(t,op,w,1)==500*(Del(t,op,w,1)-Del(t,op,w,2))];
            Constraints=[Constraints, -200<=Pline(t,op,w,1)<=200];
            Constraints=[Constraints, -200*sum(x_BS(1:t,1,w))<=Pline(t,op,w,2)<=200*sum(x_BS(1:t,1,w))];
            Constraints=[Constraints, -(1-sum(x_BS(1:t,1,w)))*M<=Pline(t,op,w,2)-500*(Del(t,op,w,1)-Del(t,op,w,2))<=(1-sum(x_BS(1:t,1,w)))*M];
            % Constraints=[Constraints, -200<=Pline(2,1)<=200];
            Constraints=[Constraints, 0<=P_existing_gen(t,op,w)<=400];
            Constraints=[Constraints, 0<=P_can_gen(t,op,w)<=sum(P_can_max(1:t,1,w))];
            Constraints=[Constraints, 0<=P_LS(t,op,w)<=Demand(t,op,w)];
            Constraints=[Constraints, -pi<=Del(t,op,w,2)<=pi];
            Constraints=[Constraints, Del(t,op,w,1)==0];            
        end
    end
end

%% finding optimal solution (optimal=building 290MW and line 2, cost 109.03M)
ops = sdpsettings('verbose',0,'debug',1);
Solution = optimize(Constraints,Objective,ops)
% optimal cost=203554350
Total_cost=value(Objective)
x_BS=value(x_BS)
P_can_max=value(P_can_max)
P_existing_gen=value(P_existing_gen)
P_can_gen=value(P_can_gen)
P_LS=value(P_LS)
value(Objective)


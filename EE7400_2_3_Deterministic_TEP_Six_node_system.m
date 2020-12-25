clc
clear classes    

%% Read system input
GenData=[
1	300	18
2	250	25
3	400	16
4	300	32
6	150	35
];

BranchData=[
1	2	500	150	0
1	3	500	150	0
4	5	500	150	0
2	3	500	150	700000
2	4	500	200	1400000
3	4	500	200	1800000
3	6	500	200	1600000
4	6	500	150	800000
5	6	500	150	700000
];

Demand=[
1	200	40
4	150	52
5	100	55
6	200	65
];

Nbus = 6;
Nbranch=9;
Nunits = 5;
Nloads = 4;
n_prospective_branch = 6;
M = 5000;
ReferenceBus = 1;

Total_budget=3*1000000;
sigma = 8760;%total hours

Pmax = GenData(:,2);
Gencost = GenData(:,3);
branch_investment_cost=BranchData(4:end,5);
Load_shedding_cost=Demand(:,3);

%% Define problem variables
P_gen = sdpvar(Nunits,1,'full'); % Generation
x_BS = binvar(n_prospective_branch,1,'full'); %Prospective_branch_status
P_LS = sdpvar(Nloads,1,'full');%Load shedding amount
Del = sdpvar(Nbus,1,'full'); % Bus voltage angle
P_line = sdpvar(Nbranch,1,'full');% Line flows

% Other temporary variable
P_gen_node=sdpvar(Nbus,1,'full');
P_gen_node(GenData(:,1),1)=P_gen;
P_gen_node(5,1)=0;% forcing non-gen buses to be zero.
P_LS_node=sdpvar(Nbus,1,'full');
P_LS_node(Demand(:,1),1)=P_LS;
P_LS_node(2:3,1)=0;% forcing non-load buses to be zero.

P_dem_node=zeros(Nbus,1);
P_dem_node(Demand(:,1),1)=Demand(:,2);
%% Bus to Line incidence matrix
Kl = zeros(Nbus,Nbranch);
for j = 1:Nbranch
    Kl(BranchData(j,1),j) = 1;
    Kl(BranchData(j,2),j) = -1;
end

%% Objective and constraints
Objective= sum(x_BS.*branch_investment_cost)+sigma*(sum(P_gen.*Gencost) + sum(P_LS.*Load_shedding_cost));

Constraints = [];
Constraints=[Constraints, sum(x_BS.*branch_investment_cost) <= Total_budget];
Constraints = [Constraints, P_gen_node-P_dem_node+P_LS_node == Kl*P_line];
P_line(1:3,1)=(Del(BranchData(1:3,1))-Del(BranchData(1:3,2))).*BranchData(1:3,3);
Constraints = [Constraints, -BranchData(1:3,4) <= P_line(1:3,1) <= BranchData(1:3,4)];
Constraints = [Constraints, -x_BS.*BranchData(4:end,4) <= P_line(4:end,1) <= x_BS.*BranchData(4:end,4)];
Constraints = [Constraints, -(1-x_BS)*M <= P_line(4:end,1) - (Del(BranchData(4:end,1))-Del(BranchData(4:end,2))).*BranchData(4:end,3)<=(1-x_BS)*M];
Constraints = [Constraints, 0 <= P_gen <= Pmax];
Constraints = [Constraints, 0 <= P_LS <= Demand(:,2)];
Constraints = [Constraints, -pi <= Del(2:end,1) <= pi];
Constraints = [Constraints, Del(ReferenceBus,1)== 0];

%% Building objective function and finding optimal solution
ops = sdpsettings('verbose',0,'debug',1);
Solution = optimize(Constraints,Objective,ops)

Branch_to_be_built= find(value(x_BS))+3
% disp('True Optimal Solution: Building lines 5 and 7, i.e., lines connecting nodes 2-4 and 3-6')
Total_cost=value(Objective)
% P_gen=value(P_gen)
% P_LS=value(P_LS)
% Del=value(Del)
% P_gen_node=value(P_gen_node)
% P_LS_node=value(P_LS_node)
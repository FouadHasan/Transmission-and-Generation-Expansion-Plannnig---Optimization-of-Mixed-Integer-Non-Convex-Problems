clc
clear all

cost=[240e3;270e3;300e3;360e3;450e3;240e3;270e3;300e3;360e3;450e3;240e3;270e3;300e3;360e3;450e3];
Demand=[2000,2400;2000,2400;2000,2400;2000,2400;2000,2400;2250,2700;2250,2700;2250,2700;2250,2700;2250,2700;...
    2500,3000;2500,3000;2500,3000;2500,3000;2500,3000];
beta=[0.1,1,1.5,5,10];


for i=1:length(beta)
    P_can_max=sdpvar(2,1,15,'full');
    P_esixting_gen=sdpvar(2,2,15,'full');
    P_can_gen=sdpvar(2,1,15,'full');
    jita=sdpvar(1,1,'full');
    ita=sdpvar(15,1,'full');
    
    Objective1=0;
    Objective2=0;
    for w=1:15
        Objective1=Objective1+(1/15)*(8760*(14*(P_esixting_gen(1,1,w)+P_esixting_gen(2,1,w))+...
            20*(P_esixting_gen(1,2,w)+P_esixting_gen(2,2,w))+...
            15*(P_can_gen(1,1,w)+P_can_gen(2,1,w)))+...
            (0.3*300000)*P_can_max(1,1,w)+0.15*cost(w)*P_can_max(2,1,w));
        
        Objective2=Objective2+(1/(1-0.8))*(1/15)*ita(w,1);
    end
    
    Objective2=-beta(i)*(jita-Objective2);
    Objective=Objective1+Objective2;
    
    
    Constraints=[];
    for w=1:14
        Constraints=[Constraints, P_can_max(1,1,w)==P_can_max(1,1,w+1)];
    end
    for w=1:15
        Constraints=[Constraints, 0<=P_can_max(1,1,w)<=1500];
        Constraints=[Constraints, 0<=P_can_max(2,1,w)<=1500];
        
        Constraints=[Constraints,P_esixting_gen(1,1,w)+P_esixting_gen(1,2,w)+P_can_gen(1,1,w)==Demand(w,1)];
        Constraints=[Constraints,P_esixting_gen(2,1,w)+P_esixting_gen(2,2,w)+P_can_gen(2,1,w)==Demand(w,2)];
        
        Constraints=[Constraints, 0<=P_esixting_gen(1,1,w)<=1000];
        Constraints=[Constraints, 0<=P_esixting_gen(2,1,w)<=1000];
        Constraints=[Constraints, 0<=P_esixting_gen(1,2,w)<=800];
        Constraints=[Constraints, 0<=P_esixting_gen(2,2,w)<=800];
        Constraints=[Constraints, 0<=P_can_gen(1,1,w)<=P_can_max(1,1,w)];
        Constraints=[Constraints, 0<=P_can_gen(2,1,w)<=P_can_max(1,1,w)+P_can_max(2,1,w)];
        
        Constraints=[Constraints, jita+(8760*(14*(P_esixting_gen(1,1,w)+P_esixting_gen(2,1,w))+...
            20*(P_esixting_gen(1,2,w)+P_esixting_gen(2,2,w))+...
            15*(P_can_gen(1,1,w)+P_can_gen(2,1,w)))+...
            (0.3*300000)*P_can_max(1,1,w)+0.15*cost(w)*P_can_max(2,1,w))<=ita(w,1)];
        Constraints=[Constraints, ita(w)>=0];
        
    end
    Solution=optimize(Constraints,Objective)
    
    P_can_max=value(P_can_max)
    Obj1(i)=value(Objective1);
    Obj2(i)=value(Objective2);
    clearvars -except cost Demand beta Obj1 Obj2    
end

figure()
plot(Obj2, Obj1)
function [symdata]=SBML2HYB

    project=hybdata('parkramirez_201209.hmod.txt','parkram');
    
    totalsyms=["t"];
    for n=1:project.nspecies
        totalsyms=[totalsyms,project.species(n).id];
    end
    for n=1:project.ncompartments
        totalsyms=[totalsyms,project.compartments(n).id];
    end
    for n=1:project.nparameters
        totalsyms=[totalsyms,project.parameters(n).id];
    end
    for n=1:project.nruleAss
        totalsyms=[totalsyms,project.ruleAss(n).id];
    end
    for n=1:project.nreaction
        totalsyms=[totalsyms,project.reaction(n).id];
    end

    syms(totalsyms)
    
    symdata.nspecies=project.nspecies;
    symdata.species=[];
    
    for n=1:project.nspecies
        symdata.species=[symdata.species;str2sym(project.species(n).id)];
    end
    
    symdata.ncompartments=project.ncompartments;
    symdata.compartments=[];
    
    for n=1:project.ncompartments
        symdata.compartments=[symdata.compartments;str2sym(project.compartments(n).id)];
    end
    
    for n=1:project.nfunctions
        if project.functions(n).id=="CreateMLP"
            tempANN=eval(project.functions(n).inputarguments);
        end
         
        fun=strcat(tempANN.id,'=',"tempANN");
        eval(fun);
        
        for m=1:length(tempANN.outid)
            fun=strcat(tempANN.outid(m),'=',"tempANN.outputs(m)");
            eval(fun);
        end
    end
    
    for n=1:project.nfunctions
        if project.functions(n).id=="CreatePWCController"
            tempcontrol=eval(project.functions(n).inputarguments);
            syms(tempcontrol.vars(1).id);
            for m=1:length(tempcontrol.nvars)
                symids=eval('sym(tempcontrol.vars(m).id,[length(tempcontrol.vars(m).tseries-1),1])');
                syms(symids);
                fun='piecewise(';
                for i=1:length(tempcontrol.vars(m).tseries)-1
                    if i==1
                        fun=strcat(fun,num2str(tempcontrol.vars(m).tseries(i)),'<=t<',num2str(tempcontrol.vars(m).tseries(i+1)),',',tempcontrol.vars(m).id,num2str(i));
                    else
                        fun=strcat(fun,',',num2str(tempcontrol.vars(m).tseries(i)),'<=t<',num2str(tempcontrol.vars(m).tseries(i+1)),',',tempcontrol.vars(m).id,num2str(i));
                    end   
                end
                fun=strcat(fun,')');
                tempcontrol.vars(m).cfun=eval(fun);
                fun=strcat(tempcontrol.vars(m).id,'=tempcontrol.vars(m).cfun');
                eval(fun);
            end
            fun=strcat(tempcontrol.id,'=',"tempcontrol");
            eval(fun);
        end
    end
    
    for n=1:project.nparameters
        fun=strcat(project.parameters(n).id,'=',project.parameters(n).val);
        eval(fun);
    end
    
    for n=1:project.nruleAss
        fun=strcat(project.ruleAss(n).id,'=',project.ruleAss(n).val);
        eval(fun);
    end

    stoichm=[];
    
    for n=1:project.nreaction
        reaction(n,1)=eval(project.reaction(n).rate);
        stoichm=[stoichm;str2sym(project.reaction(n).Y)];
    end
                
    for n=1:project.nraterule
        rates(n)= eval(project.raterule(n).val);
        ratevars(n)= str2sym(project.raterule(n).id);
    end
    
    
    for n=1:project.nspecies
        odes(n,1)=sum(reaction.*stoichm(:,n))-rates(1)/ratevars(1)*str2sym(project.species(n).id);
    end
    
    
    Species=symdata.species;
    Compartments=symdata.compartments;
    
    dSpecies_dt = odes;
    dCompartments_dt = rates;
    
    state = [Species; Compartments]; 
    state_odes = [dSpecies_dt; dCompartments_dt];
    
    
    %%%%%%%%%%%%%%%BEFORE HERE WORKING, FINAL VERSION%%%%%%%%
    %%%%%%%%%%%%%%%FROM HERE ON WORKING ON PREVIOUS VERSION, MIGHT REQUIRE FURTHER ADAPTATIONS%%%%%%%%%%%%%%%%%%%%

    nspecies=symdata.nspecies
    Feeds=Control1.vars.vals
  

%JACOBIAN
DstateDFeed = sym('DstateDFeed',[nspecies+1,1]);
DfDstate = jacobian(state_odes,state);
DfDfeed = jacobian(state_odes,Feeds);
DfDfeed=sum(DfDfeed,2);
d_DstateDFeed_dt = DfDstate*DstateDFeed + DfDfeed;

%HESSIAN
% Hsf = sym('Hsf',[(nspecies+1)*ncontrol,nspecies+1]);
% ddt_Hsf = sym('ddt_Hsf',[(nspecies+1)*ncontrol,nspecies+1]);
% for k=1:ncontrol
%     for i=1:nspecies+1
%         for j=1:nspecies+1
%             Dstate = jacobian(d_DstateDFeed_dt(i),state(j));
%             Du = jacobian(d_DstateDFeed_dt(i),ucontrol(k));
%             ddt_Hsf((k-1)*(nspecies+1)+i,j) = Dstate*Hsf((k-1)*(nspecies+1)+i,j) + Du;
%         end
%     end
% end
% fprintf('symbolic ODEs elapsed time: %f\n',cputime-t0);
% matlabFunction(state_odes,d_DstateDFeed_dt,ddt_Hsf,'file',...
%     'auto_control.m',...
%     'vars',{t,state,DstateDFeed,Hsf,ucontrol},...
%     'outputs',{'ddt_State','ddt_Jacobian','ddt_Hessian'});
% fprintf('SAVING elapsed time: %f\n',cputime-t0);     

end

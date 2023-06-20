function projhyb=createhybmod(projhyb)
%
% JOSÉ PINTO CONVERTS projhyb stryucture into symploc function
%
if isfield(projhyb,'symbolicfunc')
    [t, State, fState, rates, anninp, rann, ucontrol]=feval(projhyb.symbolicfunc,projhyb);
else
    [t, State, fState, rates, anninp, rann, ucontrol]=hmod2symb(projhyb); 
end
%
%  
%
switch lower(projhyb.symbolic)
    case 'full-symbolic';
        projhyb=genetare_fullsymbolic_hybmod(projhyb, t, State, fState, ...
                rates, rann, ucontrol,w);
        projhyb.mlmsetwfunc=[];
    case 'semi-symbolic';
        projhyb=genetare_semisymbolic_hybmod(projhyb, t, State, fState, ...
            rates, anninp, rann, ucontrol);
        switch lower(projhyb.mlm.id)
            case 'user-defined'
                assert(~isempty(projhyb.mlm.yfun),'UNKNOWN Machine Learning user-defined-function');
                projhyb.mlmsetwfunc=[];
            case 'mlpnet'
                ind=find(strcmp('hidden nodes',projhyb.mlm.options),true);
                nh=cell2mat(projhyb.mlm.options(ind(1)+1));
                h=length(nh);
                projhyb.mlm.fundata=mlpnetcreate(projhyb.mlm.nx,projhyb.mlm.ny,h,nh,projhyb.mlm.layer);%,neuron)
                projhyb.mlm.nw=projhyb.mlm.fundata.nw;
                projhyb.mlm.w=projhyb.mlm.fundata.w;
                projhyb.mlm.yfun=projhyb.mlm.fundata.fun;
                projhyb.mlmsetwfunc=str2func('mlpnetsetw'); %set weigths 
            otherwise
                assert(false,'UNKNOWN Machine Learning Method: %s',projhyb.mlm.id);
        end

 
  otherwise
        assert(false,'UNKNOWN symbolic class: %s',projhyb.symbolic);
end
%
% the following operations are automatic initialization
% operations---------
%

switch lower(projhyb.symbolic)
    case 'full-symbolic'
      projhyb.fun_hybodes=projhyb.userdefun_hybodes;
      projhyb.fun_hybodes_jac =projhyb.userdefun_hybodes_jac;
      projhyb.fun_hybodes_jac_hess=projhyb.userdefun_hybodes_jac_hess;
      projhyb.fun_hybrates=projhyb.userdefun_hybrates;
      projhyb.fun_hybrates_jac=projhyb.userdefun_hybrates_jac;
    case 'semi-symbolic'
      projhyb.fun_hybodes=str2func('hybodesfun');   
      projhyb.fun_hybodes_jac =str2func('hybodesfun');
      projhyb.fun_hybodes_jac_hess=str2func('hybodesfun');
      projhyb.fun_hybrates=str2func('hybrates');
      projhyb.fun_hybrates_jac=str2func('hybrates');  
    otherwise
      assert(false,'UNKNOWN SYMBOLIC TYPE: hybrid model must be either ''full-symbolic'' or ''semi-symbolic''');  
end
% index of variables to minimize
count=0;
projhyb.isres=[];
projhyb.isresstate=[];
for i=1:projhyb.nspecies
    if projhyb.species(i).isres==1
        count=count+1;
        projhyb.isres(end+1)=count;
        projhyb.isresstate(end+1)=count;
    end
end
for i=1:projhyb.ncompartments
    if projhyb.compartment(i).isres==1
        count=count+1;
        projhyb.isres(end+1)=count;
    end
end
for i=1:projhyb.nraterules
    if projhyb.raterules(i).isres==1
        count=count+1;
        projhyb.isres(end+1)=count;
    end
end
projhyb.nres=count;
projhyb.nstate=projhyb.nspecies+projhyb.nraterules; %projhyb.nspecies+projhyb.compartments+projhyb.nraterules. Rate rules include non constant compartments, no need for projhyb.compartments
end
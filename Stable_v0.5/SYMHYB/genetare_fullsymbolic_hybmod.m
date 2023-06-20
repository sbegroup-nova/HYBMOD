function projhyb=genetare_fullsymbolic_hybmod(projhyb,t, State, fState, ...
    rates, rann, ucontrol,w)
nstate = length(State);
nw = length(w);

%--------------------------------------------------------------------------
% FULL-SYMBOLIC
%--------------------------------------------------------------------------
projhyb.userdefun_hybodes=sprintf('%s_odes.m',projhyb.id);
projhyb.userdefun_hybodes_jac =sprintf('%s_odes_jac.m',projhyb.id);
projhyb.userdefun_hybodes_jac_hess=sprintf('%s_odes_jac_hess.m',projhyb.id);
projhyb.userdefun_hybrates=sprintf('%s_kinetics.m',projhyb.id);
projhyb.userdefun_hybrates_jac=sprintf('%s_kinetics_jac.m',projhyb.id);
        
%1)rates function
matlabFunction(rates, rann,'file',projhyb.userdefun_hybrates,...
    'vars',{t,[State],[w],[ucontrol],[dummyarg1]})

%2) rates functions with sensitivities
DrDs = jacobian(rates,State);
DrDw = jacobian(rates,w);
matlabFunction(rates, rann, DrDs, DrDw,'file',...
    projhyb.userdefun_hybrates_jac,...
    'vars',{t,[State],[w],[ucontrol],[dummyarg1]})

%3) ODEs function of state ------------------------------------------------
matlabFunction(fState,dummyarg1,dummyarg2,'file',projhyb.userdefun_hybodes,...
    'vars',{t,[State],[dummyarg1],[dummyarg2],[w],[ucontrol],[dummyarg3]})

%4A) ODEs function with Jacobain of ANN weights-----------------------------
t0=cputime;
Jw = sym('Jw',[nstate,nw]);
DfDs = jacobian(fState,State);
DfDw = jacobian(fState,w);
dJwdt = DfDs*Jw + DfDw;
matlabFunction(fState,dJwdt,dummyarg2,'file',...
    projhyb.userdefun_hybodes_jac,...
    'vars',{t,[State],[Jw],[dummyarg2],[w],[ucontrol],[dummyarg3]})


%5) ODEs function with jacobian and hessian of ANN weights
Hw = [];
for i=1:nstate
    HessW(i).Hw = sym(sprintf('Hw_%u_%u_',i,i),[nw,nw]);
    HessW(i).dHwdt = sym(sprintf('dHwdt_%u_%u_',i,i),[nw,nw]);
    Hw = [Hw;HessW(i).Hw];
end
dHwdt=[];
for k1=1:nstate
    g = dJwdt(k1, :);   %1*nw
    DgDs = jacobian(g,State);   %nw*ns
    DgDJw = jacobian(g,Jw); %ns*nw
    DgDw = jacobian(g,w); %1*nw   
    HessW(k1).dHwdt(1:nw,1:nw) = DgDs*Jw + DgDw;
    for k2=1:nstate
        HessW(k1).dHwdt(1:nw,1:nw) = HessW(k1).dHwdt(1:nw,1:nw)+jacobian(g,Jw(k2,:))*HessW(k2).Hw;
    end
    dHwdt = [dHwdt;HessW(k1).dHwdt];
end
matlabFunction(fState,dJwdt,dHwdt,'file',...
    projhyb.userdefun_hybodes_jac_hess,...
    'vars',{t,State,Jw,Hw,w,ucontrol,dummyarg3},...
    'outputs',{'ddt_State','ddt_Jacobian','ddt_Hessian'})

projhyb.userdefun_hybodes=str2func('%s_odes',projhyb.id);
projhyb.userdefun_hybodes_jac =str2func('%s_odes_jac',projhyb.id);
projhyb.userdefun_hybodes_jac_hess=str2func('%s_odes_jac_hess',projhyb.id);
projhyb.userdefun_hybrates=str2func('%s_kinetics',projhyb.id);
projhyb.userdefun_hybrates_jac=str2func('%s_kinetics_jac',projhyb.id);
end

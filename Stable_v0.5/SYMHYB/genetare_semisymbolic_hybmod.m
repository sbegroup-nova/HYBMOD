function projhyb=genetare_semisymbolic_hybmod(projhyb, t, State, fState, ...
    rates, anninp, rann, ucontrol)

%--------------------------------------------------------------------------
% FROM NOW ON AUTOMATIC
%--------------------------------------------------------------------------
% SEMI-SYMBOLIC
%--------------------------------------------------------------------------

projhyb.userdefun_parametric_kinetic=sprintf('%s_kinetics.m',projhyb.id);
projhyb.userdefun_parametric_odes=sprintf('%s_odes.m',projhyb.id);
projhyb.mlm.xfun=sprintf('%s_anninps.m',projhyb.id); %generated automatically

%1)ann inputs function
DanninpDstate=jacobian(anninp,State);
DanninpDucontrol=jacobian(anninp,ucontrol);
matlabFunction(anninp,DanninpDstate,DanninpDucontrol,'file',projhyb.mlm.xfun,...
    'vars',{t,[State],[ucontrol]})

%2) rates functions with sensitivities
DrDs = jacobian(rates,State);
DrDrann = jacobian(rates,rann);
matlabFunction(rates, DrDs, DrDrann,'file',...
    projhyb.userdefun_parametric_kinetic,...
    'vars',{t,[State],[rann],[ucontrol]})
 
%3) ODEs function with Jacobain of ANN weights
DfDs = jacobian(fState,State);
DfDrann = jacobian(fState,rann);
matlabFunction(fState,DfDs,DfDrann,'file',...
    projhyb.userdefun_parametric_odes,...
    'vars',{t,[State],[rann],[ucontrol]})

projhyb.userdefun_parametric_kinetic=str2func(sprintf('%s_kinetics',projhyb.id));
projhyb.userdefun_parametric_odes=str2func(sprintf('%s_odes',projhyb.id));
projhyb.mlm.xfun=str2func(sprintf('%s_anninps',projhyb.id)); %generated automatically
end

function [fstate, fjac, fhess]=hybodesfun(t,state,jac,hess,w,ucontrol,projhyb)
% HYBODESFUN computes the time derivative of state,jacoban and hessian
%
%[fstate, fjac, fhess] = HYBODESFUN(t,state,jac,hess,w,ucontrol,projhyb)
%
% INPUT ARGUMENTS
% projhyb           Data strtucture holding information of the hybrid model, 
%                   data and traning method
% t                 current time (scalar)
% state             vector of state variables (ns*1)
% jac               matrix of sensitivities (ns*nw)
% hess              matrix of second order sensitivities (ns*(nw*nw))
%
% OUTPUT ARGUMENTS
% fstate            vector of state variables time derivatives (ns*1)
% jac               matrix of sensitivities time derivatives (ns*nw)
% hess              matrix of second order sensitivities time derivatives (ns*(nw*nw))
%
% Copyright, 2020 -
% This M-file and the code in it belongs to the holder of the
% copyrights and is made public under the following constraints:
% It must not be changed or modified and code cannot be added.
% The file must be regarded as read-only.
% In case of doubt, contact the holder of the copyrights.
%
% AUTHORS: Rui Oliveira
%
% Copyright holder:
%
% Rui Oliveira
% Faculdade de Ciências e Tecnologia
% Universidade Nova de Lisboa]
% DQ/FCT/UNL 6º piso
% P-2829-516 Caparica, Portugual
% Phone  +351 212948356
% Fax    +351 212948385
% E-mail rmo@fct.unl.pt
%
% $ Version 10.00 $ Date November 2020 $ Not compiled $
if nargout==1
    [anninp] = feval(projhyb.mlm.xfun,t,state,ucontrol);
    [rann] =   feval(projhyb.mlm.yfun,anninp,w,projhyb.mlm.fundata);
    fstate =   feval(projhyb.userdefun_parametric_odes,t,state,rann,ucontrol);
    fjac=[];
    fhess=[];
elseif nargout==2 
    if projhyb.mode==1 %indirect
        [anninp,DanninpDstate] = feval(projhyb.mlm.xfun,t,state,ucontrol);
        [rann,DrannDanninp,DrannDw] =feval(projhyb.mlm.yfun,anninp,w,projhyb.mlm.fundata);
        [fstate,DfDs,DfDrann] = feval(projhyb.userdefun_parametric_odes,t,state,rann,ucontrol);
        DrannDs = DrannDanninp*DanninpDstate;
        fjac = (DfDs+DfDrann*DrannDs)*jac + DfDrann*DrannDw;
        fhess=[];
    elseif projhyb.mode==3   %semidirect
        [anninp] = feval(projhyb.mlm.xfun,t,state,ucontrol);
        [rann] =feval(projhyb.mlm.yfun,anninp,w,projhyb.mlm.fundata);
        [fstate,DfDs,DfDrann] = feval(projhyb.userdefun_parametric_odes,t,state,rann,ucontrol);
        fjac = DfDs*jac+DfDrann;
        fhess = [];
    end
elseif nargout==3
    [anninp,DanninpDstate] = feval(projhyb.mlm.xfun,t,state,ucontrol);
    [rann,DrannDanninp,DrannDw] =feval(projhyb.mlm.yfun,anninp,w,projhyb.mlm.fundata);
    DrannDs = DrannDanninp*DanninpDstate;
    [fstate,DfDs,DfDrann] = feval(projhyb.userdefun_parametric_odes,t,state,rann,ucontrol);
    fjac = (DfDs+DfDrann*DrannDs)*jac + DfDrann*DrannDw;
    fhess=[];
end
end
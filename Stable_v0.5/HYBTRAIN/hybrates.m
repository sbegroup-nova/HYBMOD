function [rhyb,rann, drhyb_ds, drhyb_dw]=hybrates(t,state,w,ucontrol,projhyb)
% HYBRATES computes reaction rates and respective sensitivities
%
%[rhyb,rann, drhyb_ds, drhyb_dw] = HYBRATES(projhyb,t,state,jac,hess,w,ucontrol)
%
% INPUT ARGUMENTS
% projhyb           Data strtucture holding information of the hybrid model, 
%                   data and traning method
% t                 current time (scalar)
% state             vector of state variables (ns*1)
% w                 vector of weights (nw*1)
% ucontrol          vectorof control variables (nu*1)
%
% OUTPUT ARGUMENTS
% rhyb              vector of reaction rates (ns*1)
% rann              vector of ANN outputs (no*1)
% drhyb_ds          matrix of state sensitivities  (ns*ns)
% drhyb_dw          matrix of weights sensitivities  (ns*nw)
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
% Universidade Nova de Lisboa
% DQ/FCT/UNL 6º piso
% P-2829-516 Caparica, Portugual
% Phone  +351 212948356
% Fax    +351 212948385
% E-mail rmo@fct.unl.pt
%
% $ Version 10.00 $ Date December 2020 $ Not compiled $
if nargout <=2
    [anninp] = feval(projhyb.mlm.xfun,t,state,ucontrol);
    [rann] =   feval(projhyb.mlm.yfun,anninp,w,projhyb.mlm.fundata);
    [rhyb] =   feval(projhyb.userdefun_parametric_kinetic,t,state,rann,ucontrol);
    drhyb_ds=[];
    drhyb_dw=[];
else    
    [anninp,danninp_dstate,~] = feval(projhyb.mlm.xfun,t,state,ucontrol);
    [rann, drann_danninp, drann_dw] =   feval(projhyb.mlm.yfun,anninp,w,projhyb.mlm.fundata);
    [rhyb,drhyb_ds,drhyb_drann] = feval(projhyb.userdefun_parametric_kinetic,t,state,rann,ucontrol);
    drhyb_dw=drhyb_drann*drann_dw;
    drhyb_ds=drhyb_ds+drhyb_drann*drann_danninp*danninp_dstate;    
end
end
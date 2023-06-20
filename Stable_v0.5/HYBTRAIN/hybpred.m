%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [tspan,statehyb,rhyb,rann,ucontrol]=hybpred(projhyb,tspan,state0,w,batch)
% HYBPRED trains a hybrid model
%
%[t,chyb,rhyb,rann,ucontrol] = HYBPRED(projhyb,t,w,upars)
%
% INPUT ARGUMENTS
% projhyb           Data strtucture holding information of the hybrid model, 
%                   data and traning method
% tspan             time grid for integration (vector np*1)
% state0            Initial conditions (vector ns*1)
% w                 Vector of kinetic parameters 
% upars             controller parameterization (matrix)
%
% OUTPUT ARGUMENTS
% t                 time span vector (=batch.t)
% statehyb          matrix [np*nstate] of predicted hybrid model sate vars
% rhyb              matrix [np*nspecies] of predicted hybrid model volumetric rates 
% rann              matrix [np*ann.no] of predicted ANN outputs 
% ucontrol          matrix [np*nu] of control variabels along time
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
% $ Version 10.00 $ Date November 2020 $ Not compiled $
np=length(tspan);
statehyb=zeros(np,projhyb.nstate);
rhyb=zeros(np,projhyb.nspecies);
rann=zeros(np,projhyb.mlm.ny);
        
state=state0;
statehyb(1,1:projhyb.nstate) = state(1:projhyb.nstate,1)';  

if ~isempty(projhyb.mlmsetwfunc)
    projhyb.mlm.fundata=feval(projhyb.mlmsetwfunc,projhyb.mlm.fundata,w); %set weigths 
end

if nargout > 2
    u = feval(projhyb.fun_control,tspan(1),batch);
    [rhyb_v,rann_v] = feval(projhyb.fun_hybrates,tspan(1),state,w,u,projhyb);
    rhyb(1,:)=rhyb_v';
    rann(1,:)=rann_v';
    ucontrol(1,:)=u';
end

for j=2:np
    
       [~,state]=hybodesolver(projhyb.fun_hybodes,...
         projhyb.fun_control,projhyb.fun_event,tspan(j-1),tspan(j),state,0,0,w,batch,...
         projhyb);
     
        statehyb(j,:)=state';
        
        if nargout > 2
            u = feval(projhyb.fun_control,tspan(j),batch);
            [rhyb_v,rann_v] = feval(projhyb.fun_hybrates,tspan(j),state,w,u,projhyb);
            rhyb(j,:)=rhyb_v';
            rann(j,:)=rann_v';
            ucontrol(j,:)=u';
        end
end
end%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
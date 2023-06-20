%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [nres,restr_c,wssetr_c,resvl_c,wssevl_c,...
    restr_r,wssetr_r,resvl_r,wssevl_r]=hybbatcherrors(projhyb,w,batch)
% HYBBATCHERRORS compute batch/model residuals
%
%[projhyb] = HYBBATCHERRORS(projhyb,w,batch)
%
% INPUT ARGUMENTS
% projhyb           Data strtucture holding information of the hybrid model, 
%                   data and traning method
% w                 vector of kinetic parameters 
% batch             Data structure holding information of the batch file to 
%                   simulate 
%
% OUTPUT ARGUMENTS
% nres              number of residuals[=btach.npspecies*batch.np]
% restr_c           concentrations residuals (training) 
% wssetr_c          concentrations WSSE (training)
% resvl_c           concentrations residuals (validation)
% wssevl_c          concentrations WSSE (validation)
% restr_r           rates residuals (training)
% wssetr_r          rates WSSE (training)
% resvl_r           rates residuals (validation)
% wssevl_r          rates WSSE (validation)
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
[~,statehyb,rhyb]=hybpred(projhyb,batch.t,batch.state(1,:)',w,batch);
%
% residuals/erros in state variables
isres=projhyb.isres;  % indexes of state variables
restr_c = reshape((batch.state(:,isres)-statehyb(:,isres))./batch.sc(:,isres),numel(statehyb(:,isres)),1);
restr_c=restr_c(~isnan(restr_c));
resvl_c = reshape((batch.statevl(:,isres)-statehyb(:,isres))./batch.sc(:,isres),numel(statehyb(:,isres)),1);
resvl_c=resvl_c(~isnan(resvl_c));
wssetr_c = restr_c'*restr_c;
wssevl_c = resvl_c'*resvl_c;
nres=length(restr_c);
%
% residuals/errors in rates 
restr_r=[];
resvl_r=[];
wssetr_r=[];
wssevl_r=[];
if nargout>5
    isress=projhyb.isresstate; % indexes of rate variables
    restr_r = reshape((batch.rnoise(:,isress)-rhyb(:,isress))./batch.sr(:,isress),numel(rhyb(:,isress)),1);
    restr_r = restr_r(~isnan(restr_r));
    resvl_r = reshape((batch.rvalid(:,isress)-rhyb(:,isress))./batch.sr(:,isress),numel(rhyb(:,isress)),1);
    resvl_r = resvl_r(~isnan(resvl_r));
    wssetr_r = restr_r'*restr_r;
    wssevl_r = resvl_r'*resvl_r;
    nres=length(restr_r);
end
end%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
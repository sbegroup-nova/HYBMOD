%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [t,shyb,shyblow,shybup,rhyb,rhyblow, rhybup, ...
         rann, rannlow,rannup, restr_c, wssetr_c, resvl_c, wssevl_c,...
         restr_r,wssetr_r,resvl_r,wssevl_r]=hybbatchsimul(projhyb,batch)
%
% HYBBATCHSIMUL simulate a batch data set by hybrid model
%
%[projhyb] = HYBBATCHSIMUL(projhyb, batch)
%
% INPUT ARGUMENTS
% projhyb           Data strtucture holding information of the hybrid model, 
%                   data and traning method
% batch             Data structure holding information of the batch file to 
%                   simulate 
%
% OUTPUT ARGUMENTS
% t                 teme span vector (=batch.t)
% shyb              matrix [np*ns] of predicted hybrid model state vars
% shyblow           matrix [np*ns] of predicted hybrid model state vars
%                   lower 95% confidence interval
% shybup            matrix [np*ns] of predicted hybrid model state vars
%                   upper 95% confidence interval
% rhyb              matrix [np*ns] of predicted hybrid model volumetric rates 
% rhyblow           matrix [np*ns] of predicted hybrid model volumetric rates 
%                   lower 95% confidence interval
% rhybup            matrix [np*ns] of predicted hybrid model volumetric rates 
%                   upper 95% confidence interval
% rann              matrix [np*ann.no] of predicted ANN outputs 
% rannlow           matrix [np*ann.no] of predicted ANN outputs 
%                   lower 95% confidence interval
% rannup            matrix [np*ann.no] of predicted ANN outputs 
%                   upper 95% confidence interval
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
t   = batch.t;
c   = batch.state;
cvl = batch.statevl;
sc = batch.sc;
r   = batch.rnoise;
rvl = batch.rvalid;
sr = batch.sr;
isres=projhyb.isres;
isress=projhyb.isresstate;
upars = batch.u;
np = length(t);

ns = projhyb.nspecies; 
nyann = projhyb.mlm.ny;
        
state0=batch.state(1,:)';

if projhyb.nensemble==1;
    [t,shyb,rhyb,rann,~]=hybpred(projhyb,t,state0,projhyb.w,batch);
    shybup=[];
    shyblow=[];
    rhybup=[];
    rhyblow=[];
    rannup=[];
    rannlow=[];
    
elseif projhyb.nensemble>1 
    
    m_shyb=zeros(np,projhyb.nstate,projhyb.nensemble);
    m_rhyb=zeros(np,ns,projhyb.nensemble);
    m_rann=zeros(np,nyann,projhyb.nensemble);
    for i=1:projhyb.nensemble
        [t,shybi,rhybi,ranni,~]=hybpred(projhyb,t,state0,projhyb.wensemble(i,:)',batch);
        m_shyb(:,:,i)=shybi;
        m_rhyb(:,:,i)=rhybi;
        m_rann(:,:,i)=ranni;
    end
    shyb = mean(m_shyb,3);
    rhyb = mean(m_rhyb,3);
    rann = mean(m_rann,3);
    stdshyb = std(m_shyb,[],3);
    stdrhyb = std(m_rhyb,[],3);
    stdrann = std(m_rann,[],3);
    tstud = tinv(0.975,projhyb.nensemble-1); %for 95% confidence with nsensemble degrees of freedom 
    shybup  = shyb  +tstud*stdshyb;
    shyblow = shyb -tstud*stdshyb;
    rhybup=rhyb  +tstud*stdrhyb;
    rhyblow=rhyb -tstud*stdrhyb;
    rannup=rann  +tstud*stdrann;
    rannlow=rann -tstud*stdrann;
    
end

% calculate residuals and model performance metrics
restr_c=[];
resvl_c=[];
wssetr_c=[];
wssevl_c=[];
restr_r=[];
resvl_r=[];
wssetr_r=[];
wssevl_r=[];
if nargout>10
    restr_c = 0;
    restr_c =0;
    resvl_c = 0;
    resvl_c =0;
    wssetr_c = 0;
    wssevl_c = 0;
    restr_r = 0;
    restr_r =0;
    resvl_r = 0;
    resvl_r =0;
    wssetr_r = 0;
    wssevl_r = 0;
end
end%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
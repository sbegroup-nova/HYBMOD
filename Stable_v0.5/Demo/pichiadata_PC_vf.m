%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SYNTHETIC DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [nbatch, batch]=pichiadata_PC_vf
rng default;

nbatch=9;

    startr=[1,15,35,63,87,101,132,159,183];
    endr=[14,34,62,86,100,131,158,182,207];

    for i=1:nbatch
    data=readmatrix('Pichiadatanew.xlsx','Sheet',"FullCtable"); %Read each excel sheet
    drange=startr(i):endr(i);
    
    t=data(drange,1); %time span
    
    V=data(drange,5); %Volume L
    
    Feed=data(drange,21); %total feed based on the average derivative of volume
    
    
    T=data(drange,2); %Temperature ºC
    pH=data(drange,3); %pH
    NH3in=data(drange,22); %Z1
    Metin=data(drange,23); %Z2
    
    X=data(drange,6); %
    ScFv=data(drange,7); %Product g/L
    Ca=data(drange,8);    
    K=data(drange,9);    
    Mg=data(drange,10);    
    P=data(drange,11);    
    S=data(drange,12); 
    NH3=zeros(length(t),1);    
    Met=zeros(length(t),1);
    Mem=ones(length(t),1);
            
    
            
%     sdX=64*ones(length(t),1); %standard deviation
%     sdScFv=5.7*ones(length(t),1); %standard deviation
%     sdCa=0.029*ones(length(t),1); %standard deviation
%     sdK=1.1*ones(length(t),1); %standard deviation
%     sdMg=0.17*ones(length(t),1); %standard deviation
%     sdP=1.2*ones(length(t),1); %standard deviation
%     sdS=0.7*ones(length(t),1); %standard deviation
%     sdNH3=ones(length(t),1); %standard deviation
%     sdMet=ones(length(t),1); %standard deviation
    
    sdX=0.09*X+6.4; %standard deviation
    sdScFv=0.09*ScFv+0.57; %standard deviation
    sdCa=0.09*Ca+0.0029; %standard deviation
    sdK=0.09*K+0.11; %standard deviation
    sdMg=0.09*Mg+0.017; %standard deviation
    sdP=0.09*P+0.12; %standard deviation
    sdS=0.09*S+0.07; %standard deviation
    sdNH3=0.09*ones(length(t),1); %standard deviation
    sdMet=0.09*ones(length(t),1); %standard deviation
    sdMem=0.09*ones(length(t),1); %standard deviation
    
    

    
    batch(i).id=sprintf('batch%u',i);
    
    batch(i).u=[T,pH,Feed,NH3in,Metin]; %controller parameters


    batch(i).np=           length(t);
    batch(i).t=            t;
    
    %species
    batch(i).cnoise=       [X,ScFv,Ca,K,Mg,P,S,NH3,Met,Mem];
 
    %compartment size
    batch(i).vol(:,1)=          V;
    
    %raterules
    batch(i).raterule=     [];
    
    %state
    batch(i).state =  [batch(i).cnoise, V];
   
    batch(i).sc=      [sdX,sdScFv,sdCa,sdK,sdMg,sdP,sdS,sdNH3,sdMet,sdMem,ones(batch(i).np,1)];
    
    %control actions
    batch(i).ualongtime=   [];
    
    %true process data only important for plot purpose
    % if not available, assign null
    batch(i).c_true=       batch(i).cnoise;
    batch(i).rvol_true=    [];
    batch(i).rann_true=    [];    
    
    end

end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



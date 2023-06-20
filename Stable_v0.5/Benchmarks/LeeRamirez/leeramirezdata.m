    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SYNTHETIC DATA
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [nbatch, batch]=leeramirezdata
rng default;

nbatch=27;

  % Central Composite design of Experiences DoE
  % The controllers are u1(Nutriente feeding rate L/h) between 0-0.25 and
  % u2(Inducer fe;zeding rate L/h) between 0-0.025
  %Acresentar tempo de indução!!!!!!!!%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Incluir no DoE duas faze, per e post induction
  %Fatores são tempo de indução, u1 antes da indução (constante, perfil exponencial, fazer DoE a partir de miu desejado), u1 depois
  %da indução (constante, perfil exponencial, fazer DoE a partir de miu desejado) e u2 depois da indução (constante),...
  %...Concentração inicial de substrato
  mat=ccdesign(4); %25 experiments+1
  tindDoE=rescale(mat(1:27,1),5,9); %Rescale matrix elements between 5 and 9(induction time)
  miupreDoE=rescale(mat(1:27,2),0,1); %Rescale matrix elements between 0 and 0.8 (desired miu)
  miupostDoE=rescale(mat(1:27,3),0,1); %Rescale matrix elements between 0 and 0.8 (desired miu)
  vpDoE=rescale(mat(1:27,4),0,1); %Rescale matrix elements between 0 and 1 (Feeding rate of inducer)
  %OLD VERSION u1=rescale(mat(:,1),0,1); %Rescale matrix elements between 0 and 0.25
  %OLD VERSION u2=rescale(mat(:,2),0,1); %Rescale matrix elements between 0 and 0.025
  %OLD VERSION DOE=[u1 u2]; 
  %OLD VERSION Exp=randi(9,11,10); %Random matrix that dictates the feeding rates according to the DOE

for i=1:nbatch
    tind=tindDoE(i);
    miupre=miupreDoE(i);
    miupost=miupostDoE(i);
    vp=vpDoE(i);
    yxs=0.51;
    X0=0.1;
    V0=1;
    Sin=20;
    f1=[];
    f2=[];
    for t=1:tind
        f1(t,1)=(miupre*X0*V0*exp(miupre*t))/(yxs*Sin);
        f2(t,1)=0;
    end
    for t=tind:10
        f1(t,1)=(miupre*X0*V0*miupost*exp(miupost*t))/(yxs*Sin);
        f2(t,1)=(miupre*X0*V0*vp*exp(vp*(t-tind)));
    end
    
    f=[f1 f2;0 0];
    
    
    %OLD VERSION f1=DOE(Exp(i,:),1);
    %OLD VERSION f2=DOE(Exp(i,:),2);
    %OLD VERSION f1(1:5)=0;
    %OLD VERSION f2(1:7)=0;
    %OLD VERSION f=[f1 f2; 0 0];
     if i==26
        f1=[0.001206041;0.001560816;0.001160486;0.051684367;0.031146922;3.08445E-05;0.144039733;0.115975472;0.399681145;0.915905148;0];
        f2=[0;0;0;0;4.49174E-11;0.011741867;0.024487052;0.025152617;0.208211097;1;0];
        f=[f1 f2];
     end
     if i==27
        f1=[0.006916443187;0.000310422802;0.01684008379;0;0.02307401607;0.07655081727;0.07048140852;0.1907820332;0.1287522701;0.2822442042;0];
        f2=[0;0.0000009316262587;0;0.000004140110325;0.001857246908;0.01479568749;0.0154546401;0.03369143929;0.0000005197347245;0;0];
        f=[f1 f2];
     end
    
    batch(i).id=sprintf('batch%u',i);
    
    batch(i).u=f; %controller parameters

    doplot=0;
    [t,species,vol,raterule,ualongtime,sdspecies,species_true,rvol_true,rann_true]=...
        protrue(batch(i).u,doplot);

    batch(i).np=           length(t);
    batch(i).t=            t;
    
    %species
    batch(i).cnoise=       species;
   % batch(i).cnoise=       species_true; %TESTING
    batch(i).cnoise(1,:)=    species_true(1,:); %true initial values
 
    %compartment size
    batch(i).vol(:,1)=          vol;
    
    %raterules
    batch(i).raterule=     raterule;
    
    %state
    %batch(i).state =  [species, vol, raterule];
    batch(i).state =  [species, vol];
    %batch(i).state =  [species_true, vol]; %TEST ONLY
    batch(i).state(1,:)=    [species_true(1,:),vol(1)]; %true initial values
   
    batch(i).sc=      [sdspecies, ones(batch(i).np,1)];
    
    %control actions
    batch(i).ualongtime=   ualongtime;
    
    %true process data only important for plot purpose
    % if not available, assign null
    batch(i).c_true=       species_true;
    batch(i).rvol_true=    rvol_true;
    batch(i).rann_true=    rann_true;    

end

end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function [t,cnoise,vol,raterule,ucontrol, sc, c, rvol_true,rann_true]=protrue(upars,doplot)
tspan=0:1:10;
%    V    X     S    P    I    FC   FR
x0=[ 1   0.1    40   0    0    1   0]; %Initial conditions Colocar a variar muito a biomassa
std=[0.1 0.1    1   0.05  0.01  0.005   0.005];
odeopts=odeset('AbsTol',1e-7,'RelTol',1e-5);%,'NonNegative',1:9);
f1=upars(:,1);
f2=upars(:,2);
ofun=@(t,x)ode(t,x,f1,f2);
[t,x]=ode45(ofun,tspan,x0,odeopts);
np=length(t);
% concentrations
c=x(:,2:7);
%volume
vol=x(:,1);
%standard deviation of concentrations
sc=repmat(std(2:7),np,1);
% add noise to concentrations
cnoise=zeros(np,6);
for i=1:6
   cnoise(:,i)=c(:,i)+randn(np,1)*std(i+1);
end
%TRUE MODEL ONLY
%cnoise=c;
%%%%%%%%
% raterules
raterule = [];
% kinetic rates %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
rann_true =zeros(np,4); %unknown kinetics
rvol_true=zeros(np,4);
ucontrol=zeros(np,2);
for i=1:np
    res=kinetics(x(i,:),f1(i),f2(i)); % res=[miu Rfp Rr k1 k2 eq1 eq2 eq3 eq4 eq5 eq6 eq7];
    rvol_true(i,1)=res(7);
    rvol_true(i,2)=res(8);
    rvol_true(i,3)=res(9);
    rvol_true(i,4)=res(10);
    rann_true(i,1)=res(1);
    rann_true(i,2)=res(2);
    rann_true(i,3)=res(4);
    rann_true(i,4)=res(5);
    ucontrol(i,1)=f1(i);
    ucontrol(i,2)=f2(i);
end
if doplot==1
    %plots----------------------
    figure
    subplot(2,5,1)
    plot(t,c(:,1),'b-'); hold on
    errorbar(t,cnoise(:,1),sc(:,1),'bo'); hold on
    ylabel('X, g/l')
    subplot(2,5,2)
    plot(t,c(:,2),'r-'); hold on
    errorbar(t,cnoise(:,2),sc(:,2),'ro'); hold on
    ylabel('S, g/l')
    hold off
    subplot(2,5,3)
    plot(t,c(:,3),'r-'); hold on
    errorbar(t,cnoise(:,3),sc(:,3),'ro'); hold on
    ylabel('PT, g/l')    
    hold off
    subplot(2,5,4)
    plot(t,c(:,4),'r-'); hold on
    errorbar(t,cnoise(:,4),sc(:,4),'ro'); hold on
    ylabel('PM, g/l')    
    hold off
    
    subplot(2,5,5); plot(t,rann_true(:,1),'b-'); ylabel('mu')
    subplot(2,5,6); plot(t,rann_true(:,2),'b-'); ylabel('vPT')
    subplot(2,5,7); plot(t,rann_true(:,3),'b-'); ylabel('vPM')

    subplot(2,5,8); plot(t,vol,'r-'); ylabel('V,l')
end
end

%-------------------------------------------------------------------------
% PARAMETERIZATION OF CONTROL VARIABLES
function [u]=control_function_leeramirez(t,upars)%------------------------------------
nupars=size(upars,1);
tf=10;
dt=tf/nupars;
i = min(floor(t/dt)+1,nupars);
FeedS = upars(i,1);%Feeding rate substrate
FeedInd = upars(i,2);%Feeding rate inducer
u =[FeedS;FeedInd];
end%-----------------------------------------------------------------------



  function res=ode(t,x,f1,f2)
% Constants
       Cnf= 100; %g/L
       Cif=4; %g/L
       Y=0.51; 
% States
       V=x(1); %Volume L
       X=x(2); %Cell density g/L
       S=x(3); %Nutrient concentration g/L
       P=x(4); %Protein concentration g/L
       I=x(5); %Inducer concentration g/L
       FC=x(6);%Inducer shock factor on cell growth rate
       FR=x(7);%Inducer recovery factor on cell growth rate
        
   if t<=1;
     u1=f1(1); 
     u2=f2(1);
   elseif   t>1 &&  t <= 2
     u1=f1(2);
     u2=f2(2);
   elseif t>2 &&  t<= 3
     u1=f1(3);
     u2=f2(3);
   elseif t>3 &&  t<= 4
     u1=f1(4);
     u2=f2(4);
   elseif t>4 &&  t<= 5
     u1=f1(5);
     u2=f2(5);
   elseif t>5 &&  t<= 6
     u1=f1(6) ;
     u2=f2(6);
   elseif t>6 &&  t<= 7
     u1=f1(7);
     u2=f2(7);
   elseif t>7 &&  t<= 8
     u1=f1(8);
     u2=f2(8);
   elseif t>8 &&  t<= 9
     u1=f1(9);
     u2=f2(9);
   elseif t>9 &&  t<= 10
     u1=f1(10); 
     u2=f2(10);
end
           
%  Kinetic Parameters
       kin=kinetics(x,u1,u2);
       miu=kin(1); %Growth rate h-1
       Rfp=kin(2); %Foreign protein production ratio
       k1=kin(4) ; %Shock parameter h-1
       k2=kin(5);  %Recovery parameter h-1
       
% ODE's
       eq1=u1+u2;
       eq2=miu*X-(u1+u2)/V*X;
       eq3=u1*Cnf/V-(u1+u2)/V*S-((1/Y)*miu*X);
       eq4=Rfp*X-(u1+u2)/V*P;
       eq5=u2*Cif/V-(u1+u2)/V*I;
       eq6=-k1*FC;
       eq7=k2*(1-FR);
       res=[eq1;eq2;eq3;eq4;eq5;eq6;eq7];
  end
% Kinetics
 function res=kinetics(x,u1,u2)
% Constants
       Cnf= 100; %g/L
       Cif=4; %g/L
       Y=0.51; 
% States
       V=x(1); %Volume L
       X=x(2); %Cell density g/L
       S=x(3); %Nutrient concentration g/L
       P=x(4); %Protein concentration g/L
       I=x(5); %Inducer concentration g/L
       FC=x(6);%Inducer shock factor on cell growth rate
       FR=x(7);%Inducer recovery factor on cell growth rate
 
% Parameters
       miumax=1; %h-1
       Kci=0.22; %g/L
       KCn=14.35; %g/L
       KI=0.022; %g/L
       KIX=0.034; %g/L
       KS =111.5;
       k11=0.09; %h-1
       k22=0.09; %h-1
       fmax=0.233; %h-1
       fi0=0.0005; %g/L
 %Rr calculation
       Rr=Kci/(Kci+I);
 %miu calculation
       miu=miumax*S/(KCn+S+(S^2/KS))*(FC+FR*Rr);
 %Rfp calculation
       Rfp=fmax*S/(KCn+S+(S^2/KS))*(fi0+I)/(KI+I);
 %k1 calculation
       k1=k11*I/(KIX+I);
 %k2 calculation
       k2=k22*I/(KIX+I);
       
       eq1=u1+u2;
       eq2=miu*X-(u1+u2)/V*X;
       eq3=u1*Cnf/V-(u1+u2)/V*S-((1/Y)*miu*X);
       eq4=Rfp*X-(u1+u2)/V*P;
       eq5=u2*Cif/V-(u1+u2)/V*I;
       eq6=-k1*FC;
       eq7=k2*(1-FR);      
       
 res=[miu Rfp Rr k1 k2 eq1 eq2 eq3 eq4 eq5 eq6 eq7];
 end



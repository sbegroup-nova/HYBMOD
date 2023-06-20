%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [projhyb,trainData] = hybtrain(projhyb)
% HYBTRAIN trains a hybrid model
%
%[projhyb] = HYBTRAIN(projhyb)
%
% INPUT ARGUMENTS
% projhyb           Data strtucture holding information of the hybrid model, 
%                   data and traning method
%
% OUTPUT ARGUMENTS
% projhyb           Updated data strtucture holding information of the 
%                   trained hybrid model, and training performance
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
assert(nargin>=1,'at least 1 inputs HYBTRAIN( projhyb)');
assert(projhyb.nensemble<=projhyb.nstep,...
    'Too many aggegation parameters\nnsensemble<=nstep');
assert(projhyb.nensemble>0,...
    'nnsensemble must be at least 1');
assert(projhyb.nstep>0,...
    'nstep must be >=1');


% Prepare data for training
projhyb.ntrain=0;
projhyb.istrain=zeros(projhyb.nbatch,1);
istrainSAVE=zeros(projhyb.nbatch,1);
projhyb.itr=[];
cnt_jctrain=0;   cnt_jcval=0;    cnt_jctest=0;    
for i=1:projhyb.nbatch
     projhyb.istrain(i)=projhyb.batch(i).istrain;
   %  istrainSAVE(i)=projhyb.batch(i).istrain;
     if projhyb.batch(i).istrain==1
         projhyb.ntrain=projhyb.ntrain+1;
         projhyb.itr(end+1)=i;
         cnt_jctrain=cnt_jctrain+numel(projhyb.batch(i).cnoise);
     elseif projhyb.batch(i).istrain==3
         cnt_jctest=cnt_jctest+numel(projhyb.batch(i).cnoise);
     end
end
if projhyb.bootstrap==1 
    if ~isfield(projhyb,'nbootstrap')
        projhyb.nbootstrap=projhyb.ntrain;
        projhyb.nstep=projhyb.ntrain;
    else
        projhyb.nstep=projhyb.nbootstrap;
    end
    if ~isfield(projhyb,'nbootrate')
        projhyb.nbootrate=2/3;
    end
    nboot=max(1,floor(projhyb.ntrain*projhyb.nbootrate));
end

% this is the output function for lsqnonl e fminunc; it is a nested
% function
ofun1=@(x1,x2,x3)outFun1(x1,x2,x3,projhyb);


fprintf('\nTraining mehod:\n')
if projhyb.mode==1
    fprintf('   Mode:                   Indirect\n')
elseif projhyb.mode==2
    fprintf('   Mode:                   Direct\n')
elseif projhyb.mode==3
    fprintf('   Mode:                   Semidirect\n')
end
jacobian='off';
if projhyb.jacobian ==0
    fprintf('   Jacobian:               OFF\n')
elseif projhyb.jacobian ==1
    fprintf('   Jacobian:               ON\n')
    jacobian='on';
end
hessian='off';
if projhyb.hessian ==0
    fprintf('   Hessian:               OFF\n')
elseif projhyb.hessian ==1
    fprintf('   Hessian:               ON\n')
    hessian='on';
end
fprintf('   Steps:                  %u\n',projhyb.nstep)
fprintf('   Displayed iterations:   %u\n',projhyb.niter)
fprintf('   Total iterations:       %u\n',projhyb.niter*projhyb.niteroptim)
if projhyb.bootstrap==1
    fprintf('   Bootstrap:              ON\n')
    fprintf('   Bootstrap repetions:    %u\n', projhyb.nbootstrap)
    fprintf('   Bootstrap permutations: %u/%u\n',nboot,projhyb.ntrain)
else
    fprintf('   Bootstrap:              OFF\n')
end
if (projhyb.method==1) %levenber-marquardt
    fprintf('   Optimiser:              levenberg-marquardt\n')
    options = optimset('lsqnonlin');
    options = optimset(options,'Algorithm','levenberg-marquardt',...
    'Jacobian',jacobian,'Display',projhyb.display,'MaxIter',projhyb.niter*projhyb.niteroptim,...
    'DerivativeCheck',projhyb.derivativecheck,'OutputFcn',ofun1,...
    'MaxFunEval',100000,'TolFun',1e-12,'TolX',1e-9);%,'OptimalityTolerance'); %,'DiffMaxChange',0.1);
elseif (projhyb.method==2) %quasi-Newton
    algorithm='lm-line-search';
    if projhyb.jacobian==1
        algorithm='trust-region-reflective';
    end
    fprintf('   Optimiser:              %s\n',algorithm);    
    options = optimset('fminunc');
    options = optimset(options,'Algorithm',algorithm,...     %'quasi-newton'
    'GradObj',jacobian,'Hessian',hessian, 'Display',projhyb.display,...   %'Diagnostics','on'
    'MaxIter',projhyb.niter*projhyb.niteroptim,...
    'DerivativeCheck',projhyb.derivativecheck,'OutputFcn',ofun1);%,...
    %'MaxFunEval',100000,'TolFun',1e-20,'TolX',1e-40); %,'DiffMaxChange',0.1);
elseif (projhyb.method==3) %simulated annealing
    fprintf('   Optimiser:              Simulated Annealing\n')
    optopts=saoptimset('Display',projhyb.display,'MaxIter',projhyb.niter*projhyb.niteroptim,'OutputFcn',ofun1);
    ParsLB=-20*ones(projhyb.mlm.nw,1);
    ParsUB=20*ones(projhyb.mlm.nw,1);
elseif (projhyb.method==4) %ADAMS
    fprintf('   Optimiser:              Adam\n')
    npall=0;
for l=1:projhyb.nbatch
    if projhyb.istrain(l) == 1
       npall=npall+length(projhyb.batch(l).t);
    end
end
  %  options.niter=projhyb.niter*npall; 
    options.niter=projhyb.niter*projhyb.niteroptim;
  %  options.LR=projhyb.learning_rate; Calculated in function
end
fprintf('\n\n');

%
% training performance data structure initialization
% 
TrainRes.witer=zeros(projhyb.nstep*projhyb.niter*2,projhyb.mlm.nw);
TrainRes.wstep=zeros(projhyb.nstep,projhyb.mlm.nw);
TrainRes.istrain=[];
TrainRes.resnorm=zeros(projhyb.nstep*projhyb.niter*2,1);
TrainRes.sjctrain=zeros(projhyb.nstep*projhyb.niter*2,1); 
TrainRes.sjrtrain=zeros(projhyb.nstep*projhyb.niter*2,1); 
TrainRes.sjcval=zeros(projhyb.nstep*projhyb.niter*2,1); 
TrainRes.sjrval=zeros(projhyb.nstep*projhyb.niter*2,1); 
TrainRes.sjctest=zeros(projhyb.nstep*projhyb.niter*2,1); 
TrainRes.sjrtest=zeros(projhyb.nstep*projhyb.niter*2,1); 
TrainRes.AICc=zeros(projhyb.nstep*projhyb.niter*2,1);
TrainRes.mj=zeros(projhyb.nstep,1);
TrainRes.iter=0;
TrainRes.istep=0;
TrainRes.t0=cputime;

if ~isfield(projhyb,'initweights')
    projhyb.initweights=1;
end
if projhyb.initweights==1
   fprintf('Weights initialization...\n')
   [weights,ann]=mlpnetinitw(projhyb.mlm.fundata);
   projhyb.mlm.fundata=ann;
elseif projhyb.initweights==2
   fprintf('Read weights from file...\n')
   weights = load(projhyb.weightsfile);
   weights=reshape(weights.wPHB0,numel(weights.wPHB0),1);
   projhyb.mlm.fundata=feval(projhyb.mlmsetwfunc,projhyb.mlm.fundata,weights); 
end
%%%%%%%
% TRAINING BEGINS HERE:
% cycle for repetion projhyb.nstep different trainings with randomized 
% initial weights
for istep=1:projhyb.nstep
    
    for i=1:projhyb.nbatch
        projhyb.istrain(i)=projhyb.batch(i).istrain;
    end
    if projhyb.bootstrap==1 
        ind=sort(randperm(projhyb.ntrain,nboot));
        projhyb.istrain(projhyb.itr)=0;
        projhyb.istrain(projhyb.itr(ind))=1;
    end
    TrainRes.istrain=[TrainRes.istrain; projhyb.istrain'];
    if projhyb.mode==1  %INDIRECT
        if projhyb.method==4
            fobj=@(w,istrain)resfun_indirect_jac(w,istrain,projhyb,projhyb.method);
        elseif projhyb.jacobian ==0
            fobj=@(w)resfun_indirect(w,projhyb.istrain,projhyb,projhyb.method);
        elseif projhyb.jacobian ==1
            fobj=@(w)resfun_indirect_jac(w,projhyb.istrain,projhyb,projhyb.method);
        elseif projhyb.hessian ==1
            assert(projhyb.hessian ==1,'Hessian not yet implemented')
        end
    elseif projhyb.mode==2 %DIRECT
        if projhyb.method==4
            fobj=@(w,istrain)resfun_direct_jac(w,istrain,projhyb,projhyb.method);
        elseif projhyb.jacobian ==0
            fobj=@(w)resfun_direct(w,projhyb.istrain,projhyb,projhyb.method);
        elseif projhyb.jacobian ==1
            fobj=@(w)resfun_direct_jac(w,projhyb.istrain,projhyb,projhyb.method);
        elseif projhyb.hessian ==1
            assert(projhyb.hessian ==1,'Hessian not yet implemented')
        end
    elseif projhyb.mode==3 %SEMIDIRECT
        if projhyb.method==4
            fobj=@(w,istrain)resfun_semidirect_jac(w,istrain,projhyb,projhyb.method);
        elseif projhyb.jacobian ==0
            fobj=@(w)resfun_semidirect(w,projhyb.istrain,projhyb,projhyb.method);
        elseif projhyb.jacobian ==1
            fobj=@(w,istrain)resfun_semidirect_jac(w,projhyb.istrain,projhyb,projhyb.method);
        elseif projhyb.hessian ==1
            assert(projhyb.hessian ==1,'Hessian not yet implemented')
        end
    end

    if istep> 1
        fprintf('Weights initialization...\n')
        [weights,ann]=mlpnetinitw(projhyb.mlm.fundata);
        projhyb.mlm.fundata=ann;
    end

    %%%%%%%%%%%%%%
    %%%%%%%%%%%%%%
    fprintf('ITER  RESNORM    [C]train   [C]valid   [C]test   [R]train   [R]valid   [R]test    AICc       NW   CPU\n')
    if projhyb.method==1 %LEVENBERG-MARQUARDT
        [wfinal,fval,res,exitflag] = lsqnonlin(fobj,weights*0.01,[],[],options);
    elseif projhyb.method==2 %QUASI-NEWTON
        [wfinal,fval,exitflag,~,grad] = fminunc(fobj,weights,options);
    elseif projhyb.method==3  %SIMULATED ANNEALING
        [wfinal, fval]=simulannealbnd(fobj,weights,ParsLB,ParsUB,optopts);
    elseif projhyb.method==4 % ADAMS
        [wfinal, fval]=adamunlnew(fobj,weights,ofun1,projhyb,options);
    end

end
TrainRes.finalcpu=cputime-TrainRes.t0;
projhyb.istrain=istrainSAVE;

%
%sort optimization results in ascending order of validation error
%important to select N best models for model aggregation
%
[~,ind ]=sort(TrainRes.mj(:,3));
TrainRes.mj(:,1)=TrainRes.mj(ind,3);
TrainRes.mj(:,2)=TrainRes.mj(ind,2);
TrainRes.mj(:,3)=TrainRes.mj(ind,3);
TrainRes.mj(:,4)=TrainRes.mj(ind,4);
TrainRes.mj(:,5)=TrainRes.mj(ind,5);
TrainRes.mj(:,6)=TrainRes.mj(ind,6);
TrainRes.mj(:,7)=TrainRes.mj(ind,7);
TrainRes.mj(:,8)=TrainRes.mj(ind,8);
TrainRes.wstep(:,1:projhyb.mlm.nw)=TrainRes.wstep(ind,1:projhyb.mlm.nw);

%
% save final training results
trainData=TrainRes;
save('hybtrain_results.mat','trainData');

%
% plot training results
figure%----------------------------------------------------------------
x=1:TrainRes.iter;
size(x)
size(TrainRes.resnorm)
semilogy(x,TrainRes.resnorm(1:TrainRes.iter),'Color', [0.08 0.5 0],'LineWidth',2,'LineStyle','-')
hold on
semilogy(x,TrainRes.sjctrain(1:TrainRes.iter),'Color', [0.2 0.2 1],'LineWidth',2,'LineStyle','-')
hold on
semilogy(x,TrainRes.sjcval(1:TrainRes.iter),'Color', [0.2 0.2 1],'LineWidth',2,'LineStyle',':')
hold on
semilogy(x,TrainRes.sjctest(1:TrainRes.iter),'Color', [1 0 0],'LineWidth',2,'LineStyle','-')
hold off
set(gca,'linewidth',2)
xlim('manual');
ylim('manual');
iga=max(floor((TrainRes.iter-1)/6)+1,1);
set(gca,'XLim',[1 6*iga],'XTick',(1:iga:iga*6));    
ymin=1e20;ymin=min(ymin,min(TrainRes.resnorm(1:TrainRes.iter)));ymin=min(ymin,min(TrainRes.sjctrain(1:TrainRes.iter)));
ymin=min(ymin,min(TrainRes.sjcval(1:TrainRes.iter)));
if cnt_jctest>1
    ymin=min(ymin,min(TrainRes.sjctest(1:TrainRes.iter)));
end
ymax=-1e20; ymax=max(ymax,max(TrainRes.resnorm(1:TrainRes.iter)));ymax=max(ymax,max(TrainRes.sjctrain(1:TrainRes.iter)));
ymax=max(ymax,max(TrainRes.sjcval(1:TrainRes.iter)));ymax=max(ymax,max(TrainRes.sjctest(1:TrainRes.iter)));
ymin=floor(log10(ymin))-1;
ymax=floor(log10(ymax))+1;
if ymax==inf
    ymax=50;
end
if ymin==-inf
    ymin=0;
end
scal=10.^(ymin:ymax);
set(gca,'YLim',[10^ymin 10^ymax],'YTick',scal);    
a = get(gca,'XTickLabel'); 
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
a = get(gca,'YTickLabel');
set(gca,'YTickLabel',a,'FontName','Times','fontsize',18)
legend('fobj','train','valid','test')
xlabel('# iteration','FontName','Times','fontsize',18)
ylabel('MSE','FontName','Times','fontsize',18)
title('concentrations','FontName','Times','fontsize',20)

% figure%--------------------------------------------------------------------
% bar(x,AICc,'EdgeColor','b','FaceColor',[1 0.2 0.87],'LineWidth',2)
% set(gca,'linewidth',2)
% xlabel('# iteration','FontName','Times','fontsize',18)
% ylabel('AICc','FontName','Times','fontsize',18)
% a = get(gca,'XTickLabel'); 
% set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
% a = get(gca,'YTickLabel');
% set(gca,'YTickLabel',a,'FontName','Times','fontsize',18)

% Histogram of MSE concentrations for training
figure
subplot(2,2,1)
[N,histdata]=hist(TrainRes.mj(:,2));
bar(histdata,N,'EdgeColor','b','FaceColor',[1 0.2 0.87],'LineWidth',2);
set(gca,'LineWidth',2);
xlim('manual');
ylim('manual');
xmin=floor(min(histdata)*0.8);
xmax=floor(max(histdata)*1.2);
if xmin==xmax %failsafe for when the minimum and maximum are very close
    xmax=xmin+1;
end
xscal=linspace(xmin,xmax,5);
ymax=(floor(max(N)/5)+1)*5;
set(gca,'XLim',[xmin xmax],'XTick',xscal);    
set(gca,'YLim',[0 ymax],'YTick',(0:ymax/5:ymax));    
xlabel('MSE_c (train)','FontName','Times','fontsize',18)
ylabel('count','FontName','Times','fontsize',18)
a = get(gca,'XTickLabel'); 
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
a = get(gca,'YTickLabel');
set(gca,'YTickLabel',a,'FontName','Times','fontsize',18)

% Histogram of MSE concentrations for validation
subplot(2,2,2)
[N,histdata]=hist(TrainRes.mj(:,3));
bar(histdata,N,'EdgeColor','b','FaceColor',[1 0.2 0.87],'LineWidth',2);
set(gca,'LineWidth',2);
xlim('manual');
ylim('manual');
xmin=floor(min(histdata)*0.8);
xmax=floor(max(histdata)*1.2);
if xmin==xmax %failsafe for when the minimum and maximum are very close
    xmax=xmin+1;
end
xscal=linspace(xmin,xmax,5);
ymax=(floor(max(N)/5)+1)*5;
set(gca,'XLim',[xmin xmax],'XTick',xscal);    
set(gca,'YLim',[0 ymax],'YTick',(0:ymax/5:ymax));    
xlabel('MSE_c (valid)','FontName','Times','fontsize',18)
ylabel('count','FontName','Times','fontsize',18)
a = get(gca,'XTickLabel'); 
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
a = get(gca,'YTickLabel');
set(gca,'YTickLabel',a,'FontName','Times','fontsize',18)

% Histogram of MSE rates training
subplot(2,2,3)
[N,histdata]=hist(TrainRes.mj(:,5));
bar(histdata,N,'EdgeColor','b','FaceColor',[1 0.2 0.87],'LineWidth',2);
set(gca,'LineWidth',2);
xlim('manual');
ylim('manual');
xmin=floor(min(histdata)*0.8);
xmax=floor(max(histdata)*1.2);
if xmin==xmax %failsafe for when the minimum and maximum are very close
    xmax=xmin+1;
end
xscal=linspace(xmin,xmax,5);
ymax=(floor(max(N)/5)+1)*5;
set(gca,'XLim',[xmin xmax],'XTick',xscal);    
set(gca,'YLim',[0 ymax],'YTick',(0:ymax/5:ymax));    
xlabel('MSE_r (train)','FontName','Times','fontsize',18)
ylabel('count','FontName','Times','fontsize',18)
a = get(gca,'XTickLabel'); 
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
a = get(gca,'YTickLabel');
set(gca,'YTickLabel',a,'FontName','Times','fontsize',18)

% Histogram of MSE rates validation
subplot(2,2,4)
[N,histdata]=hist(TrainRes.mj(:,6));
bar(histdata,N,'EdgeColor','b','FaceColor',[1 0.2 0.87],'LineWidth',2);
set(gca,'LineWidth',2);
xlim('manual');
ylim('manual');
xmin=floor(min(histdata)*0.8);
xmax=floor(max(histdata)*1.2);
if xmin==xmax %failsafe for when the minimum and maximum are very close
    xmax=xmin+1;
end
xscal=linspace(xmin,xmax,5);
ymax=(floor(max(N)/5)+1)*5;
set(gca,'XLim',[xmin xmax],'XTick',xscal);    
set(gca,'YLim',[0 ymax],'YTick',(0:ymax/5:ymax));    
xlabel('MSE_r (valid)','FontName','Times','fontsize',18)
ylabel('count','FontName','Times','fontsize',18)
a = get(gca,'XTickLabel'); 
set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
a = get(gca,'YTickLabel');
set(gca,'YTickLabel',a,'FontName','Times','fontsize',18)

%
% select the best iteration among all iterations as the one with the minimum
% validation error; show fnal results and select ANN weights
%
if projhyb.crossval==1
    ind=find(TrainRes.sjcval(1:TrainRes.iter)==min(TrainRes.sjcval(1:TrainRes.iter)));
    istep=ind(1);
else
    ind=find(TrainRes.sjctrain(1:TrainRes.iter)==min(TrainRes.sjctrain(1:TrainRes.iter)));
    istep=ind(1);
end
fprintf('\n\nBest step: %u\n',istep)
wfinal=TrainRes.witer(istep,:)';
projhyb.w=wfinal;
projhyb.wensemble=TrainRes.wstep;
fprintf('STEP  RESNORM    [C]train   [C]valid   [C]test   [R]train   [R]valid   [R]test    AICc       NW   CPU\n')        
fprintf('%3u %10.2E %10.2E %10.2E %10.2E %10.2E %10.2E %10.2E %10.2E %3u\n',...
        istep, TrainRes.resnorm(istep),...
        TrainRes.sjctrain(istep),TrainRes.sjcval(istep),TrainRes.sjctest(istep),...
        TrainRes.sjrtrain(istep),TrainRes.sjrval(istep),TrainRes.sjrtest(istep),...
        TrainRes.AICc(istep),projhyb.mlm.nw);
fprintf('AVE %10.2E %10.2E %10.2E %10.2E %10.2E %10.2E %10.2E %10.2E None\n',...
        mean(TrainRes.mj(:,1)),mean(TrainRes.mj(:,2)),mean(TrainRes.mj(:,3)),mean(TrainRes.mj(:,4)),...
        mean(TrainRes.mj(:,5)),mean(TrainRes.mj(:,6)),mean(TrainRes.mj(:,7)),mean(TrainRes.mj(:,8)));
fprintf('STD %10.2E %10.2E %10.2E %10.2E %10.2E %10.2E %10.2E %10.2E None\n',...
        std(TrainRes.mj(:,1)),std(TrainRes.mj(:,2)),std(TrainRes.mj(:,3)),std(TrainRes.mj(:,4)),...
        std(TrainRes.mj(:,5)),std(TrainRes.mj(:,6)),std(TrainRes.mj(:,7)),std(TrainRes.mj(:,8)));
fprintf('CPU: %10.2E\n',TrainRes.finalcpu);
return
%
% training stops here 
% in what follows is a nested function this is a nested functiom to produce
% ioutput during optimization; this function is called by lsqnonlin or
% fminunc
%
function [stop, optnew , changed]=outFun1(witer,optimValues,optstate,projhyb)%%
stop = false; optnew=[]; changed=false;
if projhyb.method==3 % this might need some changes in the future
    witer=optimValues.x;
end
switch optstate
    case 'init'
        TrainRes.iter0=TrainRes.iter+1;
        TrainRes.count=0;
        return;
    case 'iter'
        TrainRes.count=TrainRes.count+1;
        if projhyb.method==1
            fvaliter=optimValues.residual'*...
              optimValues.residual/numel(optimValues.residual);
        else
             fvaliter = optimValues.fval; %/cnt_jctrain;
        end
        if TrainRes.count<projhyb.niteroptim
         %   fprintf('%3u %10.2E %10.2E %10.2E %10.2E %10.2E %10.2E %10.2E %10.2E %3u %10.2E\n',...
         %       TrainRes.count, fvaliter,[],[],[],[],[],[],[],[],cputime-TrainRes.t0);
        else
            TrainRes.count=0;
            TrainRes=hybtrainiterres(TrainRes,witer,fvaliter,projhyb);
        end
    case 'done'
        if projhyb.method==1
           fvaliter=optimValues.residual'*...
           optimValues.residual/numel(optimValues.residual);
        else
           fvaliter = optimValues.fval; %/cnt_jctrain;
        end
        TrainRes=hybtrainiterres(TrainRes,witer,fvaliter,projhyb); % nested function
        TrainRes.istep=TrainRes.istep+1;
        ind=TrainRes.iter0:TrainRes.iter;
        if projhyb.crossval==1
            ibest=find(TrainRes.sjcval(ind)==min(TrainRes.sjcval(ind)));
            ibest = ibest(1)+TrainRes.iter0-1;
         else
            ibest = TrainRes.iter;
        end
        TrainRes.mj(TrainRes.istep,1:8)=[TrainRes.resnorm(ibest),...
                TrainRes.sjctrain(ibest),...
                TrainRes.sjcval(ibest),...
                TrainRes.sjctest(ibest),...
                TrainRes.sjrtrain(ibest),...
                TrainRes.sjrval(ibest),...
                TrainRes.sjrtest(ibest),...
                TrainRes.AICc(ibest)];
        TrainRes.wstep(TrainRes.istep,1:projhyb.mlm.nw)=TrainRes.witer(ibest,1:projhyb.mlm.nw);
    case 'interrupt'
        %the algorithm is performing an iteration
        %do nothing
    otherwise
        disp('big error')
        optstate
        pause
        return;        
end
return
%
% function ends here; in what follows is a nested function
%
end% outer nested function ends here 
end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INDIRECT METHOD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [sres, sjac, shess]=resfun_indirect_fminunc_hess(w,istrain,projhyb)

ns=projhyb.nstate;
nw=projhyb.mlm.nw;
isres=projhyb.isres;
nres=length(isres);
if ~isempty(projhyb.mlmsetwfunc)
    projhyb.mlm.fundata=feval(projhyb.mlmsetwfunc,projhyb.mlm.fundata,w); %set weigths 
end
sres=0;
sjac=zeros(1,nw);
shess=zeros(nw,nw);

COUNT = 0;

for l=1:projhyb.nbatch%-----

    if istrain(l) == 1%-------
    
        tb= projhyb.batch(l).t;
        Y= projhyb.batch(l).state;
        upars = projhyb.batch(l).u;
        sY=projhyb.batch(l).sc;
        np = length(tb);

        state = projhyb.batch(l).state(1,:)';
        Sw=zeros(ns,nw);
        Hsw=zeros(ns*nw,nw);
          
        for i=2:np
            
            [~,state,Sw,Hsw]=hybodesolver(projhyb.fun_hybodes_jac_hess,...
                projhyb.fun_control,projhyb.fun_event,tb(i-1),tb(i),state,Sw,Hsw,w,upars,...
                projhyb);
            
            for j=1:nres
                k1 = isres(j);
                if ~isnan(Y(i,k1))
                    COUNT = COUNT+1;
                    res = (Y(i,k1) - state(k1,1)')./sY(i,k1);
                    sres = sres + res*res;
                    sjac=  sjac -2*res/sY(i,k1)*Sw(k1,:);              
                    shess = shess + (2/sY(i,k1)^2)*Sw(k1,1:nw)'*Sw(k1,1:nw)...
                        -(2*res/sY(i,k1))*Hsw((k1-1)*nw+1:k1*nw,1:nw);
             
                end
            end
                        
        end
    
    end
end
sres=sres/COUNT;
sjac=sjac/COUNT;
shess=shess/COUNT;
end%-----------------------------------------------------------------------

function [sres, sjac]=resfun_indirect_fminunc(w,istrain,projhyb)%%%%%%%%%%%%%%%%%%%
ns=projhyb.nstate;
nw=projhyb.mlm.nw;
isres=projhyb.isres;
nres=projhyb.nres;
if ~isempty(projhyb.mlmsetwfunc)
    projhyb.mlm.fundata=feval(projhyb.mlmsetwfunc,projhyb.mlm.fundata,w); %set weigths 
end

sres=0;
sjac=zeros(1,nw);

COUNT = 0;
for l=1:projhyb.nbatch%-----

    if istrain(l)== 1%-------
    
        tb= projhyb.batch(l).t;
        Y= projhyb.batch(l).state;
        upars = projhyb.batch(l).u;
        sY=projhyb.batch(l).sc;
        np = length(tb);

        state = projhyb.batch(l).state(1,:)';
        Sw=zeros(ns,nw);
   
        for i=2:np           
            [~,state,Sw]=hybodesolver(projhyb.fun_hybodes_jac,...
                projhyb.fun_control,projhyb.fun_event,tb(i-1),tb(i),state,Sw,0,w,upars,...
                projhyb);
            for j=1:nres
               k1 = isres(j);
               if ~isnan(Y(i,k1))
                    res = (Y(i,k1) - state(k1,1)')./sY(i,k1);
                    sres = sres + res*res;
                    sjac=  sjac + -2*res/sY(i,k1)*Sw(k1,:);
                    COUNT = COUNT+1;
               end
            end
            
        end
    
    end
end
sres=sres/COUNT;
sjac=sjac/COUNT;
end%-----------------------------------------------------------------------

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% INDIRECT METHOD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fobj, jac]=resfun_indirect_jac(w,istrain,projhyb,method)%%%%%
if nargin<4
    method=1;
end
if isempty(istrain)
    istrain=projhyb.istrain;
end    

ns=projhyb.nstate;
nw=projhyb.mlm.nw;
isres=projhyb.isres;
nres=projhyb.nres;
projhyb.mlm.fundata=feval(projhyb.mlmsetwfunc,projhyb.mlm.fundata,w); %set weigths 
npall=0;
for l=1:projhyb.nbatch
    if istrain(l) == 1
       npall=npall+projhyb.batch(l).np;
    end
end
sresall = zeros(npall*nres,1);
sjacall = zeros(npall*nres,projhyb.mlm.nw);

COUNT = 1;
for l=1:projhyb.nbatch%-----

    if istrain(l) == 1%-------
    
        tb=projhyb.batch(l).t;
        Y= projhyb.batch(l).state;
        batch = projhyb.batch(l);
        sY=projhyb.batch(l).sc;
        state = projhyb.batch(l).state(1,:)';
        Sw=zeros(ns,nw);

        for i=2:projhyb.batch(l).np
            
            [~,state,Sw]=hybodesolver(projhyb.fun_hybodes_jac,...
                projhyb.fun_control,projhyb.fun_event,tb(i-1),tb(i),state,Sw,0,[],batch,...
                projhyb);
            sresall(COUNT:COUNT+nres-1,1) = (Y(i,isres)' - state(isres,1))./sY(i,isres)';
            sjacall(COUNT:COUNT+nres-1,1:nw)= - Sw(isres,:)./repmat(sY(i,isres)',1,nw);
            COUNT = COUNT+nres;
        
        end
    
    end
end
%finally remove missing values from residuals
ind = ~isnan(sresall);
sresall = sresall(ind);
sjacall = sjacall(ind,:);
ind = ~isinf(sresall); %Remove infinity values from residuals
sresall = sresall(ind);
sjacall = sjacall(ind,:);
fobj=nan;
if method==1 || method==4  %return the sum of squared errors
   fobj=sresall;
   jac=sjacall;
else   %return the sum of squared errors
   fobj=sresall'*sresall/numel(sresall);
   jac=sum(2*repmat(sresall,1,nw).*sjacall,1)/numel(sresall);
end
end%-----------------------------------------------------------------------

function [mse, grads]=resfun_semidirect_jac_batch(w,istrain,projhyb,method)%%%%%   
if nargin<4
    method=1;
end
if nargin<3
    istrain=projhyb.istrain;
end    
ns=projhyb.nstate;
nw=projhyb.mlm.nw;
isres=projhyb.isres;
nres=projhyb.nres;
% npall=0;
% for l=1:projhyb.nbatch
%     if istrain(l) == 1
%        npall=npall+projhyb.batch(l).np;
%     end
% end
% resall = zeros(npall*nres,1);
% jacall = zeros(npall*nres,nw);



projhyb.mlm.fundata=feval(projhyb.mlmsetwfunc,projhyb.mlm.fundata,w); %set weigths 



COUNT = 1;
mse = 0;
grads=zeros(1,nw);

for l=1:projhyb.nbatch%-----

    if istrain(l) == 1%-------
    
        tb=projhyb.batch(l).t;
        Y= projhyb.batch(l).state;
        upars = projhyb.batch(l).u;
        sY=projhyb.batch(l).sc;
        state = projhyb.batch(l).state(1,:)';
        Sw=zeros(ns,nw);
        DstateDrann=zeros(ns,projhyb.mlm.ny);

       
        for i=2:projhyb.batch(l).np
            
            [~,state,DstateDrann]=hybodesolver(projhyb.fun_hybodes_jac,...
                projhyb.fun_control,projhyb.fun_event,tb(i-1),tb(i),state,DstateDrann,0,w,projhyb.batch(l),...
                projhyb);
            
            res=zeros(1,ns);
            res(1,isres) = (Y(i,isres) - state(isres,1)')./sY(i,isres);
            ind =~isnan(res); %missing values
            mse_i = res(1,ind)*res(1,ind)';
            
            DmseDsate=zeros(1,ns);
            DmseDsate(1,ires)=-2*res./sY(i,isres);
            DmseDsate(~ind)=0;  % missing values
            
            DmseDrann=DmseDsate*DstateDrann;
            
            ucontrol = feval(projhyb.fun_control,tb(i),projhyb.batch(l));  
            [inp] = feval(projhyb.mlm.xfun,tb(i),state,ucontrol);
            [~,~,DmseDw] = feval(projhyb.mlm.yfun,inp,w,projhyb.mlm.fundata,DmseDrann);

            mse = mse + mse_i;
            grads = grads + DmseDw;
            
            COUNT = COUNT + nres;
        
        end

    end
end
%finally remove missing values from residuals
mse = mse /count;
grads = grads /count;

end%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [fobj]=resfun_indirect(w,istrain,projhyb,method)%-------------------
if nargin<4
    method=1;
end
if nargin<3
    istrain=projhyb.istrain;
end    
ns=projhyb.nstate;
nw=projhyb.mlm.nw;
isres=projhyb.isres;
nres=projhyb.nres;
projhyb.mlm.fundata=feval(projhyb.mlmsetwfunc,projhyb.mlm.fundata,w); %set weigths 
npall=0;
for l=1:projhyb.nbatch
    if istrain(l) == 1
       npall=npall+projhyb.batch(l).np;
    end
end
resall = zeros(npall*nres,1);

COUNT = 1;
for l=1:projhyb.nbatch%-----

    if istrain(l) == 1%-------
    
        tb= projhyb.batch(l).t;
        Y= projhyb.batch(l).state;
        upars = projhyb.batch(l).u;
        sY=projhyb.batch(l).sc;
        np = length(tb);

        state = projhyb.batch(l).state(1,:)';
    
        for i=2:np
            
             [~,state]=hybodesolver(projhyb.fun_hybodes,...
                projhyb.fun_control,projhyb.fun_event,tb(i-1),tb(i),state,0,0,w,upars,...
                projhyb);
            resall(COUNT:COUNT+nres-1,1) = (Y(i,isres)' - state(isres,1))./sY(i,isres)';
            COUNT = COUNT+nres;
        
        end
    
    end
end

%finally remove missing values from residuals
ind = ~isnan(resall);
resall=resall(ind);
ind = ~isinf(resall); %Remove infinity values from residuals
resall = resall(ind);

fobj=nan;
if method==1   %return the sum of squared errors
   fobj=resall;
else   %return the sum of squared errors
   fobj=resall'*resall/numel(resall);
end
end%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% DIRECT METHOD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fobj, jac]=resfun_direct_jac(w,istrain,projhyb,method)%%%%%
if nargin<4
    method=1;
end    
if nargin<3
    istrain=projhyb.istrain;
end    

isress=projhyb.isresstate;
ns=length(isress);
nw=projhyb.mlm.nw;
projhyb.mlm.fundata=feval(projhyb.mlmsetwfunc,projhyb.mlm.fundata,w); %set weigths 
npall=0;
for l=1:projhyb.nbatch
    if istrain(l) == 1
       npall=npall+projhyb.batch(l).np;
    end
end
resall = zeros(npall*ns,1);
jacall = zeros(npall*ns,nw);
COUNT = 1;
for l=1:projhyb.nbatch%-----

    if istrain(l) == 1%-------    
        tb= projhyb.batch(l).t;
        r= projhyb.batch(l).rnoise;
        upars = projhyb.batch(l).u;
        sr=projhyb.batch(l).sr;
        np = length(tb);
        for i=1:np
            tt=tb(i);
            state = projhyb.batch(l).state(i,:)';
            ucontrol = feval(projhyb.fun_control,tt,upars);            
            [rhyb_v,~,~,DrhybDw] = feval(projhyb.fun_hybrates_jac,tt,state,w,ucontrol,projhyb);
            resall(COUNT:COUNT+ns-1,1) = (r(i,isress)' - rhyb_v(isress,1))./sr(i,isress)';
            jacall(COUNT:COUNT+ns-1,1:nw) = -DrhybDw(isress,:)./repmat(sr(i,isress)',1,nw);
            COUNT = COUNT+ns;
        end    
    end
    
end
%finally remove missing values from residuals
ind=~isnan(resall);
resall=resall(ind);
jacall=jacall(ind,:);
ind = ~isinf(resall); %Remove infinity values from residuals
resall = resall(ind);
jacall = jacall(ind,:);
fobj=nan;
if method==1   %levenbergmarquardt
   fobj=resall;
   jac=jacall;
else
   fobj=resall'*resall/numel(resall);
   jac=sum(2*repmat(resall,1,nw).*jacall,1)/numel(resall);
end
end%-----------------------------------------------------------------------


function [fobj]=resfun_direct(w,istrain,projhyb,method)%---------------------
if nargin<4
    method=1;
end
if nargin<3
    istrain=projhyb.istrain;
end    
isress=projhyb.isresstate;
ns=length(isress);
projhyb.mlm.fundata=feval(projhyb.mlmsetwfunc,projhyb.mlm.fundata,w); %set weigths 
npall=0;
for l=1:projhyb.nbatch
    if istrain(l) == 1
       npall=npall+projhyb.batch(l).np;
    end
end
resall = zeros(npall*ns,1);
COUNT = 1;
for l=1:projhyb.nbatch%-----

    if istrain(l) == 1%-------    
        tb= projhyb.batch(l).t;
        r= projhyb.batch(l).rnoise;
        upars = projhyb.batch(l).u;
        sr=projhyb.batch(l).sr;
        np = length(tb);
        for i=1:np
            tt=tb(i);
            state = projhyb.batch(l).state(i,:)';
            ucontrol = feval(projhyb.fun_control,tt,upars);            
            [rhyb_v,~] = feval(projhyb.fun_hybrates,tt,state,w,ucontrol,projhyb);
            resall(COUNT:COUNT+ns-1,1) = (r(i,isress)' - rhyb_v(isress,1))./sr(i,isress)';
            COUNT = COUNT+ns;
        end    
    end
    
end
ind=~isnan(resall);
resall=resall(ind);
ind = ~isinf(sresall); %Remove infinity values from residuals
resall = resall(ind);
fobj=nan;
if method==1   %levenbergmarquardt
   fobj=resall;
else   %return the sum of squared errors
   fobj=resall'*resall/numel(resall);
end
end%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SEMIDIRECT METHOD
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [fobj]=resfun_semidirect(w,istrain,projhyb,method)%%%%%
if nargin<4
    method=1;
end
if nargin<3
    istrain=projhyb.istrain;
end    
isress=projhyb.isresstate;
ns=length(isress);
npall=0;
for l=1:projhyb.nbatch
    if istrain(l) == 1
       npall=npall+projhyb.batch(l).np;
    end
end
resall = zeros(npall*ns,1);
projhyb.mlm.fundata=feval(projhyb.mlmsetwfunc,projhyb.mlm.fundata,w); %set weigths 
COUNT = 1;
for l=1:projhyb.nbatch%-----

    if istrain(l) == 1%-------    
        tb= projhyb.batch(l).t;
        r= projhyb.batch(l).rnoise;
        upars = projhyb.batch(l).u;
        sr=projhyb.batch(l).sr;
        np = length(tb);
        for i=1:np-1
            tt=tb(i);
            state = projhyb.batch(l).state(i,:)';
            ucontrol = feval(projhyb.fun_control,tt,upars);            
            [rhyb_v,~] = feval(projhyb.fun_hybrates,tt,state,w,ucontrol,projhyb);
            if i==1
                resall(COUNT:COUNT+ns-1,1) = zeros(ns,1);
            end
            %this function is not suited to missing values????????????????
            resall(COUNT+ns:COUNT+ns+ns-1,1) = resall(COUNT:COUNT+ns-1,1)+(r(i,:)' - rhyb_v(isress,1))./sr(i,isress)';
            COUNT = COUNT+ns;
        end    
    end
    
end
ind = ~isnan(resall);
resall=resall(ind);
ind = ~isinf(resall); %Remove infinity values from residuals
resall = resall(ind);
fobj=nan;
if method==1   %levenbergmarquardt
    fobj=resall;
else
    fobj=resall'*resall/numel(resall);
end
end%-----------------------------------------------------------------------


function [fobj, jac]=resfun_semidirect_jac(w,istrain,projhyb,method)%%%%%   
if nargin<4
    method=1;
end
if nargin<3
    istrain=projhyb.istrain;
end    
ns=projhyb.nstate;
nw=projhyb.mlm.nw;
isres=projhyb.isres;
nres=projhyb.nres;
npall=0;
for l=1:projhyb.nbatch
    if istrain(l) == 1
       npall=npall+projhyb.batch(l).np;
    end
end
resall = zeros(npall*nres,1);
jacall = zeros(npall*nres,nw);
projhyb.mlm.fundata=feval(projhyb.mlmsetwfunc,projhyb.mlm.fundata,w); %set weigths 
COUNT = 1;
for l=1:projhyb.nbatch%-----

    if istrain(l) == 1%-------
    
        tb=projhyb.batch(l).t;
        Y= projhyb.batch(l).state;
        upars = projhyb.batch(l).u;
        sY=projhyb.batch(l).sc;
        state = projhyb.batch(l).state(1,:)';
        Sw=zeros(ns,nw);
        jac=zeros(ns,projhyb.mlm.ny);

       
        for i=2:projhyb.batch(l).np
            
            [~,state,jac]=hybodesolver(projhyb.fun_hybodes_jac,...
                projhyb.fun_control,projhyb.fun_event,tb(i-1),tb(i),state,jac,0,w,projhyb.batch(l),...
                projhyb);
            ucontrol = feval(projhyb.fun_control,tb(i),projhyb.batch(l));  
            [inp] = feval(projhyb.mlm.xfun,tb(i),state,ucontrol);
            [~,~,DrannDw] =feval(projhyb.mlm.yfun,inp,w,projhyb.mlm.fundata);
            Sw=jac*DrannDw;
            resall(COUNT:COUNT+nres-1,1) = (Y(i,isres)' - state(isres,1))./sY(i,isres)';
            jacall(COUNT:COUNT+nres-1,1:nw)= - Sw(isres,:)./repmat(sY(i,isres)',1,nw);
            COUNT = COUNT+nres;
        
        end


    end
end
%finally remove missing values from residuals
ind = ~isnan(resall);
resall = resall(ind);
jacall = jacall(ind,:);
ind = ~isinf(resall); %Remove infinity values from residuals
resall = resall(ind);
jacall = jacall(ind,:);
fobj=nan;
if method==1 || method==4 %levenbergmarquardt or ADAM
    fobj=resall;
    jac=jacall;
else
    fobj=resall'*resall/numel(resall);
    jac=sum(2*repmat(resall,1,nw).*jacall,1)/numel(resall);
end
end%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

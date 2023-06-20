function projhyb=hybreaddata(projhyb)
% HYBREADDATA reads data for training data
%
%[projhyb] = HYBREADDATA(projhyb)
%
% INPUT ARGUMENTS
% projhyb           Data strtucture holding information of the hybrid model, 
%                   data and traning method
%
% OUTPUT ARGUMENTS
% projhyb           Updated data strtucture holding information of the 
%                   experimental data to train the model
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


if projhyb.datasource == 3  %experimental 
    [nbatch, batch]=feval(projhyb.datafun);
    projhyb.nbatch=nbatch;
    projhyb.batch=batch;
elseif projhyb.datasource == 1
    disp('reading data from textfile not yet implemented!!!!!')
    stop
elseif projhyb.datasource == 2
    disp('reading data from excelfile not yet implemented!!!!!')
    stop
end

%
% Data pre-processing for hybrid modeling 
%
uall=[];
cnoiseall=[];
rnoiseall=[];

for i=1:projhyb.nbatch
  
    projhyb.batch(i).np=        length(projhyb.batch(i).t);
    %
    % Create a virtual validation set by adding gaussian noise to the
    % measured data;
    %
    projhyb.batch(i).cvalid = projhyb.batch(i).c_true...
          +randn(projhyb.batch(i).np,projhyb.nspecies)...
          .*projhyb.batch(i).sc(1:projhyb.batch(i).np,1:projhyb.nspecies);
    projhyb.batch(i).statevl=[projhyb.batch(i).cvalid,...
                                projhyb.batch(i).vol,...
                                projhyb.batch(i).raterule];
    projhyb.batch(i).cvalid(1,:)=projhyb.batch(i).c_true(1,:);
    %NO ERROR ONLY%
%      projhyb.batch(i).cnoise=projhyb.batch(i).c_true;
%      projhyb.batch(i).cvalid=projhyb.batch(i).c_true;
%      projhyb.batch(i).statevl=[projhyb.batch(i).cvalid,...
%                                 projhyb.batch(i).vol,...
%                                 projhyb.batch(i).raterule];
%      projhyb.batch(i).state=projhyb.batch(i).statevl;                       
    %%%%%%%%%%%%%%%%%%
    
    %
    % estimated volumetrix reaction rates
    % this part is important for 1) direct trainng, 2) plotting of
    % model/plant mismatch
    %
    projhyb.batch(i).rnoise=zeros(size(projhyb.batch(i).cnoise));
    projhyb.batch(i).rvalid=zeros(size(projhyb.batch(i).cnoise));
    projhyb.batch(i).sr=ones(size(projhyb.batch(i).cnoise));
%??????????????????????????????????????????????????????????????????????????
%     for j=1:projhyb.nspecies
%         sp = csaps(t,cnoise(:,j),0.8); %why 0.8???????
%         projhyb.batch(i).rnoise(:,j)=fnval(fnder(sp),t)./vol;
%         sp = csaps(t,projhyb.batch(i).cvalid(:,j),0.8);  %why 0.8???????
%         projhyb.batch(i).rvalid(:,j)=fnval(fnder(sp),t)./vol;
%         projhyb.batch(i).sr(:,j)=2*sc(:,j);
%     end    
%??????????????????????????????????????????????????????????????????????????
    for k=1:projhyb.batch(i).np-1
        projhyb.batch(i).rnoise(k,:)=...
        (projhyb.batch(i).cnoise(k+1,:)-projhyb.batch(i).cnoise(k,:))...
            /(projhyb.batch(i).t(k+1)-projhyb.batch(i).t(k));
    end
    projhyb.batch(i).rnoise(projhyb.batch(i).np,:)=...
                 projhyb.batch(i).rnoise(projhyb.batch(i).np-1,:);
    projhyb.batch(i).sr=2*projhyb.batch(i).sc(:,1:projhyb.nspecies);
    
%     %REAL ONLY%
%         for k=1:projhyb.batch(i).np-1
%         projhyb.batch(i).rnoise(k,:)=...
%         (projhyb.batch(i).c_true(k+1,:)-projhyb.batch(i).c_true(k,:))...
%             /(projhyb.batch(i).t(k+1)-projhyb.batch(i).t(k));
%     end
%     projhyb.batch(i).rnoise(projhyb.batch(i).np,:)=...
%                  projhyb.batch(i).rnoise(projhyb.batch(i).np-1,:);
%     projhyb.batch(i).sr=2*projhyb.batch(i).sc(:,1:projhyb.nspecies);
    %%%%%%%%%%%
    
 %??????????????????????????????????????????????????????????????????????????       

    cnoiseall=[cnoiseall; projhyb.batch(i).cnoise];
    rnoiseall=[rnoiseall; projhyb.batch(i).rnoise];
    uall=[uall; projhyb.batch(i).ualongtime];

end

[projhyb.np,~]=size(cnoiseall);
projhyb.cmean=mean(cnoiseall,1);
projhyb.cstd=std(cnoiseall,0,1);
projhyb.rmean=mean(rnoiseall,1);
projhyb.rstd=std(rnoiseall,0,1);
projhyb.umean=mean(uall,1);
projhyb.ustd=std(uall,0,1);
projhyb.cabsmax=max(abs(cnoiseall),[],1);
projhyb.cmax=max(cnoiseall,[],1);
projhyb.cmin=min(cnoiseall,[],1);
projhyb.rabsmax=max(abs(rnoiseall),[],1);
projhyb.rmax=max(rnoiseall,[],1);
projhyb.rmin=min(rnoiseall,[],1);

end%----------------------------------------------------------------------

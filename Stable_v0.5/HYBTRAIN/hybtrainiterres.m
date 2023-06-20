function TrainRes=hybtrainiterres(TrainRes,witer,fvaliter,projhyb) %%%%%%%%%%%%%
% HYBTRAINITERRES computes model-data training metrics after a training iteration 
% it creates a new entry on data structure TrainRes and saves the results
% for witer on the new entry
%
% TrainRes=HYBTRAINITERRES(TrainRes,witer,fvaliter,projhyb)
%
% INPUT ARGUMENTS
% TrainRes          Data structure holding information on training
%                   progress over iteration and over step
% witer             vetctor holding model parameters  for a the new iteration
% fvaliter          resnorm for witer computed by the optimnisation method
% projhyb           Data strtucture holding information of the hybrid model, 
%                   data and traning method
%
% OUTPUT ARGUMENTS
% TrainRes          Updated data structure holding information on training
%                   progress over iteration and over step with a new entry 
%                   of model-data mismatch for witer
%
% Copyright, 2021 -
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
TrainRes.iter=TrainRes.iter+1;
TrainRes.witer(TrainRes.iter,1:projhyb.mlm.nw)=witer';
TrainRes.sjctrain(TrainRes.iter)=0;
TrainRes.sjcval(TrainRes.iter)=0;
TrainRes.sjctest(TrainRes.iter)=0;
TrainRes.sjrtrain(TrainRes.iter)=0;
TrainRes.sjrval(TrainRes.iter)=0;
TrainRes.sjrtest(TrainRes.iter)=0;
TrainRes.AICc(TrainRes.iter)=0;
cnt_jctrain=0;   cnt_jcval=0;    cnt_jctest=0;    
for i=1:projhyb.nbatch
        [nres,~,jctr,~,jcvl,~,jrtr,~,jrvl]=hybbatcherrors(projhyb,...
               witer,projhyb.batch(i));            
        if projhyb.istrain(i)==1   % training batch
            TrainRes.sjctrain(TrainRes.iter)=TrainRes.sjctrain(TrainRes.iter)+jctr; 
            TrainRes.sjcval(TrainRes.iter)=TrainRes.sjcval(TrainRes.iter)+jcvl;
            TrainRes.sjrtrain(TrainRes.iter)=TrainRes.sjrtrain(TrainRes.iter)+jrtr; 
            TrainRes.sjrval(TrainRes.iter)=TrainRes.sjrval(TrainRes.iter)+jrvl;
            cnt_jctrain=cnt_jctrain+nres;            
        elseif projhyb.istrain(i)==3 % testing batch
            TrainRes.sjctest(TrainRes.iter)=TrainRes.sjctest(TrainRes.iter)+jctr;
            TrainRes.sjrtest(TrainRes.iter)=TrainRes.sjrtest(TrainRes.iter)+jrtr;
            cnt_jctest=cnt_jctest+nres;
        end        
end
cnt_jctrain=max(cnt_jctrain,1);
cnt_jctest=max(cnt_jctest,1);    
TrainRes.sjctrain(TrainRes.iter)=TrainRes.sjctrain(TrainRes.iter)/cnt_jctrain;
TrainRes.sjcval(TrainRes.iter)=TrainRes.sjcval(TrainRes.iter)/cnt_jctrain;
TrainRes.sjctest(TrainRes.iter)=TrainRes.sjctest(TrainRes.iter)/cnt_jctest;
TrainRes.sjrtrain(TrainRes.iter)=TrainRes.sjrtrain(TrainRes.iter)/cnt_jctrain;
TrainRes.sjrval(TrainRes.iter)=TrainRes.sjrval(TrainRes.iter)/cnt_jctrain;
TrainRes.sjrtest(TrainRes.iter)=TrainRes.sjrtest(TrainRes.iter)/cnt_jctest;
TrainRes.AICc(TrainRes.iter)=cnt_jctrain*log(TrainRes.sjctrain(TrainRes.iter))+2*projhyb.mlm.nw+...
           2*projhyb.mlm.nw*(projhyb.mlm.nw+1)/(cnt_jctrain-projhyb.mlm.nw-1);
TrainRes.resnorm(TrainRes.iter)=fvaliter;
fprintf('%3u %10.2E %10.2E %10.2E %10.2E %10.2E %10.2E %10.2E %10.2E %3u %10.2E\n',...
   TrainRes.iter, TrainRes.resnorm(TrainRes.iter),...
   TrainRes.sjctrain(TrainRes.iter),TrainRes.sjcval(TrainRes.iter),...
   TrainRes.sjctest(TrainRes.iter),...
   TrainRes.sjrtrain(TrainRes.iter),TrainRes.sjrval(TrainRes.iter),...
   TrainRes.sjrtest(TrainRes.iter),...
   TrainRes.AICc(TrainRes.iter),projhyb.mlm.nw,cputime-TrainRes.t0);
end% nested function ends here %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 


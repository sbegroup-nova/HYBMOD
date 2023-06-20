function [w,fval]=adamunlnew(lossfunc, w0, ofun, projhyb, options)
% default adam parameters; in future goes to structure options

if isfield(projhyb,"adalfa")
    alfa=projhyb.adalfa;
else
    alfa = 0.001; %AUTOMATE, if undefined, make it n
end
beta1=0.9;
beta2=0.999;
eta=1e-8;

if isfield(projhyb,"admini")
    minibatchsize=projhyb.admini;
else
    minibatchsize = 0.7828; %AUTOMATE, if undefined, make it n
end
if isfield(projhyb,"addrop")
    dropout=projhyb.addrop;
else
    dropout = 0.2172; %AUTOMATE, if undefined, make it n
end
%initialization of variables
w=reshape(w0,numel(w0),1); %weights
m=zeros(numel(w),1);  %first moment vector
v=zeros(numel(w),1); %Second moment vector
u=zeros(numel(w),1); %Second moment vector for ADAMAX

% call outpt function to initialize
feval(ofun,w,[],'init');

% iteration 0
[res]=feval(lossfunc,w,projhyb.istrain);  
optimValues.x=w;
optimValues.fval=res'*res/numel(res);
feval(ofun,w,optimValues,'iter');



for i=1:options.niter  %iteration cylce
  
    

  witer=w;
  
  %minibatch option 2 (Only use some batches)
%   minitrain=zeros(projhyb.nbatch,1);
%   minibatchsize=8;
%   trainbatch=randperm(projhyb.ntrain,minibatchsize);
%   minitrain(trainbatch)=1;
%   projhyb.istrain=minitrain;
%   
  
  %call lossfun get residuals and gradients residuals
  [res,jac]=feval(lossfunc,witer,projhyb.istrain);  

  %minibatch option 1 (Only use some datapoints)
  
  prob=rand(numel(res),1);
  ind= prob <= minibatchsize;
  res=res(ind);
  jac=jac(ind,:);
  
  %calculate objective and gradient
  fval=res'*res/numel(res);    %+lambda*witer'*witer;   %sum of squares
  g=2/numel(res)*sum((repmat(res,1,size(jac,2)).*jac),1)'; %+2*lambda*witer; %batch gradients
  %update weights via ADAMS + dropout
  prob=rand(numel(w),1);
  iw= (prob >= dropout);
  
  m(iw) = beta1*m(iw) + (1-beta1)*g(iw);
  v(iw) = beta2*v(iw) + (1-beta2)*(g(iw).*g(iw));  
  mest = m(iw)/(1-beta1^i);
  vest = v(iw)/(1-beta2^i);
  w(iw) = w(iw) - alfa*(mest./(sqrt(vest)+eta));

  %update the weights according to ADAMS method for the next iteration
%   m = beta1*m + (1-beta1)*g;
%   v = beta2*v + (1-beta2)*(g.*g);  
%   mest = m/(1-beta1^i);
%   vest = v/(1-beta2^i);
%   w = w - alfa*(mest./(sqrt(vest)+eta));
  
  %update the weights according to ADAMAX method for the next iteration
  
 %  m = beta1*m + (1-beta1)*g;
 %  u = max(beta2*u, norm(g));
 %  w = w - (alfa/(1-beta1^i))* m./u;
  
    %update the weights according to ADAM method with weight decay

%   m = beta1*m + (1-beta1)*g;
%   v = beta2*v + (1-beta2)*(g.*g);  
%   mest = m/(1-beta1^i);
%   vest = v/(1-beta2^i);
%   lambdanorm=0.001;
%   lambda = lambdanorm*sqrt(projhyb.nbatch/projhyb.ntrain/options.niter);
%   w = w - alfa*(mest./(sqrt(vest)+eta)+ lambda*w);



  %ADAMAX

%--------------------------------------------------------------------------
% EFICIENT VERSION
%--------------------------------------------------------------------------
%   alfa = alfa0 * (sqrt(1-beta2^(i)))/(1-beta1^(i));
%   w(ind) = w(ind) - alfa*m(ind)./(sqrt(v(ind))+eta);
%--------------------------------------------------------------------------

%adamax--------------------------------------------------------------------
%     m = beta1*m + (1-beta1)*g;
%     u = max(beta2*u, norm(g));
%     w = w - (alfa/(1-beta1^i))* m./u;

%--------------------------------------------------------------------------
    %test
%   [res]=feval(lossfunc,w,projhyb.istrain);  
%   fvalall=res'*res/numel(res);   %sum of squares
%   if fvalall>optimValues.fvalall
%      w=optimValues.x; 
%   else
%       optimValues.x=w;
%       optimValues.fvalall=fvalall;      
%   end
  optimValues.fval=fval;
  optimValues.x=w;      
  
  %add iteration
  %call the output function to display iteration 
  feval(ofun,w,optimValues,'iter');
  
end

%final iteration
%[res]=feval(lossfunc, w, istrain);
%fval=res'*res;
%optimValues.x=w;
%optimValues.fval=fval;
%feval(ofun,w,optimValues,'iter');

%finalize traning
feval(ofun,w,optimValues,'done');

end


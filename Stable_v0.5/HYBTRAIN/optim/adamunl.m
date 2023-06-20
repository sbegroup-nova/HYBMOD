function [w,fval]=adamunl(lossfunc, w0, ofun, projhyb, options)
% default adam parameters; in future goes to structure options
alfa0 = 0.001;
beta1=0.9;
beta2=0.999;
eta=1e-8;
lambdanorm=0.001; %weight decay method
minibatchsize=1;%????
pvisible=0; %probability of dropping out visible nodes
phidden=0; %probability of dropping out hidden nodes
lambda = lambdanorm*sqrt(projhyb.ntrain/minibatchsize/options.niter);
%initialization of variables
w=reshape(w0,numel(w0),1); %weights
m=zeros(numel(w),1);  %first moment vector
v=zeros(numel(w),1); %Second moment vector
u=zeros(numel(w),1); %Exponentially weighted infinity norm

% call outpt function to initialize
feval(ofun,w,[],'init');

% iteration 0
[res]=feval(lossfunc,w,projhyb.istrain);  
optimValues.x=w;
optimValues.fval=res'*res/numel(res);
feval(ofun,w,optimValues,'iter');



for i=1:options.niter  %iteration cylce
  

  %stochastic minibatch selection
  istrain=zeros(projhyb.nbatch,1);
%  ind=randi(projhyb.ntrain,min(floor(projhyb.ntrain/10)+1,projhyb.ntrain),1);
  ind=randi(projhyb.ntrain,minibatchsize); %what is the obtimal minibatch size?
  istrain(projhyb.itr(ind))=1;

  %stochastic dropout - not working - WHY?
  iw=mlpnetstockdropout(projhyb.mlm.fundata,pvisible,phidden);
%  iw=true(numel(w0),1);
  witer=w;
  witer(~iw)=0;
  
  %call lossfun get residuals and gradients residuals
  [res,jac]=feval(lossfunc,witer,istrain);  
  fval=res'*res/numel(res);    %+lambda*witer'*witer;   %sum of squares
  g=2/numel(res)*sum((repmat(res,1,size(jac,2)).*jac),1)'; %+2*lambda*witer; %batch gradients
  
 
  %update the weights according to ADAMS method for the next iteration
  m(iw) = beta1*m(iw) + (1-beta1)*g(iw);
  v(iw) = beta2*v(iw) + (1-beta2)*(g(iw).*g(iw));  
  mest = m(iw)/(1-beta1^i);
  vest = v(iw)/(1-beta2^i);
  alfa = alfa0/sqrt(i);
  alfa = alfa0; 
  w(iw) = w(iw) - alfa*(mest./(sqrt(vest)+eta));

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


function ann=mlpnetcreate(ninp,nout,H,NH,neuron)
% MLPNCREATEUNL creates a a feedforward network project
%
%[ann]=MLPCREATEUNL(ninp,nout,H,NH,neuron)
% INPUT ARGUMENTS
% ninp              Number of nodes in the input layer
% nout              Number of nodes in the output layer
% H                 Number of hidden layers
% NH                Number of nodes in the hidden layer
% neuron            Array of strings with node type in each layer
%                   Example: neuron = {'lin','tanh','sigm','lin'}
%                   if not specified, a network is created with 'lin'
%                   input and output nodes and 'tanh' hidden nodes 
%     
% OUTPUT ARGUMENTS
% ann               Structure holding network information
%
%
% Copyright, 2016 -
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
% $ Version 4.00 $ Date November 2016 $ Not compiled $
assert(nargin>=4,'at least 4 inputs MLPCREATEUNL(ninp,nout,H,NH)');
assert(H<=5,'more than 5 hidden layers not implemented')
ann.nx=ninp;
ann.ny=nout;
ann.h = H;
ann.nl=2+H;
ann.nh = NH(1:H);
ann.nw=(ann.nx+1)*ann.nh(1);
for i=2:H
  ann.nw=ann.nw+(ann.nh(i-1)+1)*ann.nh(i);
end
ann.nw=ann.nw+(ann.nh(H)+1)*ann.ny;
ann.w=randn(ann.nw,1)*0.001; %not actually in use
if H==1
    ann.fun=str2func('mlp1H');
elseif H==2
    ann.fun=str2func('mlp2H');
elseif H==3
    ann.fun=str2func('mlp3H');
elseif H==4
    ann.fun=str2func('mlp4H');
elseif H==5
    ann.fun=str2func('mlp5H');    
end

if neuron==1
    ann.layerff=@tanhff;
    ann.layerbp=@tanhbp;
elseif neuron==2
    ann.layerff=@reluff;
    ann.layerbp=@relubp;
elseif neuron==3
    ann.layerff=@LSTMff;
    ann.layerbp=@LSTMbp;
end



end%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



function [y,layer]=tanhff(x,layer) %tanh layer feedforward, working
y=tanh(layer.w*x+layer.b);
end
function yl=tanhbp(x,y,layer) %tanh layer backprop, working
yl=y.*y-1;
end
function [y,layer]=reluff(x,layer) %ReLU layer feedforward, working
    xin=layer.w*x+layer.b;
    y=max(0.01*xin,0.003*xin);
end

function yl=relubp(x,y,layer) %ReLU layer backprop, working
yl=zeros(size(y));
yl(y>=0)=-0.01;
yl(y<0)=-0.003;
end

function [y,layer]=LSTMff(x,layer)% ---cprev,yprev,w) %LSTM layer feedforward

fg=1/(1+exp(layer.wf*x+layer.wrf*layer.yprev+layer.bfor));
ing=1/(1+exp(layer.win*x+layer.wrin*layer.yprev+layer.bin));
blg=tanh(layer.wbl*x+layer.wrbl*layer.yprev+layer.bprev);
outg=1/(1+exp(layer.wout*x+layer.wrout*layer.yprev+layer.bout));

c=blg.*ing + layer.cprev.*fg;
y=outg.*tanh(c);    
layer.yprev=y;
layer.cprev=c;

end

function yl=LSTMbp(x,y) %LSTM layer backprop
yl=zeros(size(y));
yl(y>0)=1;
yl(y<=0)=0.01;
end

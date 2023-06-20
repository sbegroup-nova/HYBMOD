% PARAMETERIZATION OF CONTROL VARIABLES
function [u]=control_function_leeramirez(t,batch)%------------------------------------

upars=batch.u;
nupars=size(upars,1);
tf=11;
dt=tf/nupars;
i = min(floor(t/dt)+1,nupars);
FeedS = upars(i,1);%Feeding rate substrate
FeedInd = upars(i,2);%Feeding rate inducer

% if 3<=t<=5
%     FeedS = 5;
% else
%     FeedS = 0;
% end

u =[FeedS;FeedInd];
end%-----------------------------------------------------------------------


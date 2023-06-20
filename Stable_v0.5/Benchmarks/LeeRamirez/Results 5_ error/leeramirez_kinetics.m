function [rates,DrDs,DrDrann] = leeramirez_kinetics(t,in2,in3,in4)
%LEERAMIREZ_KINETICS
%    [RATES,DRDS,DRDRANN] = LEERAMIREZ_KINETICS(T,IN2,IN3,IN4)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    31-Mar-2022 17:19:04

FeedS = in4(1,:);
FeedInd = in4(2,:);
Sh = in2(5,:);
V = in2(7,:);
X = in2(1,:);
rann1 = in3(1,:);
rann2 = in3(2,:);
rann3 = in3(3,:);
t2 = Sh.*rann3;
t3 = 1.0./V;
rates = [X.*rann1;FeedS.*t3.*1.0e+2-X.*rann1.*(1.0e+2./5.1e+1);X.*rann2;FeedInd.*t3.*4.0;-t2;t2];
if nargout > 1
    t4 = t3.^2;
    DrDs = reshape([rann1,rann1.*(-1.0e+2./5.1e+1),rann2,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,-rann3,rann3,0.0,0.0,0.0,0.0,0.0,0.0,0.0,FeedS.*t4.*-1.0e+2,0.0,FeedInd.*t4.*-4.0,0.0,0.0],[6,7]);
end
if nargout > 2
    DrDrann = reshape([X,X.*(-1.0e+2./5.1e+1),0.0,0.0,0.0,0.0,0.0,0.0,X,0.0,0.0,0.0,0.0,0.0,0.0,0.0,-Sh,Sh],[6,3]);
end
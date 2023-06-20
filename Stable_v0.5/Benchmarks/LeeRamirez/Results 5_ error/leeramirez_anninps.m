function [anninp,DanninpDstate,DanninpDucontrol] = leeramirez_anninps(t,in2,in3)
%LEERAMIREZ_ANNINPS
%    [ANNINP,DANNINPDSTATE,DANNINPDUCONTROL] = LEERAMIREZ_ANNINPS(T,IN2,IN3)

%    This function was generated by the Symbolic Math Toolbox version 8.5.
%    31-Mar-2022 17:19:04

Ind = in2(4,:);
S = in2(2,:);
Sh = in2(5,:);
anninp = [S./7.0e+1;Ind.*4.0;Sh];
if nargout > 1
    DanninpDstate = reshape([0.0,0.0,0.0,1.0./7.0e+1,0.0,0.0,0.0,0.0,0.0,0.0,4.0,0.0,0.0,0.0,1.0,0.0,0.0,0.0,0.0,0.0,0.0],[3,7]);
end
if nargout > 2
    DanninpDucontrol = reshape([0.0,0.0,0.0,0.0,0.0,0.0],[3,2]);
end
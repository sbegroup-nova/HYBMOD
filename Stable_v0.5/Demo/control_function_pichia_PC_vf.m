% PARAMETERIZATION OF CONTROL VARIABLES
function [u]=control_function_pichia_PC_vf(t,batch)%------------------------------------
upars=batch.u;
i=0;
for n=1:length(batch.t)-1
    if t>=batch.t(n) && t<batch.t(n+1)
        i = n;
    end
end
if i==0
    i=length(batch.t);
end

T = upars(i,1);%Temperature
pH = upars(i,2);%pH
Feed=upars(i,3); %Feed
NH3in=upars(i,4); %Z1in
Metin=upars(i,5); %Z2in
u =[T;pH;Feed;NH3in;Metin];
end%-----------------------------------------------------------------------


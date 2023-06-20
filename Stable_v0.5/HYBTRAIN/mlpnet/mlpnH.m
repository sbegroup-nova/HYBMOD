function [y,dydx,dydw]=mlpnH(x,w,ann)
count=1;
ann.layer(1).w=reshape(w(count:count-1+ann.nh(1)*ann.nx),ann.nh(1),ann.nx);
count=count+ann.nh(1)*ann.nx;
ann.layer(1).b=reshape(w(count:count-1+ann.nh(1)),ann.nh(1),1);
count=count+ann.nh(1);
ann.layer(1).h=tanh(ann.layer(1).w*x+ann.layer(1).b);
for i=2:length(nh)  
    ann.layer(i).w=reshape(w(count:count-1+ann.nh(i)*ann.nh(i-1)),ann.nh(i),ann.nh(i-1));
    count=count+ann.nh(i)*ann.nh(i-1);
    ann.layer(i).b=reshape(w(count:count-1+ann.nh(i)),ann.nh(i),1);
    count=count+ann.nh(i);
    ann.layer(i).h=tanh(ann.layer(i).w*ann.layer(i-1).h+ann.layer(i).b);
end
wy=reshape(w(count:count-1+ann.ny*ann.nh(end)),ann.ny,ann.nh(end))
count=count+ann.ny*ann.nh(end);
by=reshape(w(count:count-1+ann.ny),ann.ny,1);
count=count+ny;
y = wy*ann.layer(end).h + by;


if nargout>1   %backpropagation
% L1                                                 L2                                                   Y
%[ kron(x,A1),  A1=-A2*wl.*repmat(hl.*hl-1),ny,1), kron(h1,A2), A2=-A3*wy.*repmat((h2.*h2-1),ny,1),kron(h2',A3), A3=eye(ny)]  
    
    A=eye(ann.ny);
    for i=length(nh)+1:-1:2
        dydw(:,layer(i).ib)=A;
        dydw(:,layer(i).iw)=kron(ann.layer(i-1).h',A);
        A=-(A*ann.layer(i).w).*repmat(ann.layer(i-1).h.*ann.layer(i-1).h-1,ann.ny,1)
    end
    dydw(:,layer(1).ib)=A;
    dydw(:,layer(1).iw)=kron(x',A);

end

end
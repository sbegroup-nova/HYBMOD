function [y,dydx,dydw]=mlp2H(x,w,ann)

% count = 1;
% w1=reshape(w(count:count-1+ann.nh(1)*ann.nx),ann.nh(1),ann.nx);
% count = count + ann.nh(1)*ann.nx;
% b1=w(count:count-1+ann.nh(1));
% count = count + ann.nh(1);
% w2=reshape(w(count:count-1+ann.nh(2)*ann.nh(1)),ann.nh(2),ann.nh(1));
% count = count + ann.nh(2)*ann.nh(1);
% b2=w(count:count-1+ann.nh(2));
% count = count + ann.nh(2);
% w3=reshape(w(count:count-1+ann.ny*ann.nh(2)),ann.ny,ann.nh(2));
% count = count + ann.ny*ann.nh(2);
% b3=w(count:count-1+ann.ny);

%forward propagation
% h1 = tanh(ann.w1*x+ann.b1);
% h2 = tanh(ann.w2*h1+ann.b2);
% y = ann.w3*h2+ann.b3;


[h1,layer] = feval(ann.layerff, x, ann.layer(1));
ann.layer(1)=layer;
[h2,layer] = feval(ann.layerff, h1, ann.layer(2));
ann.layer(2)=layer;
y = ann.layer(3).w*h2+ann.layer(3).b;



%h1 = feval(ann.layerff, ann.w1*x+ann.b1);
%h2 = feval(ann.layerff, ann.w2*h1+ann.b2);
%y = ann.w3*h2+ann.b3;


% if nargout>1   %backpropagation
%     A3=   eye(ann.ny);
%     A2 = -(A3*ann.w3).*repmat((h2.*h2-1)',ann.ny,1);    %ny*nh
%     A1 = -(A2*ann.w2).*repmat((h1.*h1-1)',ann.ny,1);
%     dydw = [kron([x',1],A1), kron([h1',1],A2),kron([h2',1],A3)];
%     dydx = A1*ann.w1;
% end

if nargout>1   %backpropagation
    A3 = eye(ann.ny);    %ny*nh
    h2l = feval(ann.layerbp,h1,h2,ann.layer(2));
    A2 = -(A3*ann.layer(3).w).*repmat(h2l',ann.ny,1);
    h1l = feval(ann.layerbp,x,h1,ann.layer(1));
    A1 = -(A2*ann.layer(2).w).*repmat(h1l',ann.ny,1);
    dydw = [kron([x',1],A1), kron([h1',1],A2), kron([h2',1],A3)];
    dydx = A1*ann.layer(1).w;
end

end
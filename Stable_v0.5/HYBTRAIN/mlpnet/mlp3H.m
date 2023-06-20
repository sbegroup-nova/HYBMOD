function [y,dydx,dydw]=mlp3H(x,w,ann)

% count = 1;
% w1=reshape(w(count:count-1+ann.nh(1)*ann.nx),ann.nh(1),ann.nx);
% count = count + ann.nh(1)*ann.nx;
% b1=w(count:count-1+ann.nh(1));
% count = count + ann.nh(1);
% w2=reshape(w(count:count-1+ann.nh(2)*ann.nh(1)),ann.nh(2),ann.nh(1));
% count = count + ann.nh(2)*ann.nh(1);
% b2=w(count:count-1+ann.nh(2));
% count = count + ann.nh(2);
% w3=reshape(w(count:count-1+ann.nh(3)*ann.nh(2)),ann.nh(3),ann.nh(2));
% count = count + ann.nh(3)*ann.nh(2);
% b3=w(count:count-1+ann.nh(3));
% count = count + ann.nh(3);
% w4=reshape(w(count:count-1+ann.ny*ann.nh(3)),ann.ny,ann.nh(3));
% count = count + ann.ny*ann.nh(3);
% b4=w(count:count-1+ann.ny);

% forward propagation tanh

% h1 = tanh(ann.w1*x+ann.b1);
% h2 = tanh(ann.w2*h1+ann.b2);
% h3 = tanh(ann.w3*h2+ann.b3);
% y = ann.w4*h3+ann.b4;

% h1 = feval(ann.layerff, ann.w1*x+ann.b1);
% h2 = feval(ann.layerff, ann.w2*h1+ann.b2);
% h3 = feval(ann.layerff, ann.w3*h2+ann.b3);
% y = ann.w4*h3+ann.b4;

[h1,layer] = feval(ann.layerff, x, ann.layer(1));
ann.layer(1)=layer;
[h2,layer] = feval(ann.layerff, h1, ann.layer(2));
ann.layer(2)=layer;
[h3,layer] = feval(ann.layerff, h2, ann.layer(3));
ann.layer(3)=layer;
y = ann.layer(4).w*h3+ann.layer(4).b;




% if nargout>1   %backpropagation
%     A4=   eye(ann.ny);
%     A3 = -(A4*ann.w4).*repmat((h3.*h3-1)',ann.ny,1);    %ny*nh
%     A2 = -(A3*ann.w3).*repmat((h2.*h2-1)',ann.ny,1);
%     A1 = -(A2*ann.w2).*repmat((h1.*h1-1)',ann.ny,1);
%     dydw = [kron([x',1],A1), kron([h1',1],A2), kron([h2',1],A3), kron([h3',1],A4)];
%     dydx = A1*ann.w1;
% end

if nargout>1   %backpropagation
    A4 = eye(ann.ny);
    h3l = feval(ann.layerbp,h2,h3,ann.layer(3));
    A3 = -(A4*ann.layer(4).w).*repmat(h3l',ann.ny,1);    %ny*nh
    h2l = feval(ann.layerbp,h1,h2,ann.layer(2));
    A2 = -(A3*ann.layer(3).w).*repmat(h2l',ann.ny,1);
    h1l = feval(ann.layerbp,x,h1,ann.layer(1));
    A1 = -(A2*ann.layer(2).w).*repmat(h1l',ann.ny,1);
    dydw = [kron([x',1],A1), kron([h1',1],A2), kron([h2',1],A3), kron([h3',1],A4)];
    dydx = A1*ann.layer(1).w;
end
  
% %ReLU forward
% 
% h1=max(0,ann.w1*x+ann.b1);
% h2=max(0,ann.w2*h1+ann.b2);
% h3=max(0,ann.w3*h2+ann.b3);
% y =ann.w4*h3+ann.b4;
% 
% 
% 
% if nargout>1   %ReLU backpropagation
%     A4=   eye(ann.ny);  %Linear back 
%     A3 = -(A4*ann.w4).*repmat((max(h3./h3,0))',ann.ny,1);    %ReLU back A is next, Z is previous
%     A2 = -(A3*ann.w3).*repmat((max(h2./h2,0))',ann.ny,1);
%     A1 = -(A2*ann.w2).*repmat((max(h1./h1,0))',ann.ny,1);
%     dydw = [kron([x',1],A1), kron([h1',1],A2), kron([h2',1],A3), kron([h3',1],A4)];
%     dydx = A1*ann.w1;
%     
% end



end
function [y,dydx,dydw,ann]=mlp1H(x,w,ann)

% % countw1 = 1;
% % w1=reshape(w(countw1:countw1+ann.nh*ann.nx-1),ann.nh,ann.nx);
% % countb1 = countw1 + ann.nh*ann.nx;
% % b1=w(countb1:countb1+ann.nh-1);
% % countw2 = countb1 + ann.nh;
% % w2=reshape(w(countw2:countw2+ann.ny*ann.nh-1),ann.ny,ann.nh);
% % countb2 = countw2 + ann.ny*ann.nh;
% % b2=w(countb2:countb2+ann.ny-1);


% w1=reshape(w(1:ann.nh*ann.nx),ann.nh,ann.nx);
% b1=reshape(w(ann.nh*ann.nx+1:ann.nh*(ann.nx+1)),ann.nh,1);
% w2=reshape(w(ann.nh*(ann.nx+1)+1:ann.nh*(ann.nx+1)+ann.ny*ann.nh),ann.ny,ann.nh);
% b2=reshape(w(ann.nh*(ann.nx+1)+ann.ny*ann.nh+1:ann.nh*(ann.nx+1)+(ann.nh+1)*ann.ny),ann.ny,1);

%forward propagation


% h1 = tanh(ann.w1*x+ann.b1);
% y = ann.w2*h1+ann.b2;
%manual test phase


%end manual input

[h1,layer] = feval(ann.layerff, x, ann.layer(1));
ann.layer(1)=layer;

y = ann.layer(2).w*h1+ann.layer(2).b;



% if nargout>1   %backpropagation
%     A2 = eye(ann.ny);   %ny*nh
%     A1 = -(A2*ann.w2).*repmat((h1.*h1-1)',ann.ny,1);
%     dydw = [kron([x',1],A1), kron([h1',1],A2)];
%     dydx = A1*ann.w1;
% end

if nargout>1   %backpropagation
    A2 = eye(ann.ny);
    h1l = feval(ann.layerbp,x,h1,ann.layer(1));
    A1 = -(A2*ann.layer(2).w).*repmat(h1l',ann.ny,1);
    dydw = [kron([x',1],A1), kron([h1',1],A2)];
    dydx = A1*ann.layer(1).w;
end



end
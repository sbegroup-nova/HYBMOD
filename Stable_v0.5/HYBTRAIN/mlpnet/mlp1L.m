function [y,dydx,dydw]=mlp1L(x,w,ann)

countw1 = 1;
w1=reshape(w(countw1:countw1+ann.nh*ann.nx-1),ann.nh,ann.nx);
countb1 = countw1 + ann.nh*ann.nx;
b1=w(countb1:countb1+ann.nh-1);
countw2 = countb1 + ann.nh;
w2=reshape(w(countw2:countw2+ann.ny*ann.nh-1),ann.ny,ann.nh);
countb2 = countw2 + ann.ny*ann.nh;
b2=w(countb2:countb2+ann.ny-1);

%forward propagation
h = tanh(w1*x+b1);
y = w2*h+b2;

%backpropagation
w2z = w2.*repmat((h.*h-1)',ann.ny,1);    %ny*nh
dydw = [kron([x',1],w2z),kron([h',1],eye(ann.ny))];
dydx = w2z*w1;

end
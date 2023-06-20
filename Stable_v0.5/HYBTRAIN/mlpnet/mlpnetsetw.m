function ann=mlpnetsetw(ann,w)
% MLPNCREATEUNL creates a a feedforward network project
%
%[ann]=MLPCREATEUNL(ninp,nout,H,NH,neuron)
% INPUT ARGUMENTS
% ann               Structure holding network information
% w                 Vector with network weights
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
if ann.h==1
    ann.layer(1).w=reshape(w(1:ann.nh*ann.nx),ann.nh,ann.nx);
    ann.layer(1).b=reshape(w(ann.nh*ann.nx+1:ann.nh*(ann.nx+1)),ann.nh,1);
    ann.layer(2).w=reshape(w(ann.nh*(ann.nx+1)+1:ann.nh*(ann.nx+1)+ann.ny*ann.nh),ann.ny,ann.nh);
    ann.layer(2).b=reshape(w(ann.nh*(ann.nx+1)+ann.ny*ann.nh+1:ann.nh*(ann.nx+1)+(ann.nh+1)*ann.ny),ann.ny,1);
elseif ann.h==2
    count = 1;
    ann.layer(1).w=reshape(w(count:count-1+ann.nh(1)*ann.nx),ann.nh(1),ann.nx);
    count = count + ann.nh(1)*ann.nx;
    ann.layer(1).b=w(count:count-1+ann.nh(1));
    count = count + ann.nh(1);
    ann.layer(2).w=reshape(w(count:count-1+ann.nh(2)*ann.nh(1)),ann.nh(2),ann.nh(1));
    count = count + ann.nh(2)*ann.nh(1);
    ann.layer(2).b=w(count:count-1+ann.nh(2));
    count = count + ann.nh(2);
    ann.layer(3).w=reshape(w(count:count-1+ann.ny*ann.nh(2)),ann.ny,ann.nh(2));
    count = count + ann.ny*ann.nh(2);
    ann.layer(3).b=w(count:count-1+ann.ny);
elseif ann.h==3
    count = 1;
    ann.layer(1).w=reshape(w(count:count-1+ann.nh(1)*ann.nx),ann.nh(1),ann.nx);
    count = count + ann.nh(1)*ann.nx;
    ann.layer(1).b=w(count:count-1+ann.nh(1));
    count = count + ann.nh(1);
    ann.layer(2).w=reshape(w(count:count-1+ann.nh(2)*ann.nh(1)),ann.nh(2),ann.nh(1));
    count = count + ann.nh(2)*ann.nh(1);
    ann.layer(2).b=w(count:count-1+ann.nh(2));
    count = count + ann.nh(2);
    ann.layer(3).w=reshape(w(count:count-1+ann.nh(3)*ann.nh(2)),ann.nh(3),ann.nh(2));
    count = count + ann.nh(3)*ann.nh(2);
    ann.layer(3).b=w(count:count-1+ann.nh(3));
    count = count + ann.nh(3);
    ann.layer(4).w=reshape(w(count:count-1+ann.ny*ann.nh(3)),ann.ny,ann.nh(3));
    count = count + ann.ny*ann.nh(3);
    ann.layer(4).b=w(count:count-1+ann.ny);
elseif ann.h==4
    count = 1;
    ann.layer(1).w=reshape(w(count:count-1+ann.nh(1)*ann.nx),ann.nh(1),ann.nx);
    count = count + ann.nh(1)*ann.nx;
    ann.layer(1).b=w(count:count-1+ann.nh(1));
    count = count + ann.nh(1);
    ann.layer(2).w=reshape(w(count:count-1+ann.nh(2)*ann.nh(1)),ann.nh(2),ann.nh(1));
    count = count + ann.nh(2)*ann.nh(1);
    ann.layer(2).b=w(count:count-1+ann.nh(2));
    count = count + ann.nh(2);
    ann.layer(3).w=reshape(w(count:count-1+ann.nh(3)*ann.nh(2)),ann.nh(3),ann.nh(2));
    count = count + ann.nh(3)*ann.nh(2);
    ann.layer(3).b=w(count:count-1+ann.nh(3));
    count = count + ann.nh(3);
    ann.layer(4).w=reshape(w(count:count-1+ann.nh(4)*ann.nh(3)),ann.nh(4),ann.nh(3));
    count = count + ann.nh(4)*ann.nh(3);
    ann.layer(4).b=w(count:count-1+ann.nh(4));
    count = count + ann.nh(4);
    ann.layer(5).w=reshape(w(count:count-1+ann.ny*ann.nh(4)),ann.ny,ann.nh(4));
    count = count + ann.ny*ann.nh(4);
    ann.layer(5).b=w(count:count-1+ann.ny);
elseif ann.h==5
    count = 1;
    ann.layer(1).w=reshape(w(count:count-1+ann.nh(1)*ann.nx),ann.nh(1),ann.nx);
    count = count + ann.nh(1)*ann.nx;
    ann.layer(1).b=w(count:count-1+ann.nh(1));
    count = count + ann.nh(1);
    ann.layer(2).w=reshape(w(count:count-1+ann.nh(2)*ann.nh(1)),ann.nh(2),ann.nh(1));
    count = count + ann.nh(2)*ann.nh(1);
    ann.layer(2).b=w(count:count-1+ann.nh(2));
    count = count + ann.nh(2);
    ann.layer(3).w=reshape(w(count:count-1+ann.nh(3)*ann.nh(2)),ann.nh(3),ann.nh(2));
    count = count + ann.nh(3)*ann.nh(2);
    ann.layer(3).b=w(count:count-1+ann.nh(3));
    count = count + ann.nh(3);
    ann.layer(4).w=reshape(w(count:count-1+ann.nh(4)*ann.nh(3)),ann.nh(4),ann.nh(3));
    count = count + ann.nh(4)*ann.nh(3);
    ann.layer(4).b=w(count:count-1+ann.nh(4));
    count = count + ann.nh(4);
    ann.layer(5).w=reshape(w(count:count-1+ann.nh(5)*ann.nh(4)),ann.nh(5),ann.nh(4));
    count = count + ann.nh(5)*ann.nh(4);
    ann.layer(5).b=w(count:count-1+ann.nh(5));
    count = count + ann.nh(5);
    ann.layer(6).w=reshape(w(count:count-1+ann.ny*ann.nh(5)),ann.ny,ann.nh(5));
    count = count + ann.ny*ann.nh(5);
    ann.layer(6).b=w(count:count-1+ann.ny);  
end
end%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


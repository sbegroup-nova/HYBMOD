function [w,ann]=mlpnetinitw(ann)
% MLPNETINITW initializes network weights
%
%[w,ann]=MLPNETINITW(ann)
% INPUT ARGUMENTS
% ann               Structure holding network information
%     
% OUTPUT ARGUMENTS
% w                 Vector with initialized network weights
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
    ann.layer(1).w=randn(ann.nh,ann.nx)*(2/(ann.nx+ann.nh));
    ann.layer(1).b=zeros(ann.nh,1);
    ann.layer(2).w=randn(ann.ny,ann.nh)*(2/(ann.nh+ann.ny));
    ann.layer(2).b=zeros(ann.ny,1);    
    w(1:ann.nh*ann.nx)=reshape(ann.layer(1).w,ann.nh*ann.nx,1);
    w(ann.nh*ann.nx+1:ann.nh*(ann.nx+1))=reshape(ann.layer(1).b,ann.nh,1);
    w(ann.nh*(ann.nx+1)+1:ann.nh*(ann.nx+1)+ann.ny*ann.nh)=reshape(ann.layer(2).w,ann.ny*ann.nh,1);
    w(ann.nh*(ann.nx+1)+ann.ny*ann.nh+1:ann.nh*(ann.nx+1)+(ann.nh+1)*ann.ny)=reshape(ann.layer(2).b,ann.ny,1);
elseif ann.h==2
    ann.layer(1).w=randn(ann.nh(1),ann.nx)*sqrt(2/(ann.nx+ann.nh(1)));
    ann.layer(1).b=zeros(ann.nh(1),1);
    ann.layer(2).w=randn(ann.nh(2),ann.nh(1))*sqrt(2/(ann.nh(1)+ann.nh(2)));
    ann.layer(2).b=zeros(ann.nh(2),1);    
    ann.layer(3).w=randn(ann.ny,ann.nh(2))*sqrt(2/(ann.nh(2)+ann.ny));
    ann.layer(3).b=zeros(ann.ny,1);    
    count = 1;
    w(count:count-1+ann.nh(1)*ann.nx)=reshape(ann.layer(1).w,ann.nh(1)*ann.nx,1);
    count = count + ann.nh(1)*ann.nx;
    w(count:count-1+ann.nh(1))=ann.layer(1).b;
    count = count + ann.nh(1);
    w(count:count-1+ann.nh(2)*ann.nh(1))=reshape(ann.layer(2).w,ann.nh(2)*ann.nh(1),1);
    count = count + ann.nh(2)*ann.nh(1);
    w(count:count-1+ann.nh(2))=ann.layer(2).b;
    count = count + ann.nh(2);
    w(count:count-1+ann.ny*ann.nh(2))=reshape(ann.layer(3).w,ann.ny*ann.nh(2),1);
    count = count + ann.ny*ann.nh(2);
    w(count:count-1+ann.ny)=ann.layer(3).b;
elseif ann.h==3
    ann.layer(1).w=randn(ann.nh(1),ann.nx)*sqrt(2/(ann.nx+ann.nh(1)));
    ann.layer(1).b=zeros(ann.nh(1),1);
    ann.layer(2).w=randn(ann.nh(2),ann.nh(1))*sqrt(2/(ann.nh(1)+ann.nh(2)));
    ann.layer(2).b=zeros(ann.nh(2),1);    
    ann.layer(3).w=randn(ann.nh(3),ann.nh(2))*sqrt(2/(ann.nh(2)+ann.nh(3)));
    ann.layer(3).b=zeros(ann.nh(3),1);        
    ann.layer(4).w=randn(ann.ny,ann.nh(3))*sqrt(2/(ann.nh(3)+ann.ny));
    ann.layer(4).b=zeros(ann.ny,1);    
    count = 1;
    w(count:count-1+ann.nh(1)*ann.nx)=reshape(ann.layer(1).w,ann.nh(1)*ann.nx,1);
    count = count + ann.nh(1)*ann.nx;
    w(count:count-1+ann.nh(1))=ann.layer(1).b;
    count = count + ann.nh(1);
    w(count:count-1+ann.nh(2)*ann.nh(1))=reshape(ann.layer(2).w,ann.nh(2)*ann.nh(1),1);
    count = count + ann.nh(2)*ann.nh(1);
    w(count:count-1+ann.nh(2))=ann.layer(2).b;
    count = count + ann.nh(2);
    w(count:count-1+ann.nh(3)*ann.nh(2))=reshape(ann.layer(3).w,ann.nh(3)*ann.nh(2),1);
    count = count + ann.nh(3)*ann.nh(2);
    w(count:count-1+ann.nh(3))=ann.layer(3).b;
    count = count + ann.nh(3);
    w(count:count-1+ann.ny*ann.nh(3))=reshape(ann.layer(4).w,ann.ny*ann.nh(3),1);
    count = count + ann.ny*ann.nh(3);
    w(count:count-1+ann.ny)=ann.layer(4).b;
elseif ann.h==4
    ann.layer(1).w=randn(ann.nh(1),ann.nx)*sqrt(2/(ann.nx+ann.nh(1)));
    ann.layer(1).b=zeros(ann.nh(1),1);
    ann.layer(2).w=randn(ann.nh(2),ann.nh(1))*sqrt(2/(ann.nh(1)+ann.nh(2)));
    ann.layer(2).b=zeros(ann.nh(2),1);    
    ann.layer(3).w=randn(ann.nh(3),ann.nh(2))*sqrt(2/(ann.nh(2)+ann.nh(3)));
    ann.layer(3).b=zeros(ann.nh(3),1);        
    ann.layer(4).w=randn(ann.nh(4),ann.nh(3))*sqrt(2/(ann.nh(3)+ann.nh(4)));
    ann.layer(4).b=zeros(ann.nh(4),1);        
    ann.layer(5).w=randn(ann.ny,ann.nh(4))*sqrt(2/(ann.nh(4)+ann.ny));
    ann.layer(5).b=zeros(ann.ny,1);        
    count = 1;
    w(count:count-1+ann.nh(1)*ann.nx)=reshape(ann.layer(1).w,ann.nh(1)*ann.nx,1);
    count = count + ann.nh(1)*ann.nx;
    w(count:count-1+ann.nh(1))=ann.layer(1).b;
    count = count + ann.nh(1);
    w(count:count-1+ann.nh(2)*ann.nh(1))=reshape(ann.layer(2).w,ann.nh(2)*ann.nh(1),1);
    count = count + ann.nh(2)*ann.nh(1);
    w(count:count-1+ann.nh(2))=ann.layer(2).b;
    count = count + ann.nh(2);
    w(count:count-1+ann.nh(3)*ann.nh(2))=reshape(ann.layer(3).w,ann.nh(3)*ann.nh(2),1);
    count = count + ann.nh(3)*ann.nh(2);
    w(count:count-1+ann.nh(3))=ann.layer(3).b;
    count = count + ann.nh(3);
    w(count:count-1+ann.nh(4)*ann.nh(3))=reshape(ann.layer(4).w,ann.nh(4)*ann.nh(3),1);
    count = count + ann.nh(4)*ann.nh(3);
    w(count:count-1+ann.nh(4))=ann.layer(4).b;
    count = count + ann.nh(4);
    w(count:count-1+ann.ny*ann.nh(4))=reshape(ann.layer(5).w,ann.ny*ann.nh(4),1);
    count = count + ann.ny*ann.nh(4);
    w(count:count-1+ann.ny)=ann.layer(5).b;
elseif ann.h==5
    ann.layer(1).w=randn(ann.nh(1),ann.nx)*sqrt(2/(ann.nx+ann.nh(1)));
    ann.layer(1).b=zeros(ann.nh(1),1);
    ann.layer(2).w=randn(ann.nh(2),ann.nh(1))*sqrt(2/(ann.nh(1)+ann.nh(2)));
    ann.layer(2).b=zeros(ann.nh(2),1);    
    ann.layer(3).w=randn(ann.nh(3),ann.nh(2))*sqrt(2/(ann.nh(2)+ann.nh(3)));
    ann.layer(3).b=zeros(ann.nh(3),1);        
    ann.layer(4).w=randn(ann.nh(4),ann.nh(3))*sqrt(2/(ann.nh(3)+ann.nh(4)));
    ann.layer(4).b=zeros(ann.nh(4),1);        
    ann.layer(5).w=randn(ann.nh(5),ann.nh(4))*sqrt(2/(ann.nh(4)+ann.nh(5)));
    ann.layer(5).b=zeros(ann.nh(5),1);        
    ann.layer(6).w=randn(ann.ny,ann.nh(5))*sqrt(2/(ann.nh(5)+ann.ny));
    ann.layer(6).b=zeros(ann.ny,1);            
    count = 1;
    w(count:count-1+ann.nh(1)*ann.nx)=reshape(ann.layer(1).w,ann.nh(1)*ann.nx,1);
    count = count + ann.nh(1)*ann.nx;
    w(count:count-1+ann.nh(1))=ann.layer(1).b;
    count = count + ann.nh(1);
    w(count:count-1+ann.nh(2)*ann.nh(1))=reshape(ann.layer(2).w,ann.nh(2)*ann.nh(1),1);
    count = count + ann.nh(2)*ann.nh(1);
    w(count:count-1+ann.nh(2))=ann.layer(2).b;
    count = count + ann.nh(2);
    w(count:count-1+ann.nh(3)*ann.nh(2))=reshape(ann.layer(3).w,ann.nh(3)*ann.nh(2),1);
    count = count + ann.nh(3)*ann.nh(2);
    w(count:count-1+ann.nh(3))=ann.layer(3).b;
    count = count + ann.nh(3);
    w(count:count-1+ann.nh(4)*ann.nh(3))=reshape(ann.layer(4).w,ann.nh(4)*ann.nh(3),1);
    count = count + ann.nh(4)*ann.nh(3);
    w(count:count-1+ann.nh(4))=ann.layer(4).b;
    count = count + ann.nh(4);
    w(count:count-1+ann.nh(5)*ann.nh(4))=reshape(ann.layer(5).w,ann.nh(5)*ann.nh(4),1);
    count = count + ann.nh(5)*ann.nh(4);
    w(count:count-1+ann.nh(5))=ann.layer(5).b;
    count = count + ann.nh(5);
    w(count:count-1+ann.ny*ann.nh(5))=reshape(ann.layer(6).w,ann.ny*ann.nh(5),1);
    count = count + ann.ny*ann.nh(5);
    w(count:count-1+ann.ny)=ann.layer(6).b;  
end
w=reshape(w,numel(w),1);
ann.w=w;
end%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


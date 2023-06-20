function [iw]=mlpnetstockdropout(ann,pvisible,phidden)
% MLPNETINITW initializes network weights
%
%[w,ann]=MLPNETINITiw(ann)
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
iw= false(ann.nw,1);
w=  true(ann.nh(1),ann.nx);
b=  true(ann.nh(1),1);
ix= rand(ann.nx,1)<pvisible;
ih= rand(ann.nh(1),1)<phidden; 
w(ih,:)=false;
w(:,ix)=false;
b(ih,1)=false;
count = 1;
iw(count:count-1+ann.nh(1)*ann.nx,1)=reshape(w,ann.nh(1)*ann.nx,1);
count = count + ann.nh(1)*ann.nx;
iw(count:count-1+ann.nh(1),1)=b;
count = count + ann.nh(1);
for i=2:ann.h
    w=true(ann.nh(i),ann.nh(i-1));
    b=true(ann.nh(i),1);
    ihm1=ih;
    ih=rand(ann.nh(i),1)<phidden;
    %ihim1=rand(ann.nh(i-1),1)<phidden;
    w(ih,:)=false;
    w(:,ihm1)=false;
    b(ih,1)=false;
    iw(count:count-1+ann.nh(i)*ann.nh(i-1),1)=reshape(w,ann.nh(i)*ann.nh(i-1),1);
    count = count + ann.nh(i)*ann.nh(i-1);
    iw(count:count-1+ann.nh(i),1)=b;
    count = count + ann.nh(i);
end
w=true(ann.ny,ann.nh(ann.h));
b=true(ann.ny,1);
w(:,ih)=false;
iw(count:count-1+ann.ny*ann.nh(ann.h),1)=reshape(w,ann.ny*ann.nh(ann.h),1);
count = count + ann.ny*ann.nh(ann.h);
iw(count:count-1+ann.ny,1)=b;
end%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


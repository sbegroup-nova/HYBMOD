function projhyb=pichiamain_5PC_vf%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%the projhyb variable corresponds to the structure Adicionar
%feeding/miu/vp/miu*vp/miu*vp*P (testar estes e outros para memória celular)
%cumulativo
projhyb=hybdata('pichia_5PC_vf.hmod','pichia'); %Read the hibmod file to generate the structure
%-------
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% START HYBRID MODELINGs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
% 1) CREATE HYBRID MODEL
%
projhyb=createhybmod(projhyb);


% 2) READ EXPERIMENTAL DATA
projhyb=hybreaddata(projhyb);
projhyb.batch(1).istrain=3;
projhyb.batch(2).istrain=1;
projhyb.batch(3).istrain=1;
projhyb.batch(4).istrain=1;
projhyb.batch(5).istrain=1;
projhyb.batch(6).istrain=3;
projhyb.batch(7).istrain=1;
projhyb.batch(8).istrain=1;
projhyb.batch(9).istrain=1;
projhyb.nbatch=9;

% 3) PERFORM TRAINING
rng('shuffle'); %??????????????????????????????????????
%rng default
projhyb=hybtrain(projhyb);

% 4) SIMULKATION OF FINAL MODEL
projhyb=hybsimul(projhyb);
end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
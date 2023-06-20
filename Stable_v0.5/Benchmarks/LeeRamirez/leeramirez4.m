function leeramirez4%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%the projhyb variable corresponds to the structure Adicionar
%feeding/miu/vp/miu*vp/miu*vp*P (testar estes e outros para memória celular)
%cumulativo
projhyb=hybdata('leeramirez2.hmod','leeram'); %Read the hibmod file to generate the structure
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
projhyb.batch(1).istrain=1;
projhyb.batch(2).istrain=1;
projhyb.batch(3).istrain=1;
projhyb.batch(4).istrain=1;
projhyb.batch(5).istrain=1;
projhyb.batch(6).istrain=1;
projhyb.batch(7).istrain=1;
projhyb.batch(8).istrain=1;
projhyb.batch(9).istrain=1;
projhyb.batch(10).istrain=1;
projhyb.batch(11).istrain=1;
projhyb.batch(12).istrain=1;
projhyb.batch(13).istrain=1;
projhyb.batch(14).istrain=1;
projhyb.batch(15).istrain=1;
projhyb.batch(16).istrain=1;
projhyb.batch(17).istrain=1;
projhyb.batch(18).istrain=1;
projhyb.batch(19).istrain=1;
projhyb.batch(20).istrain=1;
projhyb.batch(21).istrain=1;
projhyb.batch(22).istrain=1;
projhyb.batch(23).istrain=1;
projhyb.batch(24).istrain=1;
projhyb.batch(25).istrain=1;
projhyb.batch(26).istrain=3;
projhyb.batch(27).istrain=3;
projhyb.nbatch=27;

%%%%FOR THE PARTIAL TESTS ONLY%%%%%
%%%%FOR THE PARTIAL TESTS ONLY%%%%%
    batchtemp(1)=projhyb.batch(1);
    batchtemp(2)=projhyb.batch(2);
    batchtemp(3)=projhyb.batch(3);
    batchtemp(4)=projhyb.batch(4);
    batchtemp(5)=projhyb.batch(5);
    batchtemp(6)=projhyb.batch(6);
    batchtemp(7)=projhyb.batch(7);
    batchtemp(8)=projhyb.batch(8);
    batchtemp(9)=projhyb.batch(9);
    batchtemp(10)=projhyb.batch(10);
    batchtemp(11)=projhyb.batch(11);
    batchtemp(12)=projhyb.batch(12);
    batchtemp(13)=projhyb.batch(13);
    batchtemp(14)=projhyb.batch(14);
    batchtemp(15)=projhyb.batch(15);
    batchtemp(16)=projhyb.batch(16);
    batchtemp(17)=projhyb.batch(17);
    batchtemp(18)=projhyb.batch(18);
    batchtemp(19)=projhyb.batch(19);
    batchtemp(20)=projhyb.batch(20);
    batchtemp(21)=projhyb.batch(21);
    batchtemp(22)=projhyb.batch(22);
    batchtemp(23)=projhyb.batch(23);
    batchtemp(24)=projhyb.batch(24);
    batchtemp(25)=projhyb.batch(25);
    batchtemp(26)=projhyb.batch(26);
    batchtemp(27)=projhyb.batch(27);
    projhyb.nbatch=27;
    
     projhyb.batch(1)=batchtemp(25); %central
     projhyb.batch(2)=batchtemp(17); %extremes
     projhyb.batch(3)=batchtemp(18); %extremes
     projhyb.batch(4)=batchtemp(19); %extremes
     projhyb.batch(5)=batchtemp(20); %extremes
     projhyb.batch(6)=batchtemp(21); %extremes
     projhyb.batch(7)=batchtemp(22); %extremes
     projhyb.batch(8)=batchtemp(23); %extremes
     projhyb.batch(9)=batchtemp(24); %extremes
     projhyb.batch(10)=batchtemp(1); %cube
     projhyb.batch(11)=batchtemp(2); %cube
     projhyb.batch(12)=batchtemp(3); %cube
     projhyb.batch(13)=batchtemp(4); %cube
     projhyb.batch(14)=batchtemp(5); %cube
     projhyb.batch(15)=batchtemp(6); %cube
     projhyb.batch(16)=batchtemp(7); %cube
     projhyb.batch(17)=batchtemp(8); %cube
     projhyb.batch(18)=batchtemp(9); %cube
     projhyb.batch(19)=batchtemp(10); %cube
     projhyb.batch(20)=batchtemp(11); %cube
     projhyb.batch(21)=batchtemp(12); %cube
     projhyb.batch(22)=batchtemp(13); %cube
     projhyb.batch(23)=batchtemp(14); %cube
     projhyb.batch(24)=batchtemp(15); %cube
     projhyb.batch(25)=batchtemp(16); %cube
     projhyb.batch(projhyb.nbatch-1)=batchtemp(26); %optimal test
     projhyb.batch(projhyb.nbatch)=batchtemp(27); %optimal test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% 3) PERFORM TRAINING
rng('shuffle'); %??????????????????????????????????????
%rng default
projhyb=hybtrain(projhyb);

% 4) SIMULKATION OF FINAL MODEL
projhyb=hybsimul(projhyb);

projhyb.batch(projhyb.nbatch-1).cmod(end,3)*3.9315
projhyb.batch(projhyb.nbatch-1).cmodup(end,3)*3.9315
end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
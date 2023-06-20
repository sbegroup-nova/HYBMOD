%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function projhyb=hybsimul(projhyb)
% HYBTRAIN trains a hybrid model
%
%[projhyb] = HYBSIMUL(projhyb)
%
% INPUT ARGUMENTS
% projhyb           Data strtucture holding information of the hybrid model, 
%                   data and traning method
%
% OUTPUT ARGUMENTS
% projhyb           Updated data strtucture holding information of the 
%                   simulated hybrid model
%
% Copyright, 2020 -
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
% $ Version 10.00 $ Date November 2020 $ Not compiled $
cmedtr=[];
cmodtr=[];
rmedtr=[];
rmodtr=[];
cmedte=[];
cmodte=[];
rmedte=[];
rmodte=[];

for i=1:projhyb.nbatch

    [~,shyb,shyblow,shybup,rhyb,rhyblow,rhybup,rann,rannlow,rannup,...
         restr_c, wssetr_c, resvl_c, wssevl_c,restr_r,wssetr_r,resvl_r,...
         wssevl_r]=hybbatchsimul(projhyb,projhyb.batch(i));
        count=1;
        projhyb.batch(i).cmod=shyb(:,1:projhyb.nspecies);
        if isempty(shybup)
            projhyb.batch(i).cmodup=[];
        else
            projhyb.batch(i).cmodup=shybup(:,1:projhyb.nspecies);
        end
        if isempty(shyblow)
            projhyb.batch(i).cmodlow=[];
        else
            projhyb.batch(i).cmodlow=shyblow(:,1:projhyb.nspecies);
        end
        count = count+projhyb.nspecies;
%         if projhyb.ncompartments==0
%             projhyb.batch(i).volmod=[];
%         else
%             projhyb.batch(i).volmod=shyb(:,count:count+projhyb.ncompartments-1);
%         end
%         count = count+projhyb.ncompartments;
        projhyb.batch(i).raterulemod=shyb(:,count:count+projhyb.nraterules-1,1);
%        projhyb.batch(i).raterulemodup=shybup(:,count:count+projhyb.nraterules-1);
%        projhyb.batch(i).raterulemodlow=shyblow(:,count:count+projhyb.nraterules-1);
        
        projhyb.batch(i).rmod=rhyb;
        projhyb.batch(i).rmodup=rhybup;
        projhyb.batch(i).rmodlow=rhyblow;

        projhyb.batch(i).rmodann=rann;
        projhyb.batch(i).rmodannup=rannup;
        projhyb.batch(i).rmodannlow=rannlow;

        projhyb.batch(i).restr_c=restr_c;
        projhyb.batch(i).wssetr_c=wssetr_c;
        projhyb.batch(i).resvl_c=resvl_c;
        projhyb.batch(i).wssevl_c=wssevl_c;
        projhyb.batch(i).restr_r=restr_r;
        projhyb.batch(i).wssetr_r=wssetr_r;
        projhyb.batch(i).resvl_r=resvl_r;
        projhyb.batch(i).wssevl_r=wssevl_r;
        
        if projhyb.batch(i).istrain==1
            cmedtr=[cmedtr;projhyb.batch(i).cnoise];
            cmodtr=[cmodtr;projhyb.batch(i).cmod];
            rmedtr=[rmedtr;projhyb.batch(i).rnoise];
            rmodtr=[rmodtr;rhyb];
        elseif projhyb.batch(i).istrain==3
            cmedte=[cmedte;projhyb.batch(i).cnoise];
            cmodte=[cmodte;projhyb.batch(i).cmod];
            rmedte=[rmedte;projhyb.batch(i).rnoise];
            rmodte=[rmodte;rhyb];
        end
    
        % Final batch simulation
        hybplotbatch(projhyb.batch(i),projhyb);

end
nplots=2;
nlins=round(sqrt(nplots));
ncols=nlins;
if (nlins*ncols<nplots)
    ncols=ncols+1;
end
figure
for i=1
    subplot(nlins,ncols,i)
    plot(cmedtr(:,i),cmodtr(:,i),'o','MarkerSize',12,...
        'MarkerEdgeColor','b','MarkerFaceColor',[0.8 0.93 1],...
        'LineWidth',2);
    hold on
    if ~isempty(cmedte)
        plot(cmedte(:,i),cmodte(:,i),'s','MarkerSize',12,...
            'MarkerEdgeColor','r','MarkerFaceColor',[0.03 0.96 0.80],...
            'LineWidth',2)
    end
    set(gca,'linewidth',2)
    xlim('manual');
    ylim('manual');
    set(gca,'XLim',[projhyb.species(i).min projhyb.species(i).max],'XTick',...
         linspace(projhyb.species(i).min,projhyb.species(i).max,5));    
    set(gca,'YLim',[projhyb.species(i).min projhyb.species(i).max],'YTick',...
         linspace(projhyb.species(i).min,projhyb.species(i).max,5));    
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
    a = get(gca,'YTickLabel');
    set(gca,'YTickLabel',a,'FontName','Times','fontsize',18)
    ylabel('model','FontName','Times','fontsize',20)
    xlabel('measurement','FontName','Times','fontsize',20)
    title(char(projhyb.species(i).id),'FontName','Times','fontsize',24)
    hold off
end

nplots=2;
nlins=round(sqrt(nplots));
ncols=nlins;
if (nlins*ncols<nplots)
    ncols=ncols+1;
end
figure
for i=1:1
    subplot(nlins,ncols,i)
    plot(rmedtr(:,i),rmodtr(:,i),'ko','MarkerSize',12,...
      'MarkerEdgeColor','b','MarkerFaceColor',[1 0.8 1],'LineWidth',2)
    hold on
    if ~isempty(rmedte)
        plot(rmedte(:,i),rmodte(:,i),'s','MarkerSize',12,...
       'MarkerEdgeColor','r','MarkerFaceColor',[0.03 0.96 0.80],'LineWidth',2);
    end
    set(gca,'linewidth',2)
    xlim('manual');
    ylim('manual');
    set(gca,'XLim',[projhyb.rmin(i) projhyb.rmax(i)],'XTick',...
         linspace(projhyb.rmin(i),projhyb.rmax(i),5));    
    set(gca,'YLim',[projhyb.rmin(i) projhyb.rmax(i)],'YTick',...
         linspace(projhyb.rmin(i),projhyb.rmax(i),5));    
    a = get(gca,'XTickLabel');
    set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
    a = get(gca,'YTickLabel');
    set(gca,'YTickLabel',a,'FontName','Times','fontsize',18)
    ylabel('model','FontName','Times','fontsize',20)
    xlabel('measurement','FontName','Times','fontsize',20)
    title(sprintf('r%s',projhyb.species(i).id),'FontName',...
        'Times','fontsize',24)
    hold off
end

end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function hybplotbatch(batch,projhyb)
% HYBPLOTBATCH plot batch data with  hybrid model simulation
%
% HYBPLOTBATCH(batch,projhyb)
%
% INPUT ARGUMENTS
% batch             Data structure holding the information of the batch
%                   to be plotted
% projhyb           Data strtucture holding information of the hybrid model, 
%                   data and traning method
%
% OUTPUT ARGUMENTS
% None           
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
figure('Name',sprintf('Batch %s [state variables]',batch.id)); 

nplots=projhyb.nspecies+1+projhyb.mlm.ny+projhyb.ncontrol;
nlins=floor(sqrt(nplots));
ncols=nlins;
if (nlins*ncols)<nplots
    ncols=ncols+1;
end    
count=0;
for i=1:projhyb.nspecies
    count=count+1;
    subplot(nlins,ncols,count)
   errorbar(batch.t,batch.cnoise(:,i),3*batch.sc(:,i),'o',...
         'MarkerSize',12,'MarkerEdgeColor','k',...
         'MarkerFaceColor',[0.8 0.93 1],...
         'LineWidth',2);  
    hold on
    if ~isempty(batch.c_true(:,i))
        plot(batch.t,batch.c_true(:,i),'k:','LineWidth',2);hold on
    end
    if ~isempty(batch.cmod)
        plot(batch.t,batch.cmod(:,i),'r-','LineWidth',2);hold on
    end
    if ~isempty(batch.cmodup)
        plot(batch.t,batch.cmodup(:,i),'r-','LineWidth',0.5);hold on
    end
    if ~isempty(batch.cmodlow)
        plot(batch.t,batch.cmodlow(:,i),'r-','LineWidth',0.5);hold on
    end

    set(gca,'linewidth',2)
    xlim('manual');
    ylim('manual');
    set(gca,'XLim',[projhyb.time.min projhyb.time.max],'XTick',...
         linspace(projhyb.time.min,projhyb.time.max,5));
    set(gca,'YLim',[projhyb.species(i).min projhyb.species(i).max],'YTick',...
         linspace(projhyb.species(i).min,projhyb.species(i).max,5));    
    a = get(gca,'XTickLabel'); 
    set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
    a = get(gca,'YTickLabel');
    set(gca,'YTickLabel',a,'FontName','Times','fontsize',18)
    xlabel(char(projhyb.time.id),'FontName','Times','fontsize',18);
    ylabel(char(projhyb.species(i).id),'FontName','Times','fontsize',18)
    hold off
end
%COMPARTMENTS--------------------------------------------------------------
% for i=1:projhyb.ncompartments
%     count=count+1;
%     subplot(nlins,ncols,count)
%     plot(batch.t,batch.vol,'color','b','LineWidth',2); hold on
%     if ~isempty(batch.volmod)
%         plot(batch.t,batch.volmod(:,i),'r-','LineWidth',2);hold on
%     end
%     set(gca,'linewidth',2)
%     xlim('manual');
%     ylim('manual');
%     set(gca,'XLim',[projhyb.time.min projhyb.time.max],'XTick',...
%              linspace(projhyb.time.min,projhyb.time.max,5));
%     set(gca,'YLim',[projhyb.compartment(i).min projhyb.compartment(i).max],'YTick',...
%              linspace(projhyb.compartment(i).min,projhyb.compartment(i).max,5));    
%     a = get(gca,'XTickLabel'); 
%     set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
%     a = get(gca,'YTickLabel');
%     set(gca,'YTickLabel',a,'FontName','Times','fontsize',18)
%     xlabel(char(projhyb.time.id),'FontName','Times','fontsize',18);
%     ylabel(char(projhyb.compartment(i).id),'FontName','Times','fontsize',18)
%end
% RATERULES ---------------------------------------------------------------
% Raterules should be changed in the future
% for i=1:projhyb.nraterules
%     count=count+1;
%     subplot(nlins,ncols,count)
%     errorbar(batch.t,batch.raterule(:,i),3*batch.sc(:,count),'o',...
%           'MarkerSize',12,'MarkerEdgeColor','k',...
%           'MarkerFaceColor',[0.8 0.93 1],...
%           'LineWidth',2);  
%     hold on
%     if ~isempty(batch.raterulemod)
%         plot(batch.t,batch.raterulemod(:,i),'r-','LineWidth',2);hold on
%     end
%     if ~isempty(batch.raterulemodup)
%         plot(batch.t,batch.raterulemodup(:,i),'r-','LineWidth',0.5);hold on
%     end
%     if ~isempty(batch.raterulemodlow)
%         plot(batch.t,batch.raterulemodlow(:,i),'r-','LineWidth',0.5);hold on
%     end
%     set(gca,'linewidth',2)
%     xlim('manual');
%     ylim('manual');
%     set(gca,'XLim',[projhyb.time.min projhyb.time.max],'XTick',...
%          linspace(projhyb.time.min,projhyb.time.max,5));
%     set(gca,'YLim',[projhyb.raterule(i).min projhyb.raterule(i).max],'YTick',...
%          linspace(projhyb.raterule(i).min,projhyb.raterule(i).max,5));    
%     a = get(gca,'XTickLabel'); 
%     set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
%     a = get(gca,'YTickLabel');
%     set(gca,'YTickLabel',a,'FontName','Times','fontsize',18)
%     xlabel(char(projhyb.time.id),'FontName','Times','fontsize',18);
%     ylabel(char(projhyb.raterule(i).id),'FontName','Times','fontsize',18)
%     hold off
% end
%unknown rates-----
% for i=1:projhyb.mlm.ny
%     count=count+1;
%     subplot(nlins,ncols,count)
%     if ~isempty(batch.rann_true)
%         plot(batch.t,batch.rann_true(:,i),'k:','LineWidth',2); hold on
%     end
%     if ~isempty(batch.rmodann)
%         plot(batch.t,batch.rmodann(:,i),'r-','LineWidth',2); hold on
%     end
%     if ~isempty(batch.rmodannup)
%         plot(batch.t,batch.rmodannup(:,i),'r-','LineWidth',0.5); hold on
%     end
%     if ~isempty(batch.rmodannlow)
%         plot(batch.t,batch.rmodannlow(:,i),'r-','LineWidth',0.5); hold on
%     end
% 
%     set(gca,'linewidth',2)
%     xlim('manual');
%     ylim('manual');
%     set(gca,'XLim',[projhyb.time.min projhyb.time.max],'XTick',...
%          linspace(projhyb.time.min,projhyb.time.max,5));
%     set(gca,'YLim',[projhyb.mlm.y(i).min projhyb.mlm.y(i).max],'YTick',...
%          linspace(projhyb.mlm.y(i).min,projhyb.mlm.y(i).max,5));    
%     a = get(gca,'XTickLabel'); 
%     set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
%     a = get(gca,'YTickLabel');
%     set(gca,'YTickLabel',a,'FontName','Times','fontsize',18)
%     xlabel(char(projhyb.time.id),'FontName','Times','fontsize',18);
%     ylabel(char(projhyb.mlm.y(i).id),'FontName','Times','fontsize',18)
%     hold off
% end
%CONTROL-----------------------------------------------------------------
% for i=1:projhyb.ncontrol
%     count=count+1;
%     subplot(nlins,ncols,count)
%     plot(batch.t,batch.ualongtime(:,i),'color','b','LineWidth',2);
%     set(gca,'linewidth',2)
%     xlim('manual');
%     ylim('manual');
%     set(gca,'XLim',[projhyb.time.min projhyb.time.max],'XTick',...
%              linspace(projhyb.time.min,projhyb.time.max,5));
%     set(gca,'YLim',[projhyb.control(i).min projhyb.control(i).max],'YTick',...
%              linspace(projhyb.control(i).min,projhyb.control(i).max,5));    
%     a = get(gca,'XTickLabel'); 
%     set(gca,'XTickLabel',a,'FontName','Times','fontsize',18)
%     a = get(gca,'YTickLabel');
%     set(gca,'YTickLabel',a,'FontName','Times','fontsize',18)
%     xlabel(char(projhyb.time.id),'FontName','Times','fontsize',18);
%     ylabel(char(projhyb.control(i).id),'FontName','Times','fontsize',18)
% end

end %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



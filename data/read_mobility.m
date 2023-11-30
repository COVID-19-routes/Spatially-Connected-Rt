clearvars
close all
clc

% READ MATRIX FOR ITALY
opts=detectImportOptions('pendo_2011/matrix_pendo2011_10112014.txt');
opts.SelectedVariableNames=[1 3 8 15];
t=readtable('pendo_2011/matrix_pendo2011_10112014.txt',opts);

tbr=(cell2mat(t{:,1})=='L' | t{:,3}==0);
t(tbr,:)=[];

from_prov=t{:,2};
to_prov=t{:,3};
trips=str2double(t{:,4});

OD=sparse(from_prov,to_prov,trips)';
P=bsxfun(@rdivide,OD,sum(OD,1));


% COMPUTE MATRIX FOR VENETO
italy_as_8th_node = false;
OD_V = OD(23:29,23:29);

% for plotting
prov = ["VR", "VI", "BL", "TV", "VE", "PD", "RO"];
np = 7;

if italy_as_8th_node == true
    np = np + 1;
    OD_E = OD; OD_E(23:29,23:29)=0;
    IN_V = sum(OD_E(23:29,:),2); OUT_V = sum(OD_E(:,23:29),1);
    OD_E(23:29,:) = 0; OD_E(:,23:29) = 0; NO_V = sum(OD_E,'all');
    OD_V(1:7,8) = IN_V; OD_V(8,1:7) = OUT_V; OD_V(8,8) = NO_V;
    prov(8) = "IT";
end

P_V = OD_V./sum(OD_V,1);

save('mobility.mat', 'OD_V', 'P_V')

figure()
imagesc(P_V)
for i = 1:np
    text_str = [num2str(P_V(i,i)*100,'%0.0f') '%'];
    text(i,i,text_str,'fontsize',14,'HorizontalAlignment', 'center')
end
colorbar
set(gca, 'xticklabel', prov, 'yticklabel', prov,'fontsize',14)
xlabel('TO PROVINCE')
ylabel('FROM PROVINCE')


p_vect = 1:np;
[xxx,yyy]=meshgrid(1:np,1:np);
mask=find(OD_V);


figure()
subplot(121)
scatter(xxx(mask),yyy(mask),250,log10(OD_V(mask)),'filled')
axis([0 np+1 0 np+1])
axis ij; axis square; box on
cbh=colorbar(gca,'YTick',0:1:6,'YTickLabel',10.^(0:1:6));
set(get(cbh,'Title'),'String',{'People moving';'from province l to province j'})
set(gca,'XTick',p_vect,'YTick',p_vect,'TickDir','out','XTickLabels',prov,'YTickLabels',prov)
xlabel('Province of origin'); ylabel('Province of destination')
subplot(122)
scatter(xxx(mask),yyy(mask),250,log10(P_V(mask)),'filled')
axis([0 np+1 0 np+1])
axis ij; axis square; box on
cbh=colorbar(gca,'YTick',-6:1:0,'YTickLabel',10.^(-6:1:0));
set(get(cbh,'Title'),'String',{'Movement probability';'from province l to province j'})
set(gca,'XTick',p_vect,'YTick',p_vect,'TickDir','out','XTickLabels',prov,'YTickLabels',prov)
xlabel('Province of origin'); ylabel('Province of destination')
set(findall(gcf,'-property','FontSize'),'FontSize',10)

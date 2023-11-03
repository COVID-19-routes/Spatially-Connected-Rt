function make_figure_scatter(csi,R,eta,R0,ResPop,Q,par)


tau = zeros(size(R.Q50,1),size(R.Q50,2)-(par.init));
for t = par.init+1:size(csi,2)
    C = diag(1-csi(:,t))+diag(csi(:,t))*Q;
    ActPop=C*ResPop;
    tau(:,t-par.init) = ResPop./ActPop;
end

ak = (1-eta(:,par.init+1:end))./((1-csi(:,par.init+1:end)).^2)./tau; ak = ak(:);

RSI = R0.Q50(:,par.init+1:end);
RSE = R.Q50(:,par.init+1:end);

bk = RSE./RSI; bk = bk(:);

corrcoef(ak,bk)

ax_x = 0.6:0.05:1.15;
median_sp = zeros(1,length(ax_x));
pct25 = zeros(1,length(ax_x));
pct75 = zeros(1,length(ax_x));


for bin = 1:length(ax_x)
    temp = bk(ak>=(ax_x(bin)-0.025) & (ak<ax_x(bin)+0.025));
    median_sp(bin) = median(temp);
    pct25(bin) = prctile(temp,25);
    pct75(bin) = prctile(temp,75);
end


colors = {[0.4863    0.1137    0.4353]; [0.9412    0.4549    0.4314]};


f = figure('Renderer','painters','Units','centimeters','Position',[0 0 12 12]);
hold on
scatter(ak,bk,0.6,'filled','MarkerFaceAlpha',1,'MarkerEdgeAlpha',.0,...
    'MarkerFaceColor',colors{1})
plot(0:0.1:1.6,0:0.1:1.6,'--k')
plot(ax_x,median_sp,'.','color',colors{2},'MarkerSize',12)
%plot(x,yC,'--')

hold off
for bin = 1:length(ax_x)
    line([ax_x(bin) ax_x(bin)],[pct25(bin) pct75(bin)],'color',colors{2},'linewidth',1.2)
end
set(get(gca,'ylabel'),'rotation',0)
xlim([0.3 1.5])
ylim([0.3 1.5])
box off
set(findall(gcf,'-property','FontSize'),'FontSize',9)
xlabel('$\frac{1-\eta_l(t)}{(1-\xi_l(t))^2}\frac{\sum_{m=1}^N C_{lm} n_m}{n_l}$','interpreter','latex','fontsize',15)
ylabel('$\frac{\mathcal{R}^\mathrm{c}_l(t)}{\mathcal{R}^\mathrm{d}_l(t)}$','interpreter','latex','fontsize',15)


end
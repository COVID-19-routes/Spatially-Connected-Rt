function make_figure_mobility(Time,csi,eta,x)

Time.Format = 'MMMyy';
colors = ["#7c2170"; "#ee746e"; "#808080"];
prov = ["VR", "VI", "BL", "TV", "VE", "PD", "RO"];
a = find(eta(1,:),1,'first');
figure('Renderer', 'painters', 'Units', 'centimeters', 'Position', [1 1 8.7 6])
for i = 1:7
    if rem(i, 2) == 0
        subplot(4*2,2*2,[3+8*(i-2)/2 4+8*(i-2)/2 7+8*(i-2)/2 8+8*(i-2)/2])
    else
        subplot(4*2,2*2,[1+8*(i-1)/2 2+8*(i-1)/2 5+8*(i-1)/2 6+8*(i-1)/2])
    end
    hold on
    yyaxis left
    p1 = plot(Time(1:end),csi(i,1:end),'color',colors(1),'linewidth',1.25);
    p2 = plot(Time(1:end),ones(1,length(Time))*x(i),'color',colors(3),...
        'linewidth',0.75,'LineStyle','--');
    text(Time(20), max(max(csi)), prov(i))
    xlim([Time(1) Time(end)])
    ylim([0 1.5*max(max(csi))])
    if i < 6
        set(gca,'xticklabel',{[]})
    end

    box off
    set(gca, 'Color', 'None')
    if rem(i,2) ~= 0
        ylabel('\xi')
    else
        set(gca,'yticklabel',{[]})
    end

    yyaxis right
    p3 = plot(Time(a:end),eta(i,a:end),'Color',colors(2),'LineWidth',1.25);
    ylim([0 1])
    if rem(i,2) == 0 || i == 7
        ylabel('\eta')
    else
        set(gca,'yticklabel',{[]})
    end

    ax = gca;
    ax.YAxis(1).Color = colors(1);
    ax.YAxis(2).Color = colors(2);

    if i == 1
        legend([p1 p2 p3], '$\xi_l(t)$','$\xi_l^0$','$\eta_l(t)$',...
            'interpreter','latex','location','north')
        legend boxoff
    end
    set(findall(gcf,'-property','FontSize'),'FontSize',7)
end
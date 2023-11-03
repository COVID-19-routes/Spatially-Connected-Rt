function make_figure_compare(Time,R1,R2)

colors = ["#006e90", "#f18f01"];
prov = ["VR", "VI", "BL", "TV", "VE", "PD", "RO"];
a = find(R1(1,:),1,'first'); b = find(R1(1,:),1,'last');
figure('Renderer', 'painters', 'Units', 'centimeters', 'Position', [1 1 12 10])
for i = 1:7
    if rem(i, 2) == 0
        subplot(4*2,2*2,[3+8*(i-2)/2 4+8*(i-2)/2 7+8*(i-2)/2 8+8*(i-2)/2])
    else
        subplot(4*2,2*2,[1+8*(i-1)/2 2+8*(i-1)/2 5+8*(i-1)/2 6+8*(i-1)/2])
    end
    hold on
    p1 = plot(Time(1:end),R1(i,a:end),'color',colors(1),'linewidth',0.75);
    p2 = plot(Time(a:end),R2(i,a:end),'Color',colors(2),'LineWidth',0.75,...
        'LineStyle','--');
    plot(Time(a:b),ones(1,length(Time(a:b))),'color','red','linewidth',...
        .5,'LineStyle','--')
    text(Time(20), 1.1*max(R1(i,:)), prov(i))
    xlim([Time(1) Time(end)])
    ylim([0 1.1*max(R1(i,:))])
    if i < 6
        set(gca,'xticklabel',{[]})
    end

    box off
    set(gca, 'Color', 'None')
    if rem(i,2) ~= 0
        ylabel('$\mathcal{R}$','interpreter','latex')
    else
        set(gca,'yticklabel',{[]})
    end

    if i == 1
        legend([p1 p2], 'First approach','Second approach')
        legend boxoff
    end

end
set(findall(gcf,'-property','FontSize'),'FontSize',9)
end
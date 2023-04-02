function make_figure_synthetic(R_in,R_out,R0,model_in,model_out,diff,csi)

colors = ["#F46036"; "#2E294E"; "#1B998B"];

colors2 = ["#2274a5"; "#d1495b"; "#00798c"];


tt=1:size(R_out.Q50,2); a = find(R_out.Q95(1,:),1,'first');
figure('Renderer', 'painters', 'Units', 'centimeters', 'Position', [1 1 8.7 12])
for nn = 1:3
    subplot(4*2,2*2,[(1+8*(nn-1)):(2+8*(nn-1)) (5+8*(nn-1)):(6+8*(nn-1))])
    filler(tt(a:end),R_out.Q95(nn,a:end),R_out.Q05(nn,a:end),colors2(2),0.2);
    filler(tt(a:end),R0.Q95(nn,a:end),R0.Q05(nn,a:end),colors2(3),0.2);
    hold on
    p0 = plot(R_in(nn,:),'color','k','linewidth',1.75);
    p1 = plot(R_out.Q50(nn,:),'color',colors2(2),'linewidth',1);
    p2 = plot(R0.Q50(nn,:),'color',colors2(3),'linewidth',1);
    plot(tt(a:end),ones(1,length(tt(a:end))),'color','red','linewidth',0.5,...
        'LineStyle','--')
    if nn == 1
        ylabel('$\mathcal{R}_1$','Interpreter','latex')
        legend([p0,p1,p2], '$\mathcal{R}^{\textrm{true}}_l$',...
            '$\mathcal{R}^{\textrm{c}}_l$',...
            '$\mathcal{R}^{\textrm{d}}_l$', 'interpreter', 'latex',...
            'location','northeast')
        legend boxoff
    elseif nn == 2
        ylabel('$\mathcal{R}_2$','Interpreter','latex')
    elseif nn == 3
        ylabel('$\mathcal{R}_3$','Interpreter','latex')
    end
    xlim([tt(a) tt(end)])
    ylim([0 3])
    if nn ~= 3
        set(gca,'XTickLabel',[])
    end
    if nn == 3
        xlabel('Time')
    end
    set(gca, 'Color', 'None')
    box off
    
    subplot(4*2,2*2,[(3+8*(nn-1)):(4+8*(nn-1)) (7+8*(nn-1)):(8+8*(nn-1))])
    filler(tt(a:end),model_out.Q95(nn,a:end),model_out.Q05(nn,a:end),colors(nn),0.2);
    q1 = filler(tt(a:end),model_in(nn,a:end),ones(1,length(tt)-a+1),[0 0 0],0.15);
    hold on
    q2 = plot(tt(a:end),model_out.Q50(nn,a:end),'color',colors{nn},'linewidth',1.25);
    xlim([tt(a) tt(end)])
    ylim([0 1.1*max(max(model_out.Q95))])
    yticks([1 10 100 1000 10000])
    set(gca, 'YScale', 'log')
    set(gca, 'Color', 'None')
    if nn == 1
        legend([q1 q2], "Data","Simulated",'Location','northwest')
        legend boxoff
        set(gca,'XTickLabel',[])
    elseif nn == 2
        set(gca,'XTickLabel',[])
    end
    if nn == 1
        ylabel('$F_1$','Interpreter','latex')
    elseif nn == 2
        ylabel('$F_2$','Interpreter','latex')
    elseif nn == 3
        ylabel('$F_3$','Interpreter','latex')
    end
    box off
    set(gca,'YAxisLocation','right')

    subplot(4*2,2*2,[31 32])
    hold on
    plot(tt,csi(nn,:),'color',colors{nn})
    xlabel('Time')
    set(gca, 'Color', 'None')
    ylabel('$\xi_l$','interpreter','latex')
    set(gca,'YAxisLocation','right')
end
    
    subplot(4*2,2*2,[25 26 29 30])
    b = bar(diff'*100);
    for nn = 1:3
        set(b(nn),'facecolor',colors{nn})
        set(b(nn),'edgealpha',0)
    end
    xticklabels(["\alpha = 0"; "0.5"; "1"; "2"])
    ylim([0 1.1*max(max(diff*100))])
    ylabel('MAPE [%]')
    box off
    set(gca, 'Color', 'None')
set(gcf, 'PaperUnits', 'centimeters');
set(gcf, 'PaperSize', [18 18]);
set(findall(gcf,'-property','FontSize'),'FontSize',7)
    
end
function make_figure_averted(Time,Fp,R,csi,Q,ResPop,par,burn_in)

    Time.Format = 'MMMyy';
    alphas = [0 0.5 2];
    
    FF = zeros(7,600,length(alphas));

    sigmas = zeros(7,1);

    FF(:,:,1) = generate_cases(Fp,par,Q,ResPop,R,csi,burn_in,sigmas);

    FF(:,:,2) = generate_cases(Fp,par,Q,ResPop,R,csi*alphas(1),burn_in,sigmas);

    FF(:,:,3) = generate_cases(Fp,par,Q,ResPop,R,csi*alphas(2),burn_in,sigmas);

    FF(:,:,4) = generate_cases(Fp,par,Q,ResPop,R,csi*alphas(3),burn_in,sigmas);

    D2 = sum(squeeze(FF(:,burn_in:end,2)-FF(:,burn_in:end,1)),2)./sum(FF(:,burn_in:end,1),2)*100;
    D3 = sum(squeeze(FF(:,burn_in:end,3)-FF(:,burn_in:end,1)),2)./sum(FF(:,burn_in:end,1),2)*100;
    D4 = sum(squeeze(FF(:,burn_in:end,4)-FF(:,burn_in:end,1)),2)./sum(FF(:,burn_in:end,1),2)*100;

    DD = [D2 D3 D4];
    colors = ["#F46036"; "#2E294E"; "#1B998B"];
    prov = ["VR", "VI", "BL", "TV", "VE", "PD", "RO"];

    figure('Renderer', 'painters', 'Units', 'centimeters', 'Position', [1 1 8.7 6])
    for i = 1:7
        if rem(i, 2) == 0
            subplot(4*2,2*2,[3+8*(i-2)/2 4+8*(i-2)/2 7+8*(i-2)/2 8+8*(i-2)/2])
        else
            subplot(4*2,2*2,[1+8*(i-1)/2 2+8*(i-1)/2 5+8*(i-1)/2 6+8*(i-1)/2])
        end  
    p3 = filler(Time(1:end),FF(i,1:end,1),zeros(1,length(Time)),[0 0 0],0.15);
    hold on
    p1 = plot(Time(burn_in:end),FF(i,burn_in:end,2),'color',colors(1),'linewidth',1.25);
    p2 = plot(Time(burn_in:end),FF(i,burn_in:end,3),'color',colors(2),'linewidth',1.25);
    p4 = plot(Time(burn_in:end),FF(i,burn_in:end,4),'color',colors(3),'linewidth',1.25);
    plot(Time(1:burn_in),FF(i,1:burn_in,1),'k','linewidth',1.5);
    plot(Time(burn_in),Fp(i,burn_in),'square','color','k','MarkerSize',5,'MarkerFaceColor','k')
    text(Time(20), max(max(FF(i,:,:))), prov(i))
    if i == 7
        lgd = legend([p1 p2 p3 p4],'0', '0.5',...
            '1', '2','location','west'); 
        lgd.Title.String = '\psi =';
        legend boxoff;
    end
    if rem(i,2) ~=0
    ylabel('$F(t)$','interpreter','latex')
    end
    xlim([Time(1) Time(end)])
    ylim([0 1.1*max(max(FF(i,:,:)))])
    if i < 6
        set(gca,'xticklabel',{[]})
    end
    box off
    set(gca, 'Color', 'None') 
    end
    set(findall(gcf,'-property','FontSize'),'FontSize',8)
    subplot(4*2,2*2,[27 28 31 32])
    b = bar(DD);
    for nn = 1:3
        set(b(nn),'facecolor',colors(nn))
        set(b(nn),'edgealpha',0)
    end
    box off
    ylim([-100 100])
    set(gca, 'Color', 'None','YAxisLocation','right') 
    ylabel('$\delta F$ [\%]','interpreter','latex') 
    xticklabels(prov)
    set(findall(gcf,'-property','FontSize'),'FontSize',7)
end
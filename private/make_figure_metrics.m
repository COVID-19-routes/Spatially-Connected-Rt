function [metrics1, metrics2] = make_figure_metrics(Time,R0,R1)
Time.Format = 'mmmyy';

colors = ['#006e90', '#f18f01'];

metrics1 = zeros(2,7);
metrics2 = zeros(2,7);

for i = 1:7
%     metrics1(1,i) = sqrt(sum((R0(i,:)-R1(i,:)).^2,2,'omitnan')/size(R0,2)); 
    metrics1(1,i) = sum(abs(R0(i,:)-R1(i,:))./R0(i,:),2,'omitnan')/size(R0,2); 
    count = 0;
    for t = 1:size(R0,2)
        if (R0(i,t)<1 && R1(i,t)>1) || (R0(i,t)>1 && R1(i,t)<1)
            metrics2(2,i) =  metrics2(2,i) + 1;
        end
    end
end

figure('Renderer', 'painters', 'Units', 'centimeters', 'Position', [1 1 8.7 6])
yyaxis left
b1 = bar(1:7,metrics1*100,'FaceColor','#006e90','EdgeAlpha',0);
ylabel('MAPD [%]')
ylim([0 20])
yyaxis right
b2 = bar(1:7,metrics2/size(R0,2)*100,'FaceColor','#f18f01','EdgeAlpha',0);
ylabel({'Fraction of time with $\mathcal{R}^{\textrm{c}}_l< 1 \land \mathcal{R}^{\textrm{d}}_l> 1$';...
    'or  $\mathcal{R}^{\textrm{c}}_l> 1 \land \mathcal{R}^{\textrm{d}}_l< 1$ [\%]'},...
    'Interpreter','latex')
xticklabels(["VR","VI","BL","TV","VE","PD","RO"])
ylim([0 20])
ax = gca;
ax.YAxis(1).Color = '#006e90';
ax.YAxis(2).Color = '#f18f01';
box off
set(gca, 'Color', 'None') 
set(findall(gcf,'-property','FontSize'),'FontSize',7)


end
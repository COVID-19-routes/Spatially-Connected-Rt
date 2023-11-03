clear all
close all
clc

% Purpose
% 'run_veneto' -> runs the SMC for Veneto region
% 'check_stability' -> checks the stabiliy of the particle filter
% 'compare_with_EpiEstim' -> compares results with EpiEstim
% 'make_figure_incidence' -> makes figure with prevalence of active cases
% 'compare_two_approaches' -> compares the 1st and 2nd approach
purpose = 'run_veneto';


% Load incidence
cases = readtable("data/cases.csv");
Time = cases.data';
count = table2array(cases(:,2:end)); count(isnan(count))=0;
count = diff([zeros(1,7); count],1);
cases_province = count'; clear count cases;

lim = 600; cases_province = cases_province(:,1:lim); Time = Time(1:lim);
Fp = smoothdata(cases_province, 2, 'movmean', [13 0]); Fp(Fp<0)=0; cases_province(cases_province<0)=0;

% Load Mobility and Population
load data/mobility P_V
ResPop = [927108 852861 198518 876755 839396 930898 229097]';

C = full(P_V); clear P_V;
x=(1-diag(C)); % percentage of moving pop
Q=(C-diag(diag(C)))*diag(1./x); % extradiagonal fluxes

% Load Google Mobility Data
load data/google-data.mat
a = find(Time_GMD == Time(1)); b = find(Time_GMD == Time(end));
GMD = GMD(:,a:b);

gmd_fill = fillmissing(GMD,'linear',2);
gmd_fill_smooth = smoothdata(gmd_fill, 2, 'movmean', 14);
csi = x.*gmd_fill_smooth;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMETERS
par.mean_GD = 5.20;
par.std_GD = 1.72;
par.k = 21;
par.delay = 0;
par.init = 6;
par.Np = 50000;

par.cv_r_0 = 0.5;
par.low_cv_r=0.25;

par.alpha_min = 0;
par.delta = 0.95;

par.lik = 'V1';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RUN

switch purpose
    case 'run_veneto'
        % run filters
        par.lik = 'V1';
        [Rt1, diagnostic,model_out] = pf(Fp,par,Q,ResPop,csi);
        [R0] = pf(Fp,par,Q,ResPop,zeros(7,lim));
        % get eta
        alpha = compute_alpha(model_out.Q50,par);
        eta = get_eta(csi,Rt1.Q50,ResPop,alpha,Q);
        % make figures
        make_figure_results(R0,Rt1,Time,model_out,Fp)
        make_figure_averted(Time,Fp,Rt1.Q50,csi,Q,ResPop,par,230)
        make_figure_scatter(csi,Rt1,eta,R0,ResPop,Q,par)
        make_figure_mobility(Time,csi,eta,x)
        make_figure_metrics(Time,R0.Q50,Rt1.Q50)
        save('results/run_veneto.mat')

    case 'check_stability'
        Np_Vect = [100 500 1000 5000 10000 50000 100000];
        runs = 5;
        Var_Vect = zeros(1,length(Np_Vect));
        for nv = 1:length(Np_Vect)
            par.Np = Np_Vect(nv);
            RES = zeros(numel(csi),runs);
            for rr = 1:runs
                Rtemp = pf(Fp,par,Q,ResPop,csi);
                RES(:,rr) = Rtemp.Q50(:);
            end
            VARtemp = var(RES,1,2,'omitnan');
            Var_Vect(nv) = sum(VARtemp,'omitnan');
        end
        save('results/stability.mat')
        % Make figure
        figure('Renderer','painters','Units','centimeters','Position',[0 0 16 7])
        semilogx(Np_Vect,Var_Vect,'--.k','MarkerSize',15)
        xlabel('Number of particles')
        ylabel('Variance')
        box off
        set(findall(gcf,'-property','FontSize'),'FontSize',9)

    case 'compare_with_EpiEstim'
        tau = 14;
        cases = sum(cases_province,1);
        Fv = smoothdata(cases, 'movmean', [13 0]); Fv(Fv<0)=0; cases(cases<0)=0;
        R_SMC = pf(Fv,par,1,1,zeros(1,lim));
        R_EE = direct_method(cases(1:lim),par,tau);
        R_EE(R_EE == Inf)=NaN; R_EE(isnan(R_EE))=0;
        save('results/comparison.mat')
        % Make figure
        colors = ["#00798c", "#edae49"];
        figure('Renderer','painters','Units','centimeters','Position',[0 0 16 9])
        a = find(R_SMC.Q95(1,:),1,'first'); b = find(R_EE(1,:),1,'first'); c = max(a,b);
        filler(Time(a:end),R_SMC.Q95(a:end),R_SMC.Q05(a:end),colors(1),0.2);
        hold on
        p1=plot(Time(a:end),R_SMC.Q50(a:end),'Color',colors(1),'LineWidth',0.75);
        p2=plot(Time(b:end),R_EE(b:end),'Color',colors(2),'LineWidth',0.75);
        legend([p1,p2],'SMC','EpiEstim'); legend boxoff
        ylabel('$\mathcal{R}$','Interpreter','latex')
        xlabel('Time')
        box off
        set(findall(gcf,'-property','FontSize'),'FontSize',9)
        xlim([Time(c) Time(lim)])

    case 'make_figure_incidence'
        incidence = Fp./ResPop*1000;
        % Make figure
        colors = ["#fbcf36", "#11776c", "#5e4fa2", "#5299cb", "#98d5a4", "#ee6445", "#9d1642"];
        figure('Renderer','painters','Units','centimeters','Position',[0 0 11.4 6])
        hold on
        for i = 1:7
            plot(Time(1:600),incidence(i,1:600),'linewidth',1,'Color',colors(i))
        end
        ylabel(append('Incidence [', char(8240), ']'))
        box off
        legend(["Verona (VR)", "Vicenza (VI)", "Belluno (BL)", "Treviso (TV)",...
            "Venice (VE)", "Padua(PD)", "Rovigo(RO)"],'location','east')
        legend boxoff
        xlim([Time(1) Time(600)])

        set(gca,'Color','none')
        set(findall(gcf,'-property','FontSize'),'FontSize',7)
    case 'compare_two_approaches'
        % run filters
        par.lik = 'V1';
        [Rt1, ~,~] = pf(Fp,par,Q,ResPop,csi);
        par.lik = 'V2';
        [Rt2, ~,~] = pf(Fp,par,Q,ResPop,csi);
        make_figure_compare(Time,Rt1.Q50,Rt2.Q50)

end
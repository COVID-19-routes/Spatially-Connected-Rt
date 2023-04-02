clear all
close all
clc

% Generate mobility
ResPop = [80000; 450000; 700000];
C = [0.91 0.05 0.04; 0.05 0.83 0.12; 0.1 0.05 0.85]; C = C';
x=1-diag(C); % percentage of moving pop
Q=(C-diag(diag(C)))*diag(1./x); % extradiagonal fluxes


% Perturbate mobility
N = size(Q,1);
t = 0:364;                      % gregorian day
tf = t + [0; 50; 150];          % phases
T = t(end)+1; 
psi = (1-0.8*sin(4*pi*tf/T));   % seasonal perturbation
csi = x.*psi;                   % new csi

% Assign effective reproduction number
load data/synthetic_rt.mat
R = R(1:3,:);
R(1,:) = (1.25-0.35*sin(4*pi*(tf(2,:))/T));
R(2,:) = .8*(1-0.4*sin(4*pi*(tf(1,:)-20)/T));
R(3,:) = 1.05*R(3,:);
R(2,1:20) = .8;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% PARAMETERS
par.mean_GD = 5.20; 
par.std_GD = 1.72; 
par.k = 21; 
par.delay = 0; 
par.init = 6; 
par.Np = 50000;

par.cv_r_0=0.5;
par.low_cv_r=0.2;

par.alpha_min = 0;
par.delta = 0.95;

par.lik = 'V1';

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RUN

% Generate cases
%sigmas = [0.05; 0.08; 0.03]; % perturbation with log-normal noise
sigmas = [0.00; 0.00; 0.00]; % perturbation with log-normal noise
F = zeros(N,365);
F(1,1:6) = 25;
F(2,1:6) = 15;
F(3,1:6) = 80;
F = generate_cases(F,par,Q,ResPop,R,csi,6,sigmas); F=round(F(:,1:365)); 
F0 = generate_cases(F,par,Q,ResPop,R,zeros(3,365),6,sigmas); F0=round(F0(:,1:365)); 


% get idea of data
figure(333)
subplot(3,2,1); plot(1:365,R'); hold on ;plot(1:365,ones(365,1),'--r'); ylabel('$\mathcal{R}$','interpreter','latex') ;xlim([1 365]);
subplot(3,2,2); plot(1:365,R'); hold on; plot(1:365,ones(365,1),'--r'); ylabel('$\mathcal{R}$','interpreter','latex'); xlim([1 365])
subplot(3,2,3); plot(1:365,csi(:,1:end)'); ylabel('$\psi$','interpreter','latex'); xlim([1 365])
subplot(3,2,4); plot(1:365,zeros(3,365)'); ylabel('$\psi$','interpreter','latex'); xlim([1 365])
subplot(3,2,5); semilogy(1:365,F(:,1:end)); set(gca, 'YScale', 'log'); ylabel('$F$','interpreter','latex'); xlabel('Time'); xlim([1 365])
subplot(3,2,6); semilogy(1:365,F0(:,1:end)); set(gca, 'YScale', 'log'); ylabel('$F$','interpreter','latex'); xlabel('Time'); xlim([1 365])


figure()
subplot(1,3,1); area(1:365, F(1,:),'FaceColor',"#F46036",'EdgeAlpha',0); ylabel('$\hat{F}$','Interpreter','latex'); box off; set(gca,'Color','None')
subplot(1,3,2); area(1:365, F(2,:),'FaceColor',"#2E294E",'EdgeAlpha',0); box off; set(gca,'Color','None')
subplot(1,3,3); area(1:365, F(3,:),'FaceColor',"#1B998B",'EdgeAlpha',0); box off; set(gca,'Color','None')
%%
% Experiment with different mobilities
alpha_par = [0 0.5 1 2];
diff = zeros(3,length(alpha_par));
for i = 1:length(alpha_par)
    [Rt_out,dia,model_out] = pf(F,par,Q,ResPop,csi*alpha_par(i));
    if alpha_par(i) == 1
        R_out = Rt_out; m_out = model_out;
    elseif alpha_par(i) == 0
        R0 = Rt_out;
    end
    diff(:,i) = sum(abs(R(:,par.k:end)-Rt_out.Q50(:,par.k:end))./...
        R(:,par.k:end),2,'omitnan')/(size(R,2)-par.k+1); 
end  


make_figure_synthetic(R,R_out,R0,F,model_out,diff,csi);

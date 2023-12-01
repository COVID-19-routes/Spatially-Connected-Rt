function [R, diagnostic, model_out] = pf(data, par, Q, ResPop, csi, progress)
% PF Runs the particle filtering algorithm.
%
%   [R, diagnostic, model_out] = pf(data, par, Q, ResPop, csi, progress)
%
%   Inputs:
%       - data: the epidemiological data;
%       - par: the parameter set;
%       - Q: the initial contact matrix;
%       - ResPop: the resident population;
%       - csi: the fraction of outgoing mobility
%   Optional Inputs:
%       - progress: progress meter function (usually hooked to a waitbar)
%   Outputs:
%       - R: the estimated reproduction number;
%       - diagnostic: the diagnostics.
%       - model_out: the simulated cases according to the model's
%       predictions

if nargin == 5
    % no progress meter supplyed: create dummy function handle
    progress = @(varargin) (1);
elseif nargin < 5
    error('Not enough input arguments.')
end

% Nc: number of nodes
% Nt: number of time steps
% Np: numper of particles
[Nc, Nt] = size(data);
Np = par.Np;

% par.alpha_min: minimum value of alpha to perform the resampling of parameters
% par.delta: perform resampling when Neff < par.delta * Np

% compute alphas (convolution)
alpha = compute_alpha(data, par);
data(data == 0) = NaN;

% initialisation of vectors
R.Q50 = zeros(Nc, Nt);
R.Q05 = zeros(Nc, Nt);
R.Q25 = zeros(Nc, Nt);
R.Q75 = zeros(Nc, Nt);
R.Q95 = zeros(Nc, Nt);

diagnostic.loglike = zeros(1, Nt);
diagnostic.ESS = zeros(1, Nt);

diagnostic.sigma_r.Q50 = zeros(Nc, Nt);
diagnostic.sigma_r.Q05 = zeros(Nc, Nt);
diagnostic.sigma_r.Q95 = zeros(Nc, Nt);

% mean and std for parameter r (Rt, log-normally distributed)
r_mu_new = 3 * ones(Nc, 1);
sigma_r_new = par.cv_r_0 * r_mu_new;

% initialize weights (w=1/Np)
logW_old = -log(Np) * ones(1, Np);

% sample initial candidates for parameters

% coefficient of variation of the lognormal distrib.
cv_r = sigma_r_new ./ r_mu_new;
% sigma of the normal distribution associated to the lognormal
si2_r = log(cv_r.^2+1);
% mean of the normal distribution associated to the lognormal
mu_r = log(r_mu_new) - 0.5 * si2_r;

% samples of the lognormal distribution for R
r_cand = exp(normrnd(repmat(mu_r, 1, Np), repmat(sqrt(si2_r), 1, Np)));

%% implementation of the particle filtering
for t = par.init:Nt

    % Preparing contact matrix
    x = csi(:, t);
    C = diag(1-x) + Q * diag(x);
    ActPop = C * ResPop;

    % Computation of cases and weights

    switch par.lik
        case 'V1' % ENRICO/MARINO, PERCENTUALE
            mu = C' * ((C * (r_cand .* alpha(:, t))) ./ ActPop);
        case 'V2' % CRISTIANO, PERCENTUALE
            mu = C' * (r_cand ./ ActPop .* (C * alpha(:, t)));
        otherwise
            error("Wrong par.lik.")
    end
    w = -log(sum((log(data(:, t)./ResPop./mu)).^2, 1, 'omitnan'));
    mu = mu .* ResPop;

    % Normalisation
    w = w + logW_old;
    w(isnan(w)) = -Inf;
    w = exp(w-max(max(w))); %.*w_old;

    w = w / sum(w);
    diagnostic.ESS(t) = 1 / sum(w.^2);

    % disp(['Neff= ',num2str(diagnostic.ESS(t))])

    if diagnostic.ESS(t) < Np * par.delta

        sel = systematic_resampling(w, Np);
        r_temp = zeros(size(r_cand));

        for nn = 1:Nc
            if alpha(:, t) > par.alpha_min
                r_temp(nn, :) = r_cand(nn, sel);
            else
                r_temp(nn, :) = r_cand(nn, :);
            end
        end

        r_mu_new = mean(r_temp, 2);
        sigma_r_new = std(r_temp, 0, 2);
        cv_r = sigma_r_new ./ r_mu_new;
        cv_r(cv_r < par.low_cv_r) = par.low_cv_r;

        % variance of the normal distribution associated to the lognormal
        si2_r = log(cv_r.^2+1);
        % mean of the normal distribution associated to the lognormal
        mu_r = log(r_mu_new) - 0.5 * si2_r;


        % samples of the lognormal distribution for R
        r_cand = exp(normrnd(repmat(mu_r, 1, Np), ...
            repmat(sqrt(si2_r), 1, Np)));

        % set weights to 1/Np after resampling
        logW_old = -log(Np) * ones(1, Np);

    end

    % To output
    % these statistics should be weighted statistics
    temp = prctile(r_cand, [5,25,50,75,95], 2);
    R.Q05(:, t) = temp(:,1);
    R.Q25(:, t) = temp(:,2);
    R.Q50(:, t) = temp(:,3);
    R.Q75(:, t) = temp(:,4);
    R.Q95(:, t) = temp(:,5);

    temp = prctile(mu, [5,25,50,75,95], 2);
    model_out.Q05(:, t) = temp(:,1);
    model_out.Q25(:, t) = temp(:,2);
    model_out.Q50(:, t) = temp(:,3);
    model_out.Q75(:, t) = temp(:,4);
    model_out.Q95(:, t) = temp(:,5);

    temp = prctile(sigma_r_new, [5,50,95], 2);
    diagnostic.sigma_r.Q50(:, t) = temp(:,2);
    diagnostic.sigma_r.Q05(:, t) = temp(:,1);
    diagnostic.sigma_r.Q95(:, t) = temp(:,3);

    % median statistics
    switch par.lik
        case 'V2'
            mux = (C' * (R.Q50(:, t) ./ ActPop .* (C * alpha(:, t))));
        case 'V1'
            mux = (C' * ((C * (R.Q50(:, t) .* alpha(:, t))) ./ ActPop));
    end

    diagnostic.loglike(t) = -Nc / 2 * log(sum((log(data(:, t)./ResPop./mux)).^2));

    % report progress at end of time step loop
    progress(t/Nt);

end

R.Q50(R.Q50 == 0) = NaN;
end

%% systematic resampling
function [indn] = systematic_resampling(w, NSample)
indn = zeros(1, NSample);
u = rand * 1 / NSample;
csum = 0;
j = 0;
for cont_sample = 1:NSample
    while csum < u
        j = j + 1;
        csum = csum + w(j);
    end
    indn(cont_sample) = j;
    u = u + 1 / NSample;
end
return
end

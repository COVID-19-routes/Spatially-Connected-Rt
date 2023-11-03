function F = generate_cases(data,par,Q,ResPop,R_in,x_in,burn_in,sigmas)

F = zeros(size(R_in));
F(:,1:burn_in) = data(:,1:burn_in);

for t = burn_in+1:size(R_in,2)
    alpha = compute_alpha(F,par);
    pp=x_in(:,t);
    C = diag(1-pp)+Q*diag(pp);
    ActPop=C*ResPop;
    if strcmp(par.lik,'V1')
        mu = (C'*((C*(R_in(:,t).*alpha(:,t)))./ActPop)).*ResPop;
    elseif strcmp(par.lik,'V2')
        mu = (C'*(R_in(:,t)./ActPop.*(C*alpha(:,t)))).*ResPop;
    end

    F(:,t) = mu.*exp(normrnd(0,sigmas));

    F(F < 0) = 0;

end

end

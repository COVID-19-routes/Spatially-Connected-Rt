function [R, CV] = cori_et_al(data,par,tau)
a = (par.mean_GD/par.std_GD)^2;
b = par.mean_GD/a;
beta = @(x) gampdf(x,a,b);
k = par.k;
beta_x = beta(1:k+1); beta_x = beta_x/sum(beta_x);


R = zeros(size(data)); CV = R;

for tt = 1:length(data)
    
    num = sum(data(max(1,tt-tau+1):tt)); den = 0;
    for ii = 1:tau
       if tt-tau+1>0
           den = den+biglambda(data,beta_x,k,tt-tau+ii);
       end
    end
    
    R(tt) = num/den; CV(tt) = 1/(sqrt(num));

end

end
function lambda = biglambda(data,beta_x,k,t)
    keff = min(k,t-1);
    if sum(data(:,t-keff:t-1)) > 11
        lambda = sum(flip(data(:,t-keff:t-1)).*beta_x(1:keff),2);
    else
        lambda = NaN;
    end
end
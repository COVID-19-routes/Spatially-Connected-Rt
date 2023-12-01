function alpha = compute_alpha(data,par)

a = (par.mean_GD/par.std_GD)^2;
b = par.mean_GD/a;
beta = @(x) gampdf(x,a,b);
k = par.k;
beta_x = beta(1:k+1); beta_x = beta_x/sum(beta_x);

alpha = zeros(size(data));

for t = 2:size(alpha,2)

    keff = min(k,t-1);
    alpha(:,t) = sum(flip(data(:,t-keff:t-1),2).*beta_x(1:keff),2);
end
end

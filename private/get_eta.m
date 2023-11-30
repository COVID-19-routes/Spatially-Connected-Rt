function eta = get_eta(csi,R,ResPop,alpha,Q)

    eta = zeros(size(csi));

    for t = 1:size(csi,2)

            % BUILD CONTACT MATRIX
            C = diag(1-csi(:,t))+Q*diag(csi(:,t));
            ActPop=C*ResPop;

            % LOCAL INFECTIONS
            B = ((1-csi(:,t)).^2)./ActPop.*ResPop.*(R(:,t).*alpha(:,t));

            % ALL INFECTIONS
            G = (C'*((C*(R(:,t).*alpha(:,t)))./ActPop)).*ResPop;

            % GETTING PROPORTION
            D = B./G;
            eta(:,t) = 1-D;

    end
end

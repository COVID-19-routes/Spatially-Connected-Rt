function f = filler(xvalues,upper,lower,color,alpha)

    xx=[xvalues,fliplr(xvalues)];
    yy=[upper,fliplr(lower)];
    

    f = patch(xx,yy,'k','FaceAlpha',alpha,'FaceColor',color,...
        'EdgeAlpha',0,'EdgeColor',color);

end

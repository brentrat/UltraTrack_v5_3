function ap = detectAp(region, vidHeight)
%Detect aponeurosis borders using ginput.

for jj = 1:2

    [~,apCentre] = ginputYellow(1);

    apCentre = round(apCentre/vidHeight,2)*100;
    apRound = round(apCentre,-1);

    if apRound > apCentre
        ap(jj,1) = apRound-region;
        ap(jj,2) = apRound;
    elseif apRound < apCentre
        ap(jj,1) = apRound;
        ap(jj,2) = apRound+region;
    else
        ap(jj,1) = apRound-(region/2);
        ap(jj,2) = apRound+(region/2);
    end

end

if ap(2,1) < ap(1,2)
    ap(2,1) = ap(1,2)+1;
    ap(2,2) = ap(2,1)+region;
end

ap = ap/100;

function [RC_phase, Oz_phase] = extraUnwrap(RC_phase, Oz_phase) % removed Oz_phase

nCndSet = size(RC_phase,3);
nCnd = size(RC_phase,4);
nComp = size(RC_phase,2);
nFreq = size(RC_phase,1);

for cndSet = 1:nCndSet
    for cnd = 1:nCnd
        %%%
        curOzPhaseVector = Oz_phase(:,cndSet,cnd);
        for frq = 1:nFreq
            if frq == nFreq 
            elseif curOzPhaseVector(frq) > curOzPhaseVector(frq+1) 
            else
                curOzPhaseVector(frq+1) = curOzPhaseVector(frq+1) - 360;
            end
            Oz_phase(:,cndSet,cnd) = curOzPhaseVector;
        end
        %%%
        for c = 1:nComp
            curPhaseVector = RC_phase(:,c,cndSet,cnd);
            for frq = 2:nFreq
                if curPhaseVector(frq-1) > curPhaseVector(frq)
                else
                   curPhaseVector(frq) = curPhaseVector(frq) - 360;
                end                
            end
            RC_phase(:,cndSet,cnd) = curPhaseVector;
        end
        %%%
    end
end
function RC_phase_final = unwrapPos(RC_phase_raw)
%   An alternative to MATLAB's unwrap function that generates phase-angle
%   vs harmonic plots with a POSITIVE slope.
%
%   INPUT
%   RC_phase_raw - Double matrix with 4 or 5 dim (frequency/harmonic,
%   components, RC condition sets, individual conditions within sets, or
%   nSubj x nTrial in any order)
%
%   OUTPUT
%   RC_phase_final - Double matrix of the same size, but unwrapped via
%   addition of (multiples of) 360 until each element along the first dimension
%   is 90º greater than the last.
%
%   Bethany H. 2017

nDims = length(size(RC_phase_raw));

if nDims < 5
    for i = 1:size(RC_phase_raw,2)
        for j = 1:size(RC_phase_raw,3)
            for k = 1:size(RC_phase_raw,4)
                curPhaseVec = RC_phase_raw(:,i,j,k);
                for f = 2:size(RC_phase_raw,1)
                    while curPhaseVec(f) - curPhaseVec(f-1) < 90 % proceed while each element is less than 90º greater than the last
                        curPhaseVec(f) = curPhaseVec(f) + 360;
                    end
                end
                RC_phase_final(:,i,j,k) = curPhaseVec;
            end
        end
    end
    
else
    for i = 1:size(RC_phase_raw,2)
        for j = 1:size(RC_phase_raw,3)
            for k = 1:size(RC_phase_raw,4)
                for l = 1:size(RC_phase_raw,5)
                    curPhaseVec = RC_phase_raw(:,i,j,k,l);
                    for f = 2:size(RC_phase_raw,1)
                        while curPhaseVec(f) - curPhaseVec(f-1) < 90
                            curPhaseVec(f) = curPhaseVec(f) + 360;
                        end
                    end
                    RC_phase_final(:,i,j,k,l) = curPhaseVec;
                end                
            end
        end
    end
    
end

end
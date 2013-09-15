function [new_state,curr_state_time,tipI3flag] = paillard_discrete(curr_state,insol,curr_state_time,tstep,tipI3flag,params)
% could write this model as a handle class
% i won't

% params = {i0,i1,i2,i3,t_g}

% preset is to stay the same
new_state = curr_state;

switch curr_state
    case 'i'
        % can only transistion to g, if insolation low enough
        if insol < params{1}
            new_state = 'g';
            curr_state_time = -tstep;
        end
    case 'g'
        % can only transition to G, if a bunch of conditions are met
        % only point of confusion: if i3 breached, do we reset time?
        %   -going to start with no
        if insol < params{4} % insolation is low enough
            if curr_state_time > params{5} % enough time has happened
                if tipI3flag % and haven't tipped before
                    new_state = 'G';
                    curr_state_time = -tstep;
                else % have tipped before, so need to go under i2
                    if insol < params{3}
                        new_state = 'G';
                        curr_state_time = -tstep;
                        tipI3flag = 0;
                    end
                end
            end
        else % insolation got too high, reset timer
            tipI3flag = 1;
            curr_state_time = -tstep; % this resets the time
        end
    case 'G'
        % simple: only drop down if insolation gets too big
        if insol > params{2}
            new_state = 'i';
            curr_state_time = -tstep;
        end
end

% add to the time
curr_state_time = curr_state_time + tstep;
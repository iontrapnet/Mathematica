function wave = Wave(frequency,duration,varargin)
    % Frequency (MHz),Duration (us),Amplitude,Phase (Pi),Gap (us),Formula (x). Optional: Start (us)
    % f,d,a,p,g,F. Optional: t0
    sampling_step = 0.0008; % us ~ 1.25 GHz
    nin = numel(varargin);
    amplitude = 1;
    if nin >= 1
        amplitude = varargin{1};
    end
    phase = 0;
    if nin >= 2
        phase = varargin{2};
    end
    gap = 0;
    if nin >= 3
        gap = varargin{3};
    end
    formula = uint32(0);
    if nin >= 4
        formula = varargin{4};
    end
    t0 = 0;
    if nin >= 5
        t0 = varargin{5};
    end
    samples = t0:sampling_step:(t0+duration);
    len = length(samples);
    tail = zeros(1,8*ceil((len+gap/sampling_step)/8)-len);
    if isa(formula,'function_handle')
        wave = [formula(samples) tail];
    elseif isa(formula, 'char')
        vars = {'t0','w','f','d','a','p','g'};
        vals = [t0,2*pi*frequency,frequency,duration,amplitude,phase*pi,gap];
        % formula = subs(formula,vars,mat2cell(vals));
        for i=1:7
            formula = strrep(formula,vars(i),num2str(vals(i)));
        end
        formula = eval(['@(t)' char(formula)]);
        wave = [formula(samples) tail];
    elseif isa(formula, 'double')
        wave = [formula*ones(1,length(samples)) tail];
    else
        wave = [amplitude*cos(2*pi*frequency*samples+phase*pi) tail];    
    end
end
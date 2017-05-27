function waves = Waves(defs,varargin)
	sampling_step = 0.0008; % us ~ 1.25 GHz
	amplitude = 1;
	phase = 0;
	gap = 0;
	nin = numel(varargin);
	if nin >= 1
		gap = varargin{1};
	end
	formula = uint32(0);
	t0 = 0;
	if nin >= 2
		t0 = varargin{2};
	end
	waves = [];
	for i=1:length(defs)
		def = defs{i};
		len = length(def);
		if len == 2
			wave = Wave(def(1),def(2),amplitude,phase,gap,formula,t0);
		elseif len == 3
			wave = Wave(def(1),def(2),def(3),phase,gap,formula,t0);
		elseif len == 4
			wave = Wave(def(1),def(2),def(3),def(4),gap,formula,t0);
		elseif len == 5
			wave = Wave(def(1),def(2),def(3),def(4),def(5),formula,t0);
		elseif len >= 6
			mdef = cell2mat(def(1:5));
			formula = def(6);
			formula = formula{1};
			if len == 6
				wave = Wave(mdef(1),mdef(2),mdef(3),mdef(4),mdef(5),formula,t0);
			else
				wave = Wave(mdef(1),mdef(2),mdef(3),mdef(4),mdef(5),formula,cell2mat(def(7)));
			end
		end
		waves = [waves wave];
		t0 = t0 + length(wave)*sampling_step;
	end
end
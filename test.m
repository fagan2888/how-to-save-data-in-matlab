
pHeader;

% core variables
ntrials = round(logspace(1,2,10));
time_to_read_variable_names = zeros(length(ntrials),1);
time_to_read_random_trial = zeros(length(ntrials),1);
file_size = zeros(length(ntrials),1);
nrep = 10; % how many random trials should we read to estimate time to read random trial? 

%  #######  ##    ## ######## 
% ##     ## ###   ## ##       
% ##     ## ####  ## ##       
% ##     ## ## ## ## ######   
% ##     ## ##  #### ##       
% ##     ## ##   ### ##       
%  #######  ##    ## ######## 


% make data
delete('data.mat')
RandStream.setGlobalStream(RandStream('mt19937ar','Seed',1984)); 
for j = 1:length(ntrials)
	textbar(j,length(ntrials))
	trial_lengths = 1e4 + round(1e5*exp(randn(ntrials(j),1)));
	clear data
	for i = 1:ntrials(j)
		data(i).variable1 = rand(trial_lengths(i),1);
		data(i).variable2 = rand(trial_lengths(i),1);
		if rand > .5
			data(i).variable3 = rand(trial_lengths(i),1);
		end
	end
	save('data.mat','data','-v7.3')

	% test it
	m = matfile('data.mat');

	tic; f = fieldnames(m.data); time_to_read_variable_names(j) = toc;

	clear temp
	temp = dir('data.mat');
	file_size(j) = temp.bytes;

	clear temp
	temp = zeros(nrep,1);
	for i = 1:nrep
		tic; temp2 = m.data(1,floor(1+rand*(ntrials(j)-1))); temp(i) = toc;
	end
	time_to_read_random_trial(j) = mean(temp);
	clear temp temp2
end

data_type_results(1).file_size = file_size;
data_type_results(1).time_to_read_random_trial = time_to_read_random_trial;
data_type_results(1).time_to_read_variable_names = time_to_read_variable_names;


% now we do data type 2
% make data
delete('data.mat')
RandStream.setGlobalStream(RandStream('mt19937ar','Seed',1984)); 
for j = 1:length(ntrials)
	textbar(j,length(ntrials))
	trial_lengths = 1e4 + round(1e5*exp(randn(ntrials(j),1)));
	clear variable1 variable2 variable3
	variable1 = struct();
	variable2 = struct();
	variable3 = struct();
	for i = 1:ntrials(j)
		variable1(i).data = rand(trial_lengths(i),1);
		variable2(i).data = rand(trial_lengths(i),1);
		if rand > .5
			variable3(i).data = rand(trial_lengths(i),1);
		else
			variable3(i).data = [];
		end
	end
	save('data.mat','variable1','variable2','variable3','-v7.3')

	% test it
	m = matfile('data.mat');

	tic; f = whos(m); time_to_read_variable_names(j) = toc;
	variable_names = {f.name};

	clear temp
	temp = dir('data.mat');
	file_size(j) = temp.bytes;

	clear temp
	temp = zeros(nrep,1);
	for i = 1:nrep
		tic; 
		for k = 1:length(variable_names)
			temp2 = m.(variable_names{k})(1,10);
		end
		temp(i) = toc;
	end
	time_to_read_random_trial(j) = mean(temp);
	clear temp temp2
end

data_type_results(2).file_size = file_size;
data_type_results(2).time_to_read_random_trial = time_to_read_random_trial;
data_type_results(2).time_to_read_variable_names = time_to_read_variable_names;

figure('outerposition',[0 0 1000 500],'PaperUnits','points','PaperSize',[1000 500]); hold on
subplot(1,2,1); hold on
for i = 1:length(data_type_results)
	plot(data_type_results(i).file_size,data_type_results(i).time_to_read_variable_names,'+-')
end
xlabel('File size (bytes)')
ylabel('Time to read variable names (s)')
set(gca,'XScale','log','YScale','log','YLim',[1e-3 10])

subplot(1,2,2); hold on
for i = 1:length(data_type_results)
	plot(data_type_results(i).file_size,data_type_results(i).time_to_read_random_trial,'+-')
end
xlabel('File size (bytes)')
ylabel('Time to read random trial (s)')
set(gca,'XScale','log','YScale','log','YLim',[1e-3 10])
legend({'simple structure','k2data format'})

prettyFig()

if being_published	
	snapnow	
	delete(gcf)
end


%% Version Info
%
pFooter;



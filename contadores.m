close all; clear all;

diary('contadores.log')
mkdir('results')
save_mat=true;

exclude={'id','ld_id','date_time','model','fake_data'}; %Variables to exclude
counters={'count_.*','.*counter.*','.*total.*'}; %Variables to count as counters
allBad={};

%use_config=1; % test config
%use_config=10;
use_config=[2,10];
disp(['---------------------------------------- ',char(datetime('now','TimeZone','local','Format','d-MMM-y HH:mm:ss Z')),' -----------------------------------------'])
for c=use_config
	disp(['Getting data for config: ',num2str(c),'...'])
    diary off
    diary on
    
    data=getDBdata(save_mat,c);

	lds_ids=reshape(cell2mat(data.ld_id),1,length(data.ld_id));
    for ld_id = lds_ids
        years=data.config{[data.ld_id{:}]==ld_id}.years{1};
        plant=char(data.config{[data.ld_id{:}]==ld_id}.data_table_name);
        if ~exist('allBad','var'), allBad=cell(size(years,2),1); end
        for y=1:size(years,2)
			disp(['Working on: ',num2str(ld_id),' year: ',num2str(years(y)),'...'])
			tmpdata=data.data{[data.ld_id{:}]==ld_id}{y};

			[m,n]=size(tmpdata);
			if(m==0||n==0)
				disp('No data');
			end

			%Results to table
			date_time=array2table(tmpdata.date_time);

			a=1;
			pi=1;

			TEST_RESULT=cell(n*size(lds_ids,1),6);
			TEST_RESULT=array2table(TEST_RESULT);
			TEST_RESULT.Properties.VariableNames={'VarName','VarColumn','ld_id','MaxEntropy','MinEntropy','AvgEntropy'};

			for j=1:n %iterate over columns
				currentVarName=tmpdata.Properties.VariableNames{j};
				if ~any(strcmp(exclude,currentVarName)) %If is in exclude list skip  id,ld_id,date_time,model...
					TEST_RESULT.ld_id(a)={ld_id};
					TEST_RESULT.VarName(a)={currentVarName};
					TEST_RESULT.VarColumn(a)={j};                
					x=tmpdata.(j);
					
					%calculamos la gradiente de los datos
					g=gradient(x);
					%hacemos clustering con k-means, 4 clusters
					c=kmeans(g,4);
					%computamos la entropia de shannon para cada cluster
					Ec1=wentropy(x(find(c==1)),'shannon');
					Ec2=wentropy(x(find(c==2)),'shannon');
					Ec3=wentropy(x(find(c==3)),'shannon');
					Ec4=wentropy(x(find(c==4)),'shannon');
					maxEntropy=max([Ec1,Ec2,Ec3,Ec4]);
					minEntropy=min([Ec1,Ec2,Ec3,Ec4]);
					avgEntropy=(Ec1+Ec2+Ec3+Ec4)/4;
					TEST_RESULT.MaxEntropy(a)={maxEntropy};
					TEST_RESULT.MinEntropy(a)={minEntropy};
					TEST_RESULT.AvgEntropy(a)={avgEntropy};
					a=a+1;
				end
			end
			idheys=find(abs(cell2mat(TEST_RESULT.AvgEntropy))>=1000000000000 | cell2mat(TEST_RESULT.AvgEntropy)==0);
			numVars=size(idheys,1);
			plotly=cell(numVars,1);
			for id=1:numVars                
				%he=cell2mat(TEST_RESULT.He(idheys(id)));
				%hys=cell2mat(TEST_RESULT.Hys(idheys(id)));
				currentVarName=TEST_RESULT.VarName(idheys(id));
				tmpdata2=tmpdata.(cell2mat(TEST_RESULT.VarColumn(idheys(id))));
				dt=table2cell(tmpdata(:,{'date_time'}));
				dn=datenum(dt,'yyyy-mm-dd HH:MM:SS.FFF');
				timestamps=int32(floor(86400 * (dn - datenum('01-Jan-1970')))).';
				%dt=cellstr(datestr(dn,'yyyy-mm-dd HH:MM:SS'));
				%titlea=['ld_id:',num2str(ld_id),' ',currentVarName,' He:',num2str(he),' Hys:',num2str(hys)];                 
				%subplot(size(idheys,1),1,id)
				%plot(dn,tmpdata2);
				%datetick('x','keepticks','keeplimits')
				%title(strrep(titlea,'_','\_'));
				trace1 = struct(...
				  'x', timestamps , ...
				  'y', tmpdata2, ...
				  'visible', 'legendonly', ...
				  'type', 'scatter', ...
				  'text', {dt.'}, ...
				  'name', currentVarName);
				plotly(id)={trace1};           

				if isempty(cell2mat(regexp(currentVarName, counters)))
					trace2 = struct(...
					  'x', timestamps , ...
					  'y', tmpdata2, ...
					  'visible', 'legendonly', ...
					  'type', 'scatter', ...
					  'text', {dt.'}, ...
					  'name', strjoin(['ld_id:',num2str(ld_id),' ',currentVarName]) ...
					  );
					allBad(y)={trace2};    
				end
			end

			layout = struct('showlegend', true);
			layout.title = num2str(ld_id);
			layout.width = 1850; % required
			layout.height = 950; % required
			%layout.yaxis.type = 'log';
			layout.xaxis.tickformat = 'd';
			layout.yaxis.zeroline='true';
            layout.showlegend='true';
			p = plotlyfig; % initalize an empty figure object
			p.data = plotly;
			p.layout = layout;
			p.PlotOptions.FileName = ['results/',plant,'_',num2str(ld_id),'_',num2str(years(y)),'_counters'];
			html_file = plotlyoffline(p);     
			close(gcf);                
			save(['results/TEST_RESULT_',num2str(ld_id),'_',num2str(years(y)),'.mat'],'TEST_RESULT');
        end
    end
    for y=1:size(years,2)
        layout = struct('showlegend', true);
        layout.title = 'Detected non counter variables';
        layout.width = 1850; % required
        layout.height = 950; % required
        layout.xaxis.tickformat = 'd';
        layout.yaxis.zeroline='true';
        layout.showlegend='true';
        %layout.yaxis.type = 'log';
        p = plotlyfig; % initalize an empty figure object
        p.data = allBad(y);
        p.layout = layout;
        p.PlotOptions.FileName = ['results/',plant,'_',num2str(years(y)),'_non_counter_variables'];
		html_file = plotlyoffline(p);     
        close(gcf);
        files={[plant,'_',num2str(years(y)),'_non_counter_variables.html'],[plant,'_*_',num2str(years(y)),'_counters.html'],['TEST_RESULT_*_',num2str(years(y)),'.mat']};
        zipFileName=['results/',plant,'_',num2str(years(y)),'.zip'];
        zip(zipFileName,files,'results');
        delete(['results/',plant,'_*_',num2str(years(y)),'_counters.html'])
        delete(['results/',plant,'_',num2str(years(y)),'_non_counter_variables.html'])
        delete(['results/TEST_RESULT_*_',num2str(years(y)),'.mat'])
   end
end
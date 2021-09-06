close all; clear all;

diary('contadores.log')
mkdir('results')
maxK=10;

exclude={'id','ld_id','date_time','model','fake_data'}; %Variables to exclude
counters={'count_.*','.*counter.*','.*total.*','*.OperatingHours.*','*.Counter.*'}; %Variables to count as counters

types={'kmeans','kmedoids'};
%types={'kmeans'};

gz = dir('data/*.gz'); 
for q = 1:length(gz)
	files_name=gunzip(['data/',gz(q).name]);
    data=readtable(files_name{1});
    lds_ids=unique(data.ld_id);
    for type=1:length(types)
        for k = 1:maxK
            allBad=cell(size(years,2),1);
            for idx = 1:numel(lds_ids)
                ld_id=lds_ids(idx);
                row_idx = (data.ld_id(:) == ld_id);
                dataFromld_id=data(row_idx,:);
                years=unique(year(dataFromld_id.date_time));
                files_name2=strsplit(files_name{1},'/');
                v=strsplit(files_name2{length(files_name2)},'_');
                plant=[v{1,1},'_',v{1,2}];
                %if ~exist('allBad','var'), allBad=cell(size(years,2),1); end        
                for y=1:size(years,1)
                    number_counters_found=0;            
                    badClassified=cell(1,1);
                    disp(['Working on type(',types{type},') and k(',num2str(k),'): ',num2str(ld_id),' year: ',num2str(years(y)),'...'])
                    row_idx2 = (year(dataFromld_id.date_time) == years(y));
                    tmpdata=dataFromld_id(row_idx2,:);

                    [m,n]=size(tmpdata);
                    if(m==0||n==0)
                        disp('No data');
                    end

                    %Results to table
                    date_time=tmpdata.date_time;

                    a=1;
                    pi=1;

                    TEST_RESULT=cell(n*size(lds_ids,1)*maxK*2,9);
                    TEST_RESULT=array2table(TEST_RESULT);
                    TEST_RESULT.Properties.VariableNames={'VarName','VarColumn','ld_id','MaxEntropy','MinEntropy','AvgEntropy','IsCounterConstant','typeClustering','numClusters'};

                    for j=1:n %iterate over columns
                        currentVarName=tmpdata.Properties.VariableNames{j};
                        if ~any(strcmp(exclude,currentVarName)) %If is in exclude list skip  id,ld_id,date_time,model...
                            TEST_RESULT.ld_id(a)={ld_id};
                            TEST_RESULT.VarName(a)={currentVarName};
                            TEST_RESULT.VarColumn(a)={j};
                            TEST_RESULT.IsCounterConstant(a)={0};
                            TEST_RESULT.numClusters(a)={k};
                            TEST_RESULT.typeClustering(a)=types(type);
                            if(isa(tmpdata.(j),'cell'))
                                x=str2double(tmpdata.(j));
                            else
                                x=tmpdata.(j);
                            end
                            x=x(~isnan(x(:)));
                            if(~isempty(x)&&size(x,1)>k)
                                %calculamos la gradiente de los datos
                                g=gradient(x);

                                if(isequal(types(type),{'kmeans'}))
                                    %hacemos clustering con k-means, k clusters
                                    c=kmeans(g,k);
                                else
                                    %hacemos clustering con k-means, k clusters
                                    c=kmedoids(g,k);
                                end
                                %computamos la entropia de shannon para cada cluster
                                Ec=zeros(1,k);
                                for ik = 1:k
                                    Ec(ik)=wentropy(x(find(c==ik)),'shannon');
                                end

                                maxEntropy=max(Ec);
                                minEntropy=min(Ec);
                                avgEntropy=mean(Ec);
                                TEST_RESULT.MaxEntropy(a)={maxEntropy};
                                TEST_RESULT.MinEntropy(a)={minEntropy};
                                TEST_RESULT.AvgEntropy(a)={avgEntropy};
                            else
                                TEST_RESULT.MaxEntropy(a)={NaN};
                                TEST_RESULT.MinEntropy(a)={NaN};
                                TEST_RESULT.AvgEntropy(a)={NaN};
                            end
                            a=a+1;
                        end
                    end
                    idheys=find(abs(cell2mat(TEST_RESULT.AvgEntropy))>=1000000000000 | cell2mat(TEST_RESULT.AvgEntropy)==0);
                    numVars=size(idheys,1);
                    plotly=cell(numVars,1);
                    for id=1:numVars                
                        %he=cell2mat(TEST_RESULT.He(idheys(id)));
                        %hys=cell2mat(TEST_RESULT.Hys(idheys(id)));
                        TEST_RESULT.IsCounterConstant(idheys(id))={1};
                        currentVarName=TEST_RESULT.VarName(idheys(id));
                        currentVarPos=cell2mat(currentVarName);
                        if(isa(tmpdata.(currentVarPos),'cell'))
                                tmpdata2=str2double(tmpdata.(currentVarPos));
                        else
                                tmpdata2=tmpdata.(currentVarPos);
                        end
                        dn=datenum(date_time);
                        timestamps=int32(floor(86400 * (dn - datenum('01-Jan-1970')))).';
                        %dt=cellstr(datestr(dn,'yyyy-mm-dd HH:MM:SS'));
                        %titlea=['ld_id:',num2str(ld_id),' ',currentVarName,' He:',num2str(he),' Hys:',num2str(hys)];                 
                        %subplot(size(idheys,1),1,id)
                        %plot(dn,tmpdata2);
                        %datetick('x','keepticks','keeplimits')
                        %title(strrep(titlea,'_','\_'));
                        trace1 = struct(...
                          'x', timestamps , ...
                          'y', tmpdata2.', ...
                          'visible', 'legendonly', ...
                          'type', 'scatter', ...
                          'name', currentVarName);
                        plotly(id)={trace1};           

                        if isempty(cell2mat(regexp(currentVarName, counters)))
                            trace2 = struct(...
                              'x', timestamps , ...
                              'y', tmpdata2.', ...
                              'visible', 'legendonly', ...
                              'type', 'scatter', ...
                              'name', strjoin(['ld_id:',num2str(ld_id),' ',currentVarName,' ',num2str(years(y))]));
                            if size(badClassified,1)>1&&(size(badClassified,2)>1)
                                badClassified2=cell(1,size(badClassified,2)+1);
                                badClassified2={badClassified{:},trace2};
                                badClassified=badClassified2;
                            else
                                badClassified={trace2};   
                            end
                        end
                        number_counters_found=number_counters_found+1;
                    end
                    if(number_counters_found>0)
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
                        p.PlotOptions.FileName = ['results/',plant,'_',types{type},'_k',num2str(k),'_',num2str(ld_id),'_',num2str(years(y)),'_counters'];
                        html_file = plotlyoffline(p);     
                        close(gcf);                 
                    end
                    save(['results/TEST_RESULT_',types{type},'_k',num2str(k),'_',num2str(ld_id),'_',num2str(years(y)),'.mat'],'TEST_RESULT');

                    if ~isempty(allBad{y})&&size(allBad(y),1)>0
                        allBad{y}=horzcat(allBad{y},badClassified);
                    else
                        allBad{y}=badClassified;
                    end
                end
            end
        for y=1:size(years,1)
            layout = struct('showlegend', true);
            layout.title = 'Detected variable that doesn''t contain the counter pattern name';
            layout.width = 1850; % required
            layout.height = 950; % required
            layout.xaxis.tickformat = 'd';
            layout.yaxis.zeroline='true';
            layout.showlegend='true';
            %layout.yaxis.type = 'log';
            p = plotlyfig; % initalize an empty figure object
            p.data = allBad{y};
            p.layout = layout;
            p.PlotOptions.FileName = ['results/',plant,'_',types{type},'_k',num2str(k),'_',num2str(years(y)),'_non_counter_variables'];
            html_file = plotlyoffline(p);     
            close(gcf);
            files={[plant,'_',types{type},'_k',num2str(k),'_',num2str(years(y)),'_non_counter_variables.html'],[plant,'_',types{type},'_k',num2str(k),'_*_',num2str(years(y)),'_counters.html'],['TEST_RESULT_',types{type},'_k',num2str(k),'_*_',num2str(years(y)),'.mat']};
            zipFileName=['results/',plant,'_',types{type},'_k',num2str(k),'_',num2str(years(y)),'.zip'];
            zip(zipFileName,files,'results');
            delete(['results/',plant,'_',types{type},'_k',num2str(k),'_*_',num2str(years(y)),'_counters.html'])
            delete(['results/',plant,'_',types{type},'_k',num2str(k),'_',num2str(years(y)),'_non_counter_variables.html'])
            delete(['results/TEST_RESULT_',types{type},'_k',num2str(k),'_*_',num2str(years(y)),'.mat'])
        end
        end
    end
    delete(files_name{1});
end
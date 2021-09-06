mat = dir('*.mat'); 
for q = 16:length(mat)
    disp(strcat('Processing:',mat(q).name))
    load(mat(q).name); 
    totaldata=[];
    for i=1:size(data,1)
        if(class(data.data{i})==string('cell'))
            data.data{i}{1}.ld_id = repmat(data.ld_id{i},[size(data.data{i}{1},1),1]);
            totaldata = vertcat(totaldata,data.data{i}{1});
        else
            data.data{i}.ld_id = repmat(data.ld_id{i},[size(data.data{i},1),1]);
            totaldata = vertcat(totaldata,data.data{i});
        end
    end
    if(class(data.config{1}.data_table_name)==string('cell'))
            tablename=data.config{1}.data_table_name{1};
    else
            tablename=data.config{1}.data_table_name;
    end
    if(class(data.date_ini{1})==string('cell'))
            date_time=data.date_ini{1}{1};
    else
            date_time=data.date_ini{1};
    end
    filename=char(strcat(tablename,'_',num2str(year(datetime(date_time))),'.csv'));
    writetable(totaldata,filename,'Delimiter',',','QuoteStrings',true);
    zip(strcat(filename,'.zip'),filename);
    delete(filename);
    clear totaldata i data filename;
    disp(strcat('Finish:',mat(q).name))
end
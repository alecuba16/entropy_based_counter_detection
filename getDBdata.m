function data=getDBdata(save_mat,use_config,configs)
if ~exist('use_config','var'), use_config = 2; end
if ~exist('save_mat','var'), save_mat = false; end
if ~exist('configs','var')
	configs=cell2table(cell(19,11));
	configs.Properties.VariableNames={'maquina','data_table_name','alarm_table_name','model_data_freq_min','power_variable_name','seconds_to_aggregate','use_only_positive_power_data','years','ld_id','alarms','variables'};
	configs{1,:}={'Test Robres Vestas V90 yaw','rob_v90','rob_v90_events','10','power_avg','86400','0',[2013,2014],[67,68],'79,186',''}; %Vestas v90 Robres.
    configs{2,:}={'Sant Antoni Fuhrlander fl2500 main bearing','sta_fl2500','sta_fl2500_events','5','wgdc_avg_TriGri_PwrAt','300','0',[2012,2013,2014],[80,81,82,83,84],'2142,1381,1273,1382,1392,1380,1360,1359,1364,1363','alarm,date_time,wtrm_min_TrmTmp_Brg1,wtrm_max_TrmTmp_Brg1,wtrm_avg_TrmTmp_Brg1,wtrm_sdv_TrmTmp_Brg1,wtrm_min_TrmTmp_Brg2,wtrm_max_TrmTmp_Brg2,wtrm_avg_TrmTmp_Brg2,wtrm_sdv_TrmTmp_Brg2,wtrm_min_Brg_OilPres,wtrm_max_Brg_OilPres,wtrm_avg_Brg_OilPres,wtrm_sdv_Brg_OilPres,wtrm_min_Gbx_OilPres,wtrm_max_Gbx_OilPres,wtrm_avg_Gbx_OilPres,wtrm_sdv_Gbx_OilPres,wtrm_min_Brg_OilPresIn,wtrm_max_Brg_OilPresIn,wtrm_avg_Brg_OilPresIn,wtrm_sdv_Brg_OilPresIn,wnac_min_WSpd1,wnac_max_WSpd1,wnac_avg_WSpd1,wnac_sdv_WSpd1,wnac_min_Wdir1,wnac_max_Wdir1,wnac_avg_Wdir1,wnac_sdv_Wdir1,wnac_min_Wdir2,wnac_max_Wdir2,wnac_avg_Wdir2,wnac_sdv_Wdir2,wgdc_min_TriGri_PwrAt,wgdc_max_TriGri_PwrAt,wgdc_avg_TriGri_PwrAt,wgdc_sdv_TriGri_PwrAt'}; %fuhrlander@5min.
	configs{3,:}={'Sant Antoni Fuhrlander fl2500 main bearing','sta_fl2500','sta_fl2500_events','5','wgdc_avg_TriGri_PwrAt','3600','0',[2012,2013,2014],[80,81,82,83,84],'2142,1381,1273,1382,1392,1380,1360,1359,1364,1363','alarm,date_time,wtrm_min_TrmTmp_Brg1,wtrm_max_TrmTmp_Brg1,wtrm_avg_TrmTmp_Brg1,wtrm_sdv_TrmTmp_Brg1,wtrm_min_TrmTmp_Brg2,wtrm_max_TrmTmp_Brg2,wtrm_avg_TrmTmp_Brg2,wtrm_sdv_TrmTmp_Brg2,wtrm_min_Brg_OilPres,wtrm_max_Brg_OilPres,wtrm_avg_Brg_OilPres,wtrm_sdv_Brg_OilPres,wtrm_min_Gbx_OilPres,wtrm_max_Gbx_OilPres,wtrm_avg_Gbx_OilPres,wtrm_sdv_Gbx_OilPres,wtrm_min_Brg_OilPresIn,wtrm_max_Brg_OilPresIn,wtrm_avg_Brg_OilPresIn,wtrm_sdv_Brg_OilPresIn,wnac_min_WSpd1,wnac_max_WSpd1,wnac_avg_WSpd1,wnac_sdv_WSpd1,wnac_min_Wdir1,wnac_max_Wdir1,wnac_avg_Wdir1,wnac_sdv_Wdir1,wnac_min_Wdir2,wnac_max_Wdir2,wnac_avg_Wdir2,wnac_sdv_Wdir2,wgdc_min_TriGri_PwrAt,wgdc_max_TriGri_PwrAt,wgdc_avg_TriGri_PwrAt,wgdc_sdv_TriGri_PwrAt'}; %fuhrlander@1h
	configs{4,:}={'Robres Vestas V90 yaw','rob_v90','rob_v90_events','10','power_avg','600','0',[2013,2014,2015,2016],[67,68,69,70,71,72,73,74,75,76,77,78,79],'79,186',''}; %Vestas v90 Robres.
	configs{5,:}={'Pedregoso Vestas V90 yaw','ped_v90','ped_v90_events','10','avg_grid_production_power','600','0',[2010,2011,2013,2014],[112,113,114,115,116,117],'79,180,183,186,356,89',''}; %Vestas v90 Pedregoso.
	configs{6,:}={'Pedregoso Vestas V90 yaw','ped_v90','ped_v90_events','10','avg_grid_production_power','600','0',[2010],[112,113,114,115,116,117],'79,180,183,186,356,89',''}; %Vestas v90 Pedregoso.
    configs{7,:}={'Pedregoso Vestas V90 yaw','ped_v90','ped_v90_events','10','avg_grid_production_power','600','0',[2011],[112,113,114,115,116,117],'79,180,183,186,356,89',''}; %Vestas v90 Pedregoso 2011.
    configs{8,:}={'Pedregoso Vestas V90 yaw','ped_v90','ped_v90_events','10','avg_grid_production_power','600','0',[2013],[112,113,114,115,116,117],'79,180,183,186,356,89',''}; %Vestas v90 Pedregoso 2013.
    configs{9,:}={'Pedregoso Vestas V90 yaw','ped_v90','ped_v90_events','10','avg_grid_production_power','600','0',[2014],[112,113,114,115,116,117],'79,180,183,186,356,89',''}; %Vestas v90 Pedregoso 2014.
    configs{10,:}={'Wfa h1 eco 100 yaw','wfa_h1','wfa_h1_events','10','wtur_avg_W','600','0',[2010,2011,2012,2013,2014,2015,2016],[85],'512',''}; %Wfa H1 eco 100.
	configs{11,:}={'Pforcada bonus AE','pfc_ae','pfc_ae_events','10','power','600','0',[2015],[41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66],'',''}; % Bonus pforcada ae events.
	configs{12,:}={'Sant Antoni Fuhrlander fl2500 main bearing','sta_fl2500','sta_fl2500_events','5','wgdc_avg_TriGri_PwrAt','300','0',[2012],[80,81,82,83,84],'',''}; %fuhrlander@5min all.
	configs{13,:}={'Sant Antoni Fuhrlander fl2500 main bearing','sta_fl2500','sta_fl2500_events','5','wgdc_avg_TriGri_PwrAt','300','0',[2013],[80,81,82,83,84],'',''}; %fuhrlander@5min all.
	configs{14,:}={'Sant Antoni Fuhrlander fl2500 main bearing','sta_fl2500','sta_fl2500_events','5','wgdc_avg_TriGri_PwrAt','300','0',[2014],[80,81,82,83,84],'',''}; %fuhrlander@5min all.
	configs{15,:}={'Sant Antoni Fuhrlander fl2500 main bearing','sta_fl2500','sta_fl2500_events','5','wgdc_avg_TriGri_PwrAt','300','0',[2015],[80,81,82,83,84],'',''}; %fuhrlander@5min all.
	configs{16,:}={'Robres Vestas V90 yaw','rob_v90','rob_v90_events','10','power_avg','600','0',[2013],[67,68,69,70,71,72,73,74,75,76,77,78,79],'79,186',''}; %Vestas v90 Robres..
	configs{17,:}={'Robres Vestas V90 yaw','rob_v90','rob_v90_events','10','power_avg','600','0',[2014],[67,68,69,70,71,72,73,74,75,76,77,78,79],'79,186',''}; %Vestas v90 Robres..
	configs{18,:}={'Robres Vestas V90 yaw','rob_v90','rob_v90_events','10','power_avg','600','0',[2015],[67,68,69,70,71,72,73,74,75,76,77,78,79],'79,186',''}; %Vestas v90 Robres..
	configs{19,:}={'Robres Vestas V90 yaw','rob_v90','rob_v90_events','10','power_avg','600','0',[2016],[67,68,69,70,71,72,73,74,75,76,77,78,79],'79,186',''}; %Vestas v90 Robres..
end

seconds_to_aggregate=configs.seconds_to_aggregate(use_config);
data_table_name=configs.data_table_name(use_config);
alarm_table_name=configs.alarm_table_name(use_config);
model_data_freq_min=configs.model_data_freq_min(use_config);
power_variable_name=configs.power_variable_name(use_config);
use_only_positive_power_data=configs.use_only_positive_power_data(use_config);
alarms=configs.alarms(use_config);
include=configs.variables{use_config};
ld_ids=configs.ld_id{use_config};
years=configs.years{use_config};
dataFrequencyInSeconds=str2double(configs.seconds_to_aggregate{use_config});
dataFrequencyInMinutes=round(dataFrequencyInSeconds/60);
alldata = cell2table(cell(length(ld_ids),6));
alldata.Properties.VariableNames={'ld_id','date_ini','date_end','data','config','notes'};
for year=years
    if exist('tmpdata','var') 
        clear tmpdata;
    end
    if exist('data','var') 
        clear data;
    end
    if (exist('save_mat','var') && save_mat)
        data = cell2table(cell(length(ld_ids),6));
        data.Properties.VariableNames={'ld_id','date_ini','date_end','data','config','notes'};
    else
        data=alldata;
    end
	%check if mat file exists
	matname=[char(data_table_name),'_',num2str(year),'_',num2str(dataFrequencyInMinutes),'min.mat'];
	
	if exist(matname, 'file') ~= 2
		dateini=['01-Jan-',num2str(year),' 00:00:00'];
		dateend=['31-Dec-',num2str(year),' 23:59:59'];
		%dateend=['10-Jan-',num2str(year),' 23:59:59'];
		
		%Date to timestamp
		iniTimestamp=int32(floor(86400 * (datenum(dateini) - datenum('01-Jan-1970'))));
		endTimestamp=int32(floor(86400 * (datenum(dateend) - datenum('01-Jan-1970'))));

		
		%data.date_ini={data.date_ini,repmat({dateini},length(ld_ids),1)};
		%data.date_end={data.date_end,repmat({dateend},length(ld_ids),1)};
        
		pos=1;
		for ld_id = ld_ids
            data.date_ini{pos}=vertcat(data.date_ini{pos},{dateend});
            data.date_end{pos}=vertcat(data.date_end{pos},{dateend});
			data.ld_id(pos)={ld_id};
			query=strcat('CALL formatter(''',data_table_name,''', ''',alarm_table_name,''',',num2str(ld_id),', ''',alarms,''', ''',power_variable_name,''',',use_only_positive_power_data,','''',''model,fake_data,weekly_production,weekly_n1'', ',model_data_freq_min,',',num2str(iniTimestamp),',',num2str(endTimestamp),',',seconds_to_aggregate,',0)');
			disp(query)
			tmpdata=querySmartive(query);
			%Results to table
			if(size(tmpdata,1)>0)
				if ~isempty(include)
					tmpdata=tmpdata(:,strsplit(include,','));
                end
                if size(data.data{pos},2)>0
                    data.data{pos}=vertcat(data.data{pos},{tmpdata});
                else
                    data.data{pos}=tmpdata;
                end
				data.config(pos)={configs(use_config,:)};
				data.notes(pos)={'alarm-> 0=ok/1=alarm'};
            else
                if ~isempty(include)
					tmpdata=cell2table(cell(0,size(include,1)));
                    tmpdata.Properties.VariableNames=include;
                else
                    tmpdata=cell2table(cell(0,0));
                end
				
                if size(data.data{pos},1)>0
                    data.data{pos}=vertcat(data.data{pos},{tmpdata});
                else
                    data.data{pos}={tmpdata};
                end
				data.config(pos)={configs(use_config,:)};
				data.notes(pos)={['No data for:',num2str(ld_id),' ',dateini,' -- ',dateend]};
				disp(['No data for:',num2str(ld_id),' ',dateini,' -- ',dateend])
			end
			pos=pos+1;
            whos
        end
        whos
		if (exist('save_mat','var') && save_mat)
            save(matname,'data','-v7.3'); 
        else
            alldata=data;
        end
	else
		load(matname);
	end
end
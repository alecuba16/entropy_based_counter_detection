function data=querySmartive(query)
	 %connections params
    db = 'yourHistoricalBD';
    user = 'user';
    pass = 'password';
    host = 'yourHost:3306';
      
    % Prerequirements add mysql connector to path of matlab-java
    if ispc %windows
       alecuba16SqlWrapper=[pwd,'\query.jar'];
    else %Linux Mac
       alecuba16SqlWrapper=[pwd,'/query.jar'];
    end
      
    %check if the mysql connector is included into the path
    jc=cellfun(@isempty,regexp(javaclasspath,'query'));
    if isempty(jc) || isequal(jc,1)
        javaaddpath(alecuba16SqlWrapper,'-end');                
    end
    
    a = smartive.alecuba16.Query;
    rs=javaMethod('runQuery', a, host,db,user,pass,query);
    %save('rs_workspace.mat','rs');
    %load rs_workspace.mat
    nrows=size(rs,1);    
    if(nrows>0)
        v=ver;
        has_par=any(strcmp(cellstr(char(v.Name)), 'Parallel Computing Toolbox'));
        has_par=0;%disabled parallel
        if(has_par)
            % %Preparacion parallel 
            p = gcp;
            delete(p) %apagar cualquier pool viejo activo.
            %numLogicalCpus=8;
            numLogicalCpus=eval('java.lang.Runtime.getRuntime().availableProcessors');
            LASTN = maxNumCompThreads(numLogicalCpus);%si tiene hyperthreating forzamos que matlab lo use.
            c = parcluster('local');
            c.NumWorkers = numLogicalCpus; 
            saveProfile(c);
            parpool(c,numLogicalCpus);%Creamos un parallel pool de tantos cores tengamos (incluido logicos)
        end
        %fin parallel
		ncols=size(rs(1),1);
		data=cell(nrows-1,ncols);
		head=cell(1,ncols);
        %head
        currentRow=rs(1);
        for c=1:ncols
            head(1,c)={currentRow(c)};
        end
        
        if(has_par)
            block=floor(nrows/numLogicalCpus);
            for rr=2:block:nrows
                upperlimit=min(block,nrows-(rr+block));
                subset=rs(rr:upperlimit);
                subout=cell(block,ncols);
                parfor r=1:size(subset,1)                    
                    currentRow=subset(r);
                    for c=1:ncols
                        if(isa(currentRow(c),'java.lang.String')==1)
                            subout{r,c}=char(currentRow(c));
                        elseif(isa(currentRow(c),'double')==1)
                                subout{r,c}=single(currentRow(c));
                            else
                                subout{r,c}=currentRow(c);
                        end
                    end        
                end
                data(rr-1:(rr-1+block)-1,:)=subout;
            end
            p = gcp;
            delete(p)
        else
            for r=2:nrows
                currentRow=rs(r);
                for c=1:ncols
                    if(isa(currentRow(c),'java.lang.String')==1)
                        data{r-1,c}=char(currentRow(c));
                    elseif(isa(currentRow(c),'double')==1)
                                data{r-1,c}=single(currentRow(c));
                            else
                                data{r-1,c}=currentRow(c);
                    end
                end        
            end
        end
		data=cell2table(data);
		data.Properties.VariableNames=head;
		else
		data=cell2table(cell(0,0));
    end
    return;
end
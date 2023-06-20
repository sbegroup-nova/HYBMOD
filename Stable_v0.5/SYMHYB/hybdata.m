function proj=hybdata(file,projname)

    fclose('all');
    id=fopen(file);
    correctreac=0;
    correctl=1;
    while 1
        
        line=fgetl(id);
        
        if strcmp(line,'end')==true
            
         break
         
        end
        
        if correctreac>0
            if correctl == 3
                if ~contains(line,".Y=")
                    pos1=strfind(line,").");
                    pos2=strfind(line,"=");
                    line=erase(line,line(pos1+2:pos2-1));
                    line=insertBefore(line,'=','Y');
                    line=strrep(line,'"',"");
                    line=strrep(line,"'",'"');
                end
                correctl = 0;
            end
            correctreac=correctreac-1;
            correctl= correctl+1;
        end
        eval(line);
        
        if contains(line,"nreaction")
            correctreac=3*eval(strcat(projname,'.nreaction'));
        end
        
    end
    
    proj=eval(projname);
end
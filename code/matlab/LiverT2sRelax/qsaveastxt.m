function qsaveastxt(filename,a)
fid=fopen([filename,'.txt'],'wt'); %写入的文件，各函数后面有说明
[m,n]=size(a);
for i=1:1:m    
    for j=1:1:n       
        if j==n            
            fprintf(fid,'%g\n',a(i,j));            
        else            
            fprintf(fid,'%g\t',a(i,j));
        end  
    end   
end
fclose(fid);
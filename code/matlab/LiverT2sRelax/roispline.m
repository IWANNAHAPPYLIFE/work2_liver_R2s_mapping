function [mask, points,ctrlpoints]=roispline(I,axis)

% function [mask,perimeter,area]=roispline(I,str,tension)
%
% INPUT :
% - I       : Grayscale or color image
% - kind    : String specifying the kind of spline ('natural' for natural 
%             cubic spline, 'cardinal' for cardinal cubic spline). 
%             DEFAULT = 'natural'
% - tension : Tension parameter between 0 and 1 for cardinal spline.
%             DEFAULT = 0
%
% OUTPUT :
% - mask    : Binary mask of segmented ROI
% global cor;

% warning off
siz=size(I);
% title('Click right button or close curve clicking near first point');
hold on;

flag_lineexist = 0;

% initializes number of points for each step
% npoints=sqrt(siz(1)*siz(2))*.1;
npoints = 20;

mindist=2;

bottone=1;
i=0;
flag=1;
points=[];
   while flag                   
            i=i+1;
            [x,y,bottone]=myginput(1);            
            if bottone ~= 1
                if i>3
                    flag=0;
                else if i>1
                     delete(h);                     
                     i=0;
                    end                    
                    break;
                end
            end
            xylimit = axis;
            if x<xylimit(1) | x>xylimit(2)| y<xylimit(3) | y>xylimit(4)
                if i>3;
                    flag=0;
                else
                    if i>1;
                        delete(h);
                        if ishandle(h_line)
                            delete(h_line);
                        end
                        if ishandle(h_ctrpts)
                            delete(h_ctrpts);
                        end
                    end
                    
%                     msgbox('pls put the mouse down in the image','r'); 
                    break;
                end                              
            end  

            if i<3 & flag
               cor(1,i) = x;
               cor(2,i) = y;
               h(i) = plot(cor(1,i),cor(2,i),'y.');
            else if i<4 & flag
                    delete(h);
                    cor(1,i) = x;
                    cor(2,i) = y;
                    cor(:,i+1) = cor(:,1);
                else if flag
                    dist = zeros(1,i);
                    dist = sqrt ((x-cor(1,:)).^2 + (y-cor(2,:)).^2);
                    idx_mindist = find(dist == min(dist) );
                    if min(dist) < mindist
                        cor(1,idx_mindist) = x;
                        cor(2,idx_mindist) = y;
                        i = i-1;
                    else
                        if idx_mindist(1)<2
                            if DistBtw4Pts(cor(:,i-1),cor(:,1),[x;y],cor(:,2)) < ...
                            DistBtw4Pts(cor(:,i-1),[x;y],cor(:,1),cor(:,2)) 
                            idx_pos4newpt = 2;  
                            else
                            idx_pos4newpt = i;  
                            end
                        else
                            if DistBtw4Pts(cor(:,idx_mindist-1),[x;y],cor(:,idx_mindist),cor(:,idx_mindist+1)) < ...
                                DistBtw4Pts(cor(:,idx_mindist-1),cor(:,idx_mindist),[x;y],cor(:,idx_mindist+1)) 
                                idx_pos4newpt = idx_mindist;
                            else
                                idx_pos4newpt = idx_mindist+1;
                            end
                        end                    
                        cor(:,i+1) = cor(:,1);
                        for ii = i:-1:idx_pos4newpt+1
                            cor(:,ii) = cor(:,ii-1);
                        end
                        cor(1,idx_pos4newpt) = x;
                        cor(2,idx_pos4newpt) = y; 
                    end
                    end
                end
            hold on;
            spcv = cscvn(cor);
            points = fnplt(spcv);
%             points=myfnplt(spcv,npoints*i);
                
            if (flag_lineexist)
                delete(h_line);
                delete(h_ctrpts);
            end
            h_line = line(points(1,:),points(2,:),'Color','yellow','LineWidth',1.5);
            h_ctrpts = line(cor(1,:),cor(2,:),'LineStyle','none',...
                'Marker','o','MarkerFaceColor','r','MarkerSize',1.5);
            flag_lineexist = 1;            
%             drawnow;
            end
   end

ctrlpoints(1,:) = cor(1,:);
ctrlpoints(2,:) = cor(2,:);
ctrlpoints = ctrlpoints';
% mask calculation
points=points';
if i>2
    mask=roipoly(I,points(:,1),points(:,2));
else
    mask=logical(zeros(siz(1),siz(2)));
end

%delete the line
if (flag_lineexist)
    delete(h_line);
    delete(h_ctrpts);
end
hold off;
return;


%calculate distance of a line of 4 points
function distance_4pts = DistBtw4Pts(pt1,pt2,pt3,pt4)

distance_pts1 = sqrt((pt1(1) - pt2(1)).^2 + (pt1(2) - pt2(2)).^2);
distance_pts2 = sqrt((pt2(1) - pt3(1)).^2 + (pt2(2) - pt3(2)).^2);
distance_pts3 = sqrt((pt3(1) - pt4(1)).^2 + (pt3(2) - pt4(2)).^2);
distance_4pts = distance_pts1 + distance_pts2 + distance_pts3;


% % internal functions
% 
% function [points,t] = myfnplt(f,npoints,varargin)
% 
% % interpret the input:
% symbol=''; interv=[]; linewidth=[]; jumps=0;
% for j=3:nargin
%    arg = varargin{j-1};
%    if ~isempty(arg)
%       if ischar(arg)
%          if arg(1)=='j', jumps = 1;
%          else symbol = arg;
%          end
%       else
%          [ignore,d] = size(arg);
%          if ignore~=1
% 	    error('SPLINES:FNPLT:wrongarg',['arg',num2str(j),' is incorrect.']), end
%          if d==1
%             linewidth = arg;
%          else
%             interv = arg;
%          end
%       end
%    end
% end
% 
% % generate the plotting info:
% if ~isstruct(f), f = fn2fm(f); end
% 
% % convert ND-valued to equivalent vector-valued:
% d = fnbrk(f,'dz'); if length(d)>1, f = fnchg(f,'dim',prod(d)); end
% 
% switch f.form(1:2)
% case 'st'
%    if ~isempty(interv), f = stbrk(f,interv);
%    else
%       interv = stbrk(f,'interv');
%    end
% %    npoints = 150; 
%    d = stbrk(f,'dim');
%    switch fnbrk(f,'var')
%    case 1
%       x = linspace(interv{1}(1),interv{1}(2),npoints);
%       v = stval(f,x);
%    case 2
%       x = {linspace(interv{1}(1),interv{1}(2),npoints), ...
%                     linspace(interv{2}(1),interv{2}(2),npoints)};
%       [xx,yy] = ndgrid(x{1},x{2});
%       v = reshape(stval(f,[xx(:),yy(:)].'),[d,size(xx)]);
%    otherwise
%       error('SPLINES:FNPLT:atmostbivar', ...
%             'Cannot handle st functions with more than 2 variables.')
%    end
% otherwise
%    if ~strcmp(f.form([1 2]),'pp')
%       givenform = f.form; f = fn2fm(f,'pp'); basicint = ppbrk(f,'interval');
%    end
%    
%    if ~isempty(interv), f = ppbrk(f,interv); end
%       
%    [breaks,coefs,l,k,d] = ppbrk(f);
%    if iscell(breaks)
%       m = length(breaks);
%       for i=m:-1:3
%          x{i} = (breaks{i}(1)+breaks{i}(end))/2;
%       end
% %       npoints = 150;
%       ii = [1]; if m>1, ii = [2 1]; end
%       for i=ii
%          x{i}= linspace(breaks{i}(1),breaks{i}(end),npoints);
%       end
%       v = ppual(f,x);
%       if exist('basicint','var') 
%                          % we converted from B-form to ppform, hence must now
%                          % enforce the basic interval for the underlying spline.
%          for i=ii
%             temp = find(x{i}<basicint{i}(1)|x{i}>basicint{i}(2));
%             if d==1
%                if ~isempty(temp), v(:,temp,:) = 0; end
%                v = permute(v,[2,1]);
%             else
%                if ~isempty(temp), v(:,:,temp,:) = 0; end
%                v = permute(v,[1,3,2]);
%             end
%          end
%       end
%    else     % we are dealing with a univariate spline
% %       npoints = 500;
%       x = [breaks(2:l) linspace(breaks(1),breaks(l+1),npoints)];
%       v = ppual(f,x); 
%       if l>1 % make sure of proper treatment at jumps if so required
%          if jumps
%             tx = breaks(2:l); temp = repmat(NaN, d,l-1);
%          else
%             tx = []; temp = zeros(d,0);
%          end
%          x = [breaks(2:l) tx x]; 
%          v = [ppual(f,breaks(2:l),'left') temp v];
%       end
%       [x,inx] = sort(x); v = v(:,inx);
%    
%       if exist('basicint','var') 
%                          % we converted from B-form to ppform, hence must now
%                          % enforce the basic interval for the underlying spline.
%                          % Note that only the first d components are set to zero
%                          % outside the basic interval, i.e., the (d+1)st 
%                          % component of a rational spline is left unaltered :-)
%          if jumps, extrap = repmat(NaN,d,1); else, extrap = zeros(d,1); end
%          temp = find(x<basicint(1)); ltp = length(temp);
%          if ltp
%             x = [x(temp),basicint([1 1]), x(ltp+1:end)];
%             v = [zeros(d,ltp+1),extrap,v(:,ltp+1:end)];
%          end
%          temp = find(x>basicint(2)); ltp = length(temp);
%          if ltp
%             x = [x(1:temp(1)-1),basicint([2 2]),x(temp)];
%             v = [v(:,1:temp(1)-1),extrap,zeros(d,ltp+1)];
%          end
%          %   temp = find(x<basicint(1)|x>basicint(2));
%          %   if ~isempty(temp), v(temp) = zeros(d,length(temp)); end
%       end
%    end
%    
%    if exist('givenform','var')&&givenform(1)=='r' 
%                                            % we are dealing with a rational fn:
%                                            % need to divide by last component
%       d = d-1;
%       sizev = size(v); sizev(1) = d;
%       % since fnval will replace any zero value of the denominator by 1,
%       % so must we here, for consistency:
%       v(d+1,find(v(d+1,:)==0)) = 1;
%       v = reshape(v(1:d,:)./repmat(v(d+1,:),d,1),sizev);
%    end 
% end
% 
% %  use the plotting info, to plot or else to output:
% if nargout==0
%    if iscell(x)
%       switch d
%       case 1
%          [yy,xx] = meshgrid(x{2},x{1});
%          surf(xx,yy,reshape(v,length(x{1}),length(x{2})))
%       case 2
%          v = squeeze(v); roughp = 1+(npoints-1)/5;
%          vv = reshape(cat(1,...
%               permute(v(:,1:5:npoints,:),[3,2,1]),...
%               repmat(NaN,[1,roughp,2]),...
%               permute(v(:,:,1:5:npoints),[2,3,1]),...
%               repmat(NaN,[1,roughp,2])), ...
%                     [2*roughp*(npoints+1),2]);
%          plot(vv(:,1),vv(:,2))
%       case 3
%          v = permute(reshape(v,[3,length(x{1}),length(x{2})]),[2 3 1]);
%          surf(v(:,:,1),v(:,:,2),v(:,:,3))
%       otherwise
%       end
%    else
%       if isempty(symbol), symbol = '-'; end
%       if isempty(linewidth), linewidth = 2; end
%       switch d
%       case 1, plot(x,v,symbol,'linew',linewidth)
%       case 2, plot(v(1,:),v(2,:),symbol,'linew',linewidth)
%       otherwise
%          plot3(v(1,:),v(2,:),v(3,:),symbol,'linew',linewidth)
%       end
%    end
% else
%    if iscell(x)
%       switch d
%       case 1
%          [yy,xx] = meshgrid(x{2},x{1});
%          points = {xx,yy,reshape(v,length(x{1}),length(x{2}))};
%       case 2
%          [yy,xx] = meshgrid(x{2},x{1});
%          points = {xx,yy,reshape(v,[2,length(x{1}),length(x{2})])};
%       case 3
%          points = {squeeze(v(1,:)),squeeze(v(2,:)),squeeze(v(3,:))};
%          t = {x{1:2}};
%       otherwise
%       end
%    else
%       if d==1, points = [x;v];
%       else t = x; points = v([1:min([d,3])],:); end
%    end
% end








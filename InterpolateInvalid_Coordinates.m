function [result] = InterpolateInvalid_Coordinates(variable,sr)
% Removes any small gaps using linear interpolation
% Marks any outliers (> 6 SD) and gaps (regions with zeros) in the data as
% NaN if longer than 297miliseconds; if shorter: linear interpolation
% input sampling rate per second

variable = reshape(variable,1,length(variable)); % make sure vector is horizontal
datacopy.xf = variable;

sint = 1./sr;

% Find large gaps in data (because of zeros or outliers) and substitute for NaN
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

m= mean(datacopy.xf);
s= std(datacopy.xf);

logicdata= datacopy.xf==0 | (abs(datacopy.xf-m))>6*s; % find positions of zeros & outliers (above or below 6x stand deviation)
len= length(logicdata);
totc=0;
c= 0; % will keep track of number of zeros in a gap
for k= 1:len
    if (logicdata(k)==1) && (datacopy.xf(k)==0) % if there is a zero and it has not been replaced by 'NaN' yet
        while logicdata(k)==1
            c= c+1;
            k=k+1;
            if k==len+1
                break
            else
            end
        end
        if c>9
            range=[k-c k-1]; 
            datacopy.xf(1,k-c:k-1)= NaN; % do not use the large gaps with no position info
            totc=totc+c; % keep track of the total time that position info cannot be used
        end
        c=0; % reset the count
    else
    end 
end
display('Total time -in min- lost because there were too many consecutive invalid points in the position data:'); % the number of times this message is displayed will = # of gaps too large to be used
totc= ((totc-1)*sint)./60 % total time 'lost' because the pos info cannot be used (too many consecutive zeros/outliers)
  
% Interpolate the small gaps
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

logicdata2= find(logicdata==1); % get positions where there is zero or outlier
all= datacopy.xf(logicdata2); % get data in those positions
logicdata3= isnan(all); % determine which ones are large gaps of zeros/outliers (they've been substituted for NaN)
unknownx= logicdata2(logicdata3==0); % take the values in the small gaps (these are the x values for which we want to calculate y values in the interpolation)

  
knownx = find(logicdata==0); % known x values -those that are not zero or outliers-
knowny = datacopy.xf(knownx); % corresponding y values

unknowny = interp1(knownx,knowny,unknownx);

datacopy.xf(unknownx)=unknowny;
result= datacopy.xf;



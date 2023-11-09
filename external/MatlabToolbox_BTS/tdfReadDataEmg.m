
function [startTime,frequency,emgMap,labels,emgData] = tdfReadDataEmg (filename)
%TDFREADDATAEMG   Read EMG Data from TDF-file.
%   [STARTTIME,FREQUENCY,EMGMAP,LABELS,EMGDATA] = TDFREADDATAEMG (FILENAME) retrieves
%   the EMG sampling start time ([s]) and sampling rate ([Hz]), 
%   the correspondance map between EMG logical channels and physical channels 
%   and the EMG data stored in FILENAME.
%   EMGMAP is a [nSignals,1] array such that EMGMAP(logical channel) == physical channel. 
%   LABELS is a matrix with the text strings of the EMG channels as rows.
%   EMGDATA is a [nSignals,nSamples] array such that EMGDATA(s,:) stores 
%   the samples of the signal s. 
%
%   See also TDFWRITEDATAEMG
%
%   Copyright (c) 2000 by BTS S.p.A.
%   $Revision: 7 $ $Date: 14/07/06 11.42 $

emgMap=[]; emgData=[];
globalStartTime=0;
frequency=0;

[fid,tdfBlockEntries] = tdfFileOpen (filename);   % open the file
if fid == -1
   return
end

tdfDataEmgBlockId = 11;
blockIdx = 0;
for e = 1 : length (tdfBlockEntries)
   if (tdfDataEmgBlockId == tdfBlockEntries(e).Type) & (0 ~= tdfBlockEntries(e).Format)
      blockIdx = e;
      break
   end
end
if blockIdx == 0
   disp ('Emg Data not found in the file specified.')
   tdfFileClose (fid);
   return
end

if (-1 == fseek (fid,tdfBlockEntries(blockIdx).Offset,'bof'))
   disp ('Error: the file specified is corrupted.')
   tdfFileClose (fid);
   return
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read header information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

nSignals  = fread (fid,1,'int32');
frequency = fread (fid,1,'int32');
startTime = fread (fid,1,'float32');
nSamples = fread (fid,1,'int32');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read emg map information
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

emgMap = fread (fid,nSignals,'int16');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% read emg data
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

labels   = char (zeros (nSignals,256));
emgData  = NaN * ones(nSignals,nSamples);

if (1 == tdfBlockEntries(blockIdx).Format)         % by track
   
  for e = 1 : nSignals
      label      = strtok (char ((fread (fid,256,'uchar'))'), char (0));
      labels (e,1:length (label)) = label;
      nSegments  = fread (fid,1,'int32');
      fseek (fid,4,'cof');
      segments   = fread (fid,[2,nSegments],'int32');
      for s = 1 : nSegments
         emgData(e,segments(1,s)+1 : (segments(1,s)+segments(2,s))) = (fread (fid,segments(2,s),'float32'))';
      end
   end
   
elseif (2 == tdfBlockEntries(blockIdx).Format)     % by frame
   
   for e = 1 : nSignals
      label = strtok (char ((fread (fid,256,'uchar'))'), char (0));
      labels (e,1:length (label)) = label;
   end
   for frm = 1 : nSamples
     for sign = 1 : nSignals 
       emgData(sign, frm) = (fread (fid,1,'float32'))';
     end
   end
   
end

tdfFileClose (fid);                               % close the file

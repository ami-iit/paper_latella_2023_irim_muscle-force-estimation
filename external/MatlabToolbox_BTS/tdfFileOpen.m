%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%
%

function [fid,tdfBlockEntries] = tdfFileOpen (tdfFilename)

tdfBlockEntries = struct ( ...
   'Type',{}, ...
   'Format',{}, ...
   'Offset',{}, ...
   'Size',{});

tdfSignature = '41604B82CA8411D3ACB60060080C6816';

[fid,msg] = fopen (tdfFilename,'r');                  % open the file
if fid == -1
   disp(msg)
   return
end
ID = dec2hex (fread (fid,1,'uint32'),8);              % check the ID
for i = 1:3
   ID = strcat (ID,dec2hex (fread (fid,1,'uint32'),8));
end
if ~strcmp (ID,tdfSignature)
   disp ('Error: invalid binary file.')
   fclose (fid);
   fid = -1;
   return
end

version = fread (fid,1,'uint32');
nEntries = fread (fid,1,'int32');

if (nEntries <= 0)
   disp ('The file specified contains no data.');
   fclose (fid);
   fid = -1;
   return
end

tdfVoidBlockEntries = tdfBlockEntries;
tdfBlockEntries = struct ( ...
   'Type',cell (1,nEntries), ...
   'Format',cell (1,nEntries), ...
   'Offset',cell (1,nEntries), ...
   'Size',cell (1,nEntries));

nextEntryOffset = 40;
for e = 1:nEntries
   if (-1 == fseek (fid,nextEntryOffset,'cof'))
      disp ('Error: the file specified is corrupted.');
      fclose (fid);
      fid = -1;
      tdfBlockEntries = tdfVoidBlockEntries;
      return
   end
   tdfBlockEntries(e).Type = fread (fid,1,'uint32');
   tdfBlockEntries(e).Format = fread (fid,1,'uint32');
   tdfBlockEntries(e).Offset = fread (fid,1,'int32');
   tdfBlockEntries(e).Size = fread (fid,1,'int32');
   nextEntryOffset = 16+256;
end


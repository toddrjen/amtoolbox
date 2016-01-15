function data = data_baumgartner2013(varargin)
%DATA_BAUMGARTNER2013  Data from Baumgartner et al. (2013)
%   Usage: data = data_baumgartner2013(flag)
%
%   `data_baumgartner2013(flag)` returns data of the table or
%   the pool of listener-specific models from Baumgartner et al. (2013)
%   describing a model for sound localization in sagittal planes (SPs)
%   on the basis of listener-specific directional transfer functions (DTFs).
%
%   The flag may be one of:
%
%     'tab1'  Calibration data for listener pool listed in Table 1. The
%             output contains the following fields: *id*, *u*, *goupell10* and
%             *walder10*
%
%     'pool'  DTFs and calibration data of the pool. The output contains the
%             following fields: *id*, *u*, *goupell10*, *walder10*, *fs*
%             and *Obj*.
%
%     'ari'   OBSOLETE. DTFs and calibration data of the pool. The output contains the
%             following fields: *id*, *u*, *goupell10*, *walder10*, *dtfs*,
%             *fs* and *pos*. 
%
%   The fields in the output contains the following information
%
%     .id         listener ID
%
%     .u          listener-specific uncertainty
%
%     .goupell10  boolean flag indicating whether listener
%                 participated in Goupell et al. (2010)
%
%     .walder10   boolean flag indicating whether listener
%                 participated in Walder (2010)
%
%     .dtfs       OBSOLETE. matrix containing DTFs.
%                 Dimensions: time, position, channel
%                 (more details see doc: HRTF format)
%
%     .fs         sampling rate of impulse responses
%
%     .pos        OBSOLETE. source-position matrix referring to
%                 2nd dimension of hM and formated acc.
%                 to meta.pos (ARI format).
%                 6th col: lateral angle
%                 7th col: polar angle
%
%     .Obj        DTF data in SOFA Format
%
%   Requirements: 
%   -------------
%
%   1) SOFA API from http://sourceforge.net/projects/sofacoustics for Matlab (in e.g. thirdparty/SOFA)
% 
%   2) Data in hrtf/baumgartner2013
%
%   Examples:
%   ---------
%
%   To get calibration data of pool of listener-specific models, use::
%
%     data_baumgartner2013('tab1');
%
%   To get all listener-specific data of the pool, use::
%
%     data_baumgartner2013('pool');
%
%   See also: baumgartner2013, exp_baumgartner2013
%
%   References: baumgartner2013assessment baumgartner2012modelling

% AUTHOR : Robert Baumgartner

%% ------ Check input options --------------------------------------------

% Define input flags
definput.flags.type = {'missingflag','tab1','pool'};
definput.flags.HRTFformat = {'sofa','ari'};
definput.import={'amtcache'};


% Parse input options
[flags,keyvals]  = ltfatarghelper({},definput,varargin);

if flags.do_missingflag
  flagnames=[sprintf('%s, ',definput.flags.type{2:end-2}),...
             sprintf('%s or %s',definput.flags.type{end-1},definput.flags.type{end})];
  error('%s: You must specify one of the following flags: %s.',upper(mfilename),flagnames);
end;


%% Table 1 (model calibration)
if flags.do_tab1 || flags.do_pool

    listeners={ ...
         'NH12'   1.6   true  true;  ...
         'NH15'   2.0   true  true;  ...
         'NH21'   1.8   true  false;  ...
         'NH22'   2.0   true  false;  ...
         'NH33'   2.3   true  false;  ...
         'NH39'   2.3   true  true;  ...
         'NH41'   3.0   true  false;  ...
         'NH42'   1.8   true  false;  ...
         'NH43'   1.9   false true;  ...
         'NH46'   1.8   false true;  ...
         'NH55'   2.0   false true;  ...
         'NH58'   1.4   false true;  ...
         'NH62'   2.2   false true;  ...
         'NH64'   2.1   false true;  ...
         'NH68'   2.1   false true;  ...
         'NH71'   2.1   false true;  ...
         'NH72'   2.2   false true;  ...
         };

    f={'id', 'u', 'goupell10', 'walder10'};
    data=cell2struct(listeners,f,2);

end

%% Listener pool (listener-specific SP-DTFs)
if flags.do_pool % load also DTFs of SPs

  % sort acc. to ascending exp. PE
  data = data([12,1,10,3,14,16,8,9,4,2,7,15,17,5,11,6,13]);

  if flags.do_ari
    error('Obsolete format of HRTFs. Data format not supported anymore');
%     hpath = which('hrtfinit');  % find local path of hrtf repository
%     hpath = hpath(1:end-10);
%     sl = hpath(end);            % slash sign (OS dependent)
% 
%     if exist([hpath 'hrtf_M_baumgartner2013'],'dir') ~= 7
%       fprintf([' Sorry! Before you can run this script, you have to download the HRTF Database from \n http://www.kfs.oeaw.ac.at/hrtf/database/amt/baumgartner2013.zip , \n unzip it, and move it into your HRTF repository \n ' hpath ' .\n' ' Then, press any key to quit pausing. \n'])
%       pause
%     end
% 
%     hpath = [hpath sl 'hrtf_M_baumgartner2013' sl];
% 
%     for ii = 1:length(data)
% 
%       load([hpath 'hrtf_M_baumgartner2013 ' data(ii).id])
%       data(ii).fs = stimPar.SamplingRate;
%       data(ii).pos = meta.pos;
%       data(ii).dtfs = double(hM);
% 
%     end
  end

  if flags.do_sofa

    for ii = 1:length(data)
      fn=['ARI_' data(ii).id '_hrtf_M_dtf 256.sofa'];
      data(ii).Obj = SOFAload(fullfile(SOFAdbPath,'baumgartner2013',fn));
      data(ii).fs = data(ii).Obj.Data.SamplingRate;
    end
  end

end



end
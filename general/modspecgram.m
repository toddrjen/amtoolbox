function modspecgram(f,fs,varargin)
%MODSPECGRAM  Modulation spectrogram
%   Usage:  modspecgram(f,fs);
%           modspecgram(f,fs,...);
%
%   `modspecgram(f,fs)` plot the modulation spectogram of the signal *f* sampled
%   at a sampling frequency of *fs* Hz.
%
%   `C=modspecgram(f,fs, ... )` returns the image to be displayed as a matrix. Use
%   this in conjunction with `imwrite` etc.
%
%   The function takes the following additional arguments
%
%     'win',g      Use the window *g*. See the help on `gabwin` for some
%                  possiblities. Default is to use a Gaussian window
%                  controlled by the `'thr'` or `'wlen'` parameters listed below.
%   
%     'tfr',v      Set the ratio of frequency resolution to time resolution.
%                  A value $v=1$ is the default. Setting $v>1$ will give better
%                  frequency resolution at the expense of a worse time
%                  resolution. A value of $0<v<1$ will do the opposite.
%   
%     'wlen',s     Window length. Specifies the length of the window
%                  measured in samples. See help of PGAUSS on the exact
%                  details of the window length.
%   
%     'image'      Use `imagesc` to display the spectrogram. This is the
%                  default.
%   
%     'clim',clim  Use a colormap ranging from `clim(1)` to `clim(2)`. These
%                  values are passed to `imagesc`. See the help on `imagesc`.
%   
%     'dynrange',r  Use a colormap in the interval [chigh-r,chigh], where
%                   chigh is the highest value in the plot.
%   
%     'fmax',fmax  Display *fmax* as the highest frequency.
%   
%     'mfmax',mfmax  
%                  Display *mfmax* as the highest modulation frequency.
%   
%     'xres',xres  Approximate number of pixels along x-axis / time.
%   
%     'yres',yres  Approximate number of pixels along y-axis / frequency
%   
%     'contour'    Do a contour plot to display the spectrogram.
%            
%     'surf'       Do a surf plot to display the spectrogram.
%   
%     'mesh'       Do a mesh plot to display the spectrogram.
%   
%     'colorbar'   Display the colorbar. This is the default.
%   
%     'nocolorbar'  Do not display the colorbar.
%   
%     'interp'     Interpolate the image to get the desired
%                  x-resolution. Turn this off by using 'nointerp'
%
%   The parameters `'dynrange'` and `'mfmax'` may be speficied first on the
%   argument line, in that order.
%
%   See also:  audspecgram
  
if nargin<2
  error('%s: Too few input parameters.',upper(mfilename));
end;


% Define initial value for flags and key/value pairs.
definput.flags.wlen={'nowlen','wlen'};
definput.flags.plottype={'image','contour','mesh','pcolor'};

definput.flags.clim={'noclim','clim'};
definput.flags.log={'db','lin'};
definput.flags.colorbar={'colorbar','nocolorbar'};
definput.flags.interp={'interp','nointerp'};

definput.keyvals.tfr=1;
definput.keyvals.win=[];
definput.keyvals.wlen=0;
definput.keyvals.thr=0;
definput.keyvals.clim=[0,1];
definput.keyvals.climsym=1;
definput.keyvals.fmax=[];
definput.keyvals.mfmax=[];
definput.keyvals.dynrange=[];
definput.keyvals.xres=800;
definput.keyvals.yres=600;

[flags,kv]=ltfatarghelper({'dynrange','mfmax'},definput,varargin,mfilename);

  
l = (length(f)-1)/fs;   % Length of the signal (in seconds)

% Downsample
if ~isempty(kv.fmax)
  resamp=kv.fmax*2/fs;

  f=fftresample(f,round(length(f)*resamp));
  fs=kv.fmax*2;
end;

M=kv.yres*2;

if ~isempty(kv.mfmax)
  % Choose "a" such that the subband sampling rate mathes the desired
  % mfmax.
  a=max(round((fs/2)/kv.mfmax),1);
else
  % Choose "a" such that the number of pixels is matched.
  a=max(round(length(f)/2/kv.xres),1);
end;

% Set an explicit window length, if this was specified.
if flags.do_wlen
  kv.tfr=kv.wlen^2/L;
end;

if isempty(kv.win)
  g={'gauss',kv.tfr};  
end;

% Discrete Gabor transform
fdgt = dgtreal(f,g,a,M);
L=size(fdgt,2)*a/fs;    % Length of the transform, in seconds

nwin = size(fdgt,2);    % Number of time windows
nfbin = size(fdgt,1);   % Number of frequency bins

% Do fft along second dimension (time). Normalize so different values of
% "a" does not change the magnitude.
gram=fftreal(abs(fdgt),[],2);

% Go to dB
gram = 20*log10(abs(gram));

if flags.do_interp
  gram=dctresample(gram,kv.xres,2);
end;

subbandfs=fs/a;
mfmax=subbandfs/2;
mfbins=size(gram,2);

% 'dynrange' parameter is handled by thresholding the coefficients.
if ~isempty(kv.dynrange)
  maxclim=max(gram(:));
  gram(gram<maxclim-kv.dynrange)=maxclim-kv.dynrange;
end;

%% Plotting the modulation spectrum

% Frequency axis
yr = linspace(0,fs/2,nfbin);
xr = linspace(0,mfmax,mfbins);

switch(flags.plottype)
  case 'image'
    if flags.do_clim
      imagesc(xr,yr,gram,kv.clim);
    else
      imagesc(xr,yr,gram);
    end;
  case 'contour'
    contour(xr,yr,gram);
  case 'surf'
    surf(xr,yr,gram);
  case 'pcolor'
    pcolor(xr,yr,gram);
end;

if flags.do_colorbar
  colorbar;
end;

axis('xy');

title('Temporal modulation spectrogram')
xlabel('Modulation Frequency (Hz)')
ylabel('Frequency (Hz)')


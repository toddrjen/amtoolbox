function [b,a,delay]=gammatone(fc,fs,varargin)
%GAMMATONE  Gammatone filter coefficients
%   Usage: [b,a] = gammatone(fc,fs,n,betamul);
%          [b,a] = gammatone(fc,fs,n);
%          [b,a] = gammatone(fc,fs);
%
%   Input parameters:
%      fc    : center frequency in Hz.
%      fs    : sampling rate in Hz.
%      n     :  filter order.
%      beta  :  bandwidth of the filter.
%
%   Output parameters:
%      b     :  nominator coefficients.
%      a     :  denominator coefficients.
%
%   `gammatone(fc,fs,n,betamul)` computes the filter coefficients of a
%   digital gammatone filter with center frequency *fc*, order *n*, sampling
%   rate *fs* and bandwith determined by *betamul*. The bandwidth *beta* of
%   each filter is determined as *betamul* times `audfiltbw` of the center
%   frequency of corresponding filter.
%
%   By default, the returned filter coefficients comes from the all-pole
%   approximation described in Lyon (1997). The filters are normalized to
%   have a 0 dB attenuation at the center frequency (another way of
%   stating this is that their impulse responses will have unit area).
%
%   `gammatone(fc,fs,n)` will do the same but choose a filter bandwidth
%   according to Glasberg and Moore (1990).
%
%   `gammatone(fc,fs)` will do as above for a 4th order filter.
%
%   If *fc* is a vector, each entry of *fc* is considered as one center
%   frequency, and the corresponding coefficients are returned as row
%   vectors in the output.
%
%   The inpulse response of the gammatone filter is given by:
%
%   ..   g(t) = a*t^(n-1)*cos(2*pi*fc*t)*exp(-2*pi*beta*t)
%
%   .. math::  g(t) = at^{n-1}cos(2\pi\cdot fc\cdot t)e^{-2\pi \beta \cdot t}
%
%   `gammatone` takes the following flags at the end of the line of input
%   arguments:
%
%     'allpole'  Compute the all-pole approximation of Gammatone
%                filters by Lyon. This is the default
%
%     'classic'  Compute the classical mixed pole-zero approximation of 
%                gammatone filters.
%  
%     'complex'  Generate filter coefficients corresponding to a
%                complex valued filterbank modulated by exponential
%                functions. This is useful for envelope extration
%                purposes.
%
%     'real'     Generate real-valued filters.
%
%     'casualphase'  This makes the phase of each filter start at zero.
%                    This is the default.
%
%     'peakphase'    This makes the phase of each filter be zero when the
%                    envelope of the impulse response of the filter peaks.
%
%   To create the filter coefficients of a 1-erb spaced filter bank using
%   gammatone filters use the following construction::
%
%     [b,a] = gammatone(erbspacebw(flow,fhigh),fs,'complex');
%
%   To apply the (complex valued) filters to an input signal, use
%   |filterbankz|_::
%
%     outsig = 2*real(ufilterbankz(b,a,insig));
%  
%   References: aertsen1980strI patterson1988efficient lyon1997all
  
%   AUTHOR : Stephan Ewert, Peter L. Soendergaard

% ------ Checking of input parameters ---------
  
  
% TODO: The phases of the filters all start at zero. This means that the
% real value of the impulse response of the filters does peak at the same
% time as the absolute value does. Include option to shift the phases so
% all filters have a distinct peak.

if nargin<2
  error('%s: Too few input arguments.',upper(mfilename));
end;

if ~isnumeric(fs) || ~isscalar(fs) || fs<=0
  error('%s: fs must be a positive scalar.',upper(mfilename));
end;

if ~isnumeric(fc) || ~isvector(fc) || any(fc<0) || any(fc>fs/2)
  error(['%s: fc must be a vector of positive values that are less than half ' ...
         'the sampling rate.'],upper(mfilename));
end;

definput.keyvals.n=4;
definput.keyvals.betamul=[];
definput.flags.real={'real','complex'};
definput.flags.phase={'causalphase','peakphase'};
definput.flags.filtertype={'allpole','classic'};

[flags,keyvals,n,betamul]  = ltfatarghelper({'n','betamul'},definput,varargin);

if ~isnumeric(n) || ~isscalar(n) || n<=0 || fix(n)~=n
  error('%s: n must be a positive, integer scalar.',upper(mfilename));
end;

if isempty(betamul)
  % This formula comes from patterson1988efficient, but it is easier to
  % find in the Hohmann paper.
  betamul = (factorial(n-1))^2/(pi*factorial(2*n-2)*2^(-(2*n-2)));

else
  if ~isnumeric(betamul) || ~isscalar(betamul) || betamul<=0
    error('%s: beta must be a positive scalar.',upper(mfilename));
  end;
end;


% ------ Computation --------------------------

% ourbeta is used in order not to mask the beta function.  
ourbeta = betamul*audfiltbw(fc);

nchannels = length(fc);

if flags.do_allpole

  if flags.do_real

    warning(['FIXME: The real-valued allpole filters are not scaled ' ...
             'correctly.']);
    
    
    b=zeros(nchannels,1);
    a=zeros(nchannels,2*n+1);
        
    % This is when the function peaks.
    delay = 3./(2*pi*ourbeta);

    for ii = 1:nchannels
      % convert to radians
      theta = 2*pi*fc(ii)/fs;
      phi   = 2*pi*ourbeta(ii)/fs;

      alpha = -exp(-phi)*cos(theta);
      
      b1 = 2*alpha;
      b2 = exp(-2*phi);
      a0 = abs( (1+b1*cos(theta)-1i*b1*sin(theta)+b2*cos(2*theta)-1i*b2*sin(2*theta)) / (1+alpha*cos(theta)-1i*alpha*sin(theta))  );
      
      % Compute the position of the pole
      atilde = exp(-phi - 1i*theta);
      
      % Repeat the pole n times, and expand the polynomial
      a2=poly([atilde*ones(1,n),conj(atilde)*ones(1,n)]);

      % Scale to get 0 dB attenuation, FIXME: Does not work, works only
      % for fc=fs/4
      b2=a0^n;
      
      if flags.do_peakphase
        b2=b2*exp(2*pi*1i*fc(ii)*delay(ii));
      end;
      
      % Place the result (a row vector) in the output matrices.
      b(ii,:)=b2;
      a(ii,:)=a2;
      
    end;

  end;      
  
  if flags.do_complex

    b=zeros(nchannels,1);
    a=zeros(nchannels,n+1);
        
    % This is when the function peaks.
    delay = 3./(2*pi*ourbeta);

    for ii = 1:nchannels
      % convert to radians
      theta = 2*pi*fc(ii)/fs;
      phi   = 2*pi*ourbeta(ii)/fs;
      
      % Compute the position of the pole
      atilde = exp(-2*pi*ourbeta(ii)/fs - 1i*2*pi*fc(ii)/fs);
      
      % Repeat the pole n times, and expand the polynomial
      a2=poly(atilde*ones(1,n));
      
      btmp=1-exp(-2*pi*ourbeta(ii)/fs);
      b2=btmp.^n;
      
      if flags.do_peakphase
        b2=b2*exp(2*pi*1i*fc(ii)*delay(ii));
      end;
      
      % Place the result (a row vector) in the output matrices.
      b(ii,:)=b2;
      a(ii,:)=a2;
      
    end;
    
  end;
  
else

  if flags.do_real
    b=zeros(nchannels,n+1);
    a=zeros(nchannels,2*n+1);
        
    % This is when the function peaks.
    delay = 3./(2*pi*ourbeta);
    
    for ii = 1:nchannels      
      % convert to radians
      theta = 2*pi*fc(ii)/fs;
      phi   = 2*pi*ourbeta(ii)/fs;

      alpha = -exp(-phi)*cos(theta);
      
      b1 = 2*alpha;
      b2 = exp(-2*phi);
      a0 = abs( (1+b1*cos(theta)-1i*b1*sin(theta)+b2*cos(2*theta)-1i*b2*sin(2*theta)) / (1+alpha*cos(theta)-1i*alpha*sin(theta))  );
      
      % Compute the position of the pole
      atilde = exp(-phi-1i*theta);
      
      % Repeat the conjugate pair n times, and expand the polynomial
      a2 = poly([atilde*ones(1,n),conj(atilde)*ones(1,n)]);
      
      % Compute the position of the zero, just the real value of the pole
      btilde = real(atilde);
      
      % Repeat the zero n times, and expand the polynomial
      b2 = poly(btilde*ones(1,n));
      
      % Scale to get 0 dB attenuation
      b2=b2*(a0^n);
      
      if flags.do_peakphase
        b2=b2*exp(2*pi*1i*fc(ii)*delay(ii));
      end;
      
      % Place the result (a row vector) in the output matrices.
      b(ii,:)=b2;
      a(ii,:)=a2;
      
    end;
  end;
  
  
  if flags.do_complex

    warning(['FIXME: The complex-valued mixed pole-zero filters are not scaled ' ...
             'correctly.']);

    b=zeros(nchannels,n+1);
    a=zeros(nchannels,n+1);
    
    
    % This is when the function peaks.
    delay = 3./(2*pi*ourbeta);

    for ii = 1:nchannels
      % convert to radians
      theta = 2*pi*fc(ii)/fs;
      phi   = 2*pi*ourbeta(ii)/fs;

      alpha = -exp(-phi)*cos(theta);
      b1 = 2*alpha;
      b2 = exp(-2*phi);
      a0 = abs( (1+b1*cos(theta)-1i*b1*sin(theta)+b2*cos(2*theta)-1i*b2*sin(2*theta)) / (1+alpha*cos(theta)-1i*alpha*sin(theta))  );
      
      % Compute the position of the pole
      atilde = exp(-2*pi*ourbeta(ii)/fs - 1i*2*pi*fc(ii)/fs);
      
      % Repeat the pole n times, and expand the polynomial
      a2=poly(atilde*ones(1,n));

      % Compute the position of the zero, just the real value of the pole
      btilde = real(atilde);
      
      % Repeat the zero n times, and expand the polynomial
      b2 = poly(btilde*ones(1,n));

      % Scale to get 0 dB attenuation
      b2=b2*(a0^n);

      if flags.do_peakphase
        b2=b2*exp(2*pi*1i*fc(ii)*delay(ii));
      end;
      
      % Place the result (a row vector) in the output matrices.
      b(ii,:)=b2;
      a(ii,:)=a2;
  
    end;  
  
  end;

end;


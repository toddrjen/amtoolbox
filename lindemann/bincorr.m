function crosscorr = bincorr(insig,w_f,c_s,fs)
%BINCORR Cross-correlation between two input signals
%   Usage: crosscorr = bincorr(insig,w_f,c_s,fs)
%
%	Input parameters:
%       insig      - signal with t x nfcs x 2 (right, left channel)
%       w_f        - monaural sensitivity at the end of the delay line, 
%                    0 <= w_f < 1
%       c_s        - constant inhibition factor, 0 <= c_s <= 1 
%                    (0.0 = no inhibition)
%       fs         - sampling rate
%
%   Output parameters:
%       crosscorr  - output matrix containing the correlations
%                    (n x m x amplitude), where length(n) = length(t)/fs
%
%   BINCORR(insig,w_f,c_s,fs) is an implementation of the cross-correlation
%   algorithm to simulate a binaural delay line.
%
%   The cross-correlation is calculated using:
%
%C              t
%C CC(tau,t) = int R(l-tau/2) * L(k+tau/2) exp(-(t-k)/T) dk
%C            -inf
%
%   where T denotes an integration time constant and R, L the right and 
%   left input signal.
%
%R  lindemann1986a lindemann1986b
%
% see also: lindemann
%

% AUTHOR: Hagen Wierstorf

%
% --- Used abbreviations ---
% 
% l,L       - left signal
% r,R       - right signal
% m         - discrete time steps on the delay line (tau)
% n         - discrete time (t)
% M         - number of discrete steps on the delay line, 
%             length(delay line) = length(-M:M)
% k         -
% w_r       - monaural sensitivity in dependence of l
% w_l       - monaural sensitivity in dependence of r
% c_s       - constant inhibition factor
% w_f       - monaural sensitivity at the end of the delay line
% M_f       - 
% 

%% ------ Checking of input parameters -----------------------------------
  
error(nargchk(4,4,nargin));

if ~isnumeric(insig)
    error('%s: insig has to be numeric.',upper(mfilename));
end

if ~isnumeric(w_f) || ~isscalar(w_f)
    error('%s: w_f has to be a scalar.',upper(mfilename));
end

if ~isnumeric(c_s) || ~isscalar(c_s)
    error('%s: c_s has to be a scalar.',upper(mfilename));
end

if ~isnumeric(fs) || ~isscalar(fs)
    error('%s: fs has to be a scalar.',upper(mfilename));
end


%% ------ Computation ---------------------------------------------------- 

siglen = size(insig,1);
nfcs = size(insig,2);

% Ensure 0 <= insig <= 1, so that 0 <= r,l <= 1 (see lindemann1986a, eq. 4)
insig = insig ./ (max(insig(:))+eps);

% Integration time of summing cross-correlation
T_int = round(5/1000 * fs);


% ------ Time steps on the delay line ------------------------------------
% -M:M are the time steps of the delay.
% Maximum delay (in samples): 1ms (this is for 500 Hz pure tones. In common
% this should be different for every frequency band, see Lindemann (1986a) 
% S. 1613, eq. 21.)
% NOTE:
% The delay-line needs a sampling rate of fs*2. Therefore the signals are
% not doubled and filled with 0 as in Lindemann (1986a), page 1610 and 
% 1611, but the delay line time is halved.
M = round(fs/2 / 1000);
% Length of the delay line
dlinelen = length(-M:M);


% ------ Monaural sensitives of the correlator ---------------------------
% The following equations are from Lindemann (1986a) equation 9 on page
%>1611. Obviously is w_r(m) = w_l(-m).
%
% M_f determines the decrease of the monaural sensitivities along the delay 
% line 
M_f = 6;
% Monaural sensitivities for the left ear
w_r = w_f .* exp(-(2*M:-1:0)./M_f);
w_r = w_r';
% Duplicate columns of w_r for every band
w_r = w_r(:,ones(1,nfcs));
% Monaural sensitivities for the right ear
w_l = w_f .* exp(-(0:2*M)./M_f);
w_l = w_l';
w_l = w_l(:,ones(1,nfcs));


% ------ Calculate the cross-correlation ---------------------------------

% Prepare the left and right delay line signal
l = zeros(dlinelen,nfcs);
r = zeros(dlinelen,nfcs);


% Time to look in the past for every entry in crosscorr
% See lindemann1986a, eq. 10
kk_memory = T_int;

% Memory preallocation
crosscorr = zeros( floor( siglen/kk_memory-1 ),dlinelen,nfcs );
kk = zeros(dlinelen,nfcs);

ii = 0; % crosscorr index
nn = 1; % integration window index
for n = 1:siglen
    
    % ------ Inhibition --------------------------------------------------
    % Inhibition after Lindemann (1986a, p. 1612 eq. 13):
    % r(m+1,n+1) = r(m,n) * [1 - c_s l(m,n)]
    % l(m+1,n+1) = l(m,n) * [1 - c_s r(m,n)]
    % The normalization with max([r l]+eps) is done, to avoid a
    % dependence on the amplitude for the inhibition mechanism (see Gaik
    % 1993, p. 109). This preserves the spectral shape across frequency
    % channels.
    % The length of r and l are the same as the length of the delay line
    % (dlinelen = length(-M:M)). Also the signals are mirror-inverted, 
    % because of their different directions passing the 
    % delay line. l starts on the right sight and r on the left side of the
    % delay line. If you want to mirror the axes of the delay line, you
    % have to exchange the input direction of r and l into the delay line.
    l = [ l(2:dlinelen,:) .* (1 - (c_s .* r(2:dlinelen,:) ./ ...
		      max(max([l r]+eps)) ) ); insig(n,:,1) ];
    r = [ insig(n,:,2);   r(1:dlinelen-1,:) .* ...
		      (1 - (c_s .* l(1:dlinelen-1,:) ./ max(max([l r]+eps))) ) ];
    
    % ------ Monaural sensitivity and trading ----------------------------
    %
    % Monaural sensitivities after Lindemann (1986a, p. 1611 eq. 6a + 6b):
    % r'(m,n) = r(m,n) * [1 - w_l(m)] + w_l(m)
    % l'(m,n) = l(m,n) * [1 - w_r(m)] + w_r(m)
    %
    % Trading factors after Gaik (1993, p. 106).
    %>Multiplication by a level factor to reach an ILD of 0 for a given
    %>ITD, if this ILD corresponded to a natural ILD for this ITD.
    %
    %R(m) = r(m) .* trading(m,1) .* (1-w_l(m))  +  w_l(m);
    %L(m) = l(m) .* trading(m,2)  .* (1-w_r(m))  +  w_r(m);
    R = r .* (1-w_l)  +  w_l;
    L = l .* (1-w_r)  +  w_r;
    
    % ------ Cross-correlation -------------------------------------------
    % Calculate running cross-correlation (e.g. Lindemann 1986a, p.1608,
    % 1611).
    % kk(m,n) = sum_{n=-inf}^{nn} R(m,n) * L(m,n) * exp( -(nn-n) / T_int )
    kk = kk + R.*L .* exp( -(kk_memory-nn) / T_int );
   
		% Store the result in crosscorr
    if nn==kk_memory
        ii = ii+1;
        crosscorr(ii,:,:) = kk;
        % Initialize a new running cross-correlation
        kk = zeros(dlinelen,nfcs);
        nn = 0;
    end
    
    nn = nn+1;
   
end



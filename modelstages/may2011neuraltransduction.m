function audNerve = may2011neuraltransduction(bm,fs,haircellMethod)

%   Developed with Matlab 7.5.0.342 (R2007b). Please send bug reports to:
%   
%   Author  :  Tobias May, � 2008-2009
%              TUe Eindhoven and Philips Research  
%              t.may@tue.nl      tobias.may@philips.com
%
%   History :
%   v.1.0   2008/08/06
%   v.1.1   2008/11/05 added envelope compression from Binaural
%                      Cross-correlation Toolbox developed by A. Akeroyd
%   v.1.2   2009/02/10 added persistent memory for envelope lowpass
%   v.1.3   2009/02/11 delay compensation for envelope lowpass filter
%   ***********************************************************************

% Initialize persistent memory
persistent PERfs PERlowpass


%% ***********************  CHECK INPUT ARGUMENTS  ************************

% Check for proper input arguments
checkInArg(2,3,nargin,mfilename);

% Set default values
if nargin < 3 || isempty(haircellMethod); haircellMethod = 'none'; end


%% ************************  NEURAL TRANSDUCTION  *************************
% 
% Wrapper for various models of neural transduction
% 
switch lower(haircellMethod)
    case 'none'
        % No processing ...
        audNerve = bm;
    case 'halfwave'
        % ----------------------
        % PALOMAEKI 2004
        % ----------------------
        % Half-wave rectification
        audNerve = max(bm,0);
    case 'roman'
        % ----------------------
        % ROMAN 2003
        % ----------------------
        % Half-wave rectification and square-root compression
        audNerve = sqrt(max(bm,0));
    case 'haircell'
        % Low-pass filter and half-wave rectification to mimic
        % auditory nerve fibers
        audNerve = haircell(bm,fs,1e3);
    case 'envelope'
        % Halfwave-rectification amd full envelope compression 
        %
        % The envelope compression itself is from Bernsten, van de Par
        % and Trahiotis (1996, especially the Appendix). The lowpass 
        % filtering is from Berstein and Trahiotis (1996, especially EQ 2 
        % on page 3781).

        % Define lowpass filter
        if (isempty(PERfs) || isempty(PERlowpass)) || ...
           (~isempty(PERfs) && ~isequal(PERfs,fs))
            % Define lowpass filter
            cutoff  = 425; %Hz
            order   = 4;
            lpf     = linspace(0, fs/2, 10000);
            f0      = cutoff * (1./ (2.^(1/order)-1).^0.5);
            lpmag   = 1./ (1+(lpf./f0).^2) .^ (order/2);
            lpf     = lpf ./ (fs/2);
            % Filter design
            lowpass = fir2(256, lpf, lpmag, hamming(257));
            
            % Store lowpass to persistent memory
            PERfs      = fs;
            PERlowpass = lowpass;
        else
            % Reload lowpass from persistent memory
            lowpass = PERlowpass;
        end        
        
        % Envelope compression using Weiss/Rose lowpass filter
        compress1 = 0.23;
        compress2 = 2.0;

        % ========================
        % Do the actual processing
        % ========================
       
        % Get envelope
        envelope = abs(hilbert(bm));
        % compress the envelope to a power of compression1, while 
        % maintaining the fine structure.
        compressedenvelope = (envelope.^(compress1 - 1)) .* bm;
        % rectify that compressed envelope
        rectifiedenvelope = max(compressedenvelope,0);
        % raise to power of compress2
        rectifiedenvelope = rectifiedenvelope.^compress2;
        % Zero-padd data to compensate for the delay
        [tmp,maxIdx] = max(abs(lowpass)); %#ok
        rectifiedenvelope = [rectifiedenvelope;zeros(maxIdx-1,size(bm,2))];
        % overlap-add FIR filter using the fft
        audNerve = fftfilt(lowpass, rectifiedenvelope);
        
        % Trim signal to its original length
        audNerve = audNerve(maxIdx:end,:);
    case 'meddis1988'
        % Apply meddis haricell transformation
        audNerve = haircellMeddis(bm,fs,'1988');
    case 'meddismedium'
        % Apply meddis haricell transformation
        audNerve = haircellMeddis(bm,fs,'medium');
    case 'meddishigh'
        % Apply meddis haricell transformation
        audNerve = haircellMeddis(bm,fs,'high');
    case 'meddispitch'
        % Apply meddis haricell transformation
        audNerve = haircellMeddis(bm,fs,'pitch');
    otherwise
        error(['Neural transduction method ''',haircellMethod,...
               ''' is not supported.'])
end


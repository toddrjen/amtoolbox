function exp_hohmann2002(varargin)
%EXP_HOHMANN2002 figures from Hohmann (2012)
%   Usage: exp_hohmann(flags)
%
%   `exp_hohmann2002(flags)` reproduces figures of the paper from
%   Hohmann (2002).
%
%   The following flags can be specified:
%
%     'fig1'    Reproduce Fig. 1:
%               Impulse response of the example Gammatone filter (center
%               frequency  fc = 1000 Hz: 3-dB bandwidth fb = 100 Hz;
%               sampling frequency fs = 10 kHz. Solid and dashed lines
%               show the real and imaginary part of the filter output,
%               respectively. The absolute value of the filter output
%               (dashdotted line) clearly represents the envelope.
%
%     'fig2'    Reproduce Fig.2:
%               Frequency response of the example Gammatone filter
%               (upper two panels) and of the real-to-imaginary
%               response(lower two panels). Pi/2 was added to the phase
%               of the latter (see text). The frequency axis goes up to
%               half the sampling rate (z=pi). 
%
%     'fig3'    Reproduce Fig.3:
%               Magnitude frequency response of the Gammatone
%               filterbank. In this example, the filter channel density
%               is 1 on the ERB scale and the filter bandwidth is 1
%               ERBaud. The sampling frequency was 16276Hz and the
%               lower and upper boundary for the center frequencies
%               were 70Hz and 6.7kHz, respectively.
%
%     'fig4'    Reproduce Fig.4:
%               Treatment of an impulse response with envelope maximum
%               to the left of the desired group delay (at sample 65).
%               The original complex impulse response (real part and
%               envelope plotted in the upper panel) is multiplied with
%               a complex factor and delayed so that the envelope maximum 
%               and the maximum of the real part coincide with the desired
%               group delay (lower panel).
%
%     'fig5'    Reproduce Fig.5:
%               Treatment of an impulse response with envelope maximum 
%               to the right of the desired group delay (vertical line at
%               sampling 65). The original complex impulse response ( real
%               part and envelope plotted in the upper panel) is multiplied
%               with a complex factor so that the maximum of the real part
%               coincides with the desired group delay (lower panel).
%
%     'fig6'    Reproduce Fig.6:
%               Impulse response of the analysis-synthesis system using
%               the filterbank design from section 3.1 (upper pannel). A
%               peaked impulse is achieved at the desired group delay of
%               4 ms (65 samples at fs = 16276 Hz). The lower panel shows 
%               the main part of the response on a larger scale.
%
%     'fig7'    Reproduce Fig.7:
%               Magnitude and group delay of the transfer function of the
%               analysis-synthesis system using the filterbank design from
%               section 3.1.
%             
%     'fig8'    Reproduce Fig.8: !!!not ready yet!!!
%               Objective Difference Grade(ODG) according to ITU-R [15] as a
%               function of the total delay of the analysis-synthesis system
%               for five different signals (castanets, Jazz trio, chimes, 
%               harpsichord and speech). For delay values of 4 ms and above,
%               the quality degradation is smaller than 1 point on the
%               ITU scale, indicating that the distortion is barely audible. 
%
%
%   Examples:
%   ---------
%
%   To display Fig. 1, use :::
%
%     exp_hohmann2002('fig1');
%
%   To display Fig. 2, use :::
%
%     exp_hohmann2002('fig2');
%
%   To display Fig. 3, use :::
%
%     exp_hohmann2002('fig3');
%
%   To display Fig. 4, use :::
%
%     exp_hohmann2002('fig4');
%
%   To display Fig. 5, use :::
%
%     exp_hohmann2002('fig5');
%
%   To display Fig. 6, use :::
%
%     exp_hohmann2002('fig6');
%
%   To display Fig. 7, use :::
%
%     exp_hohmann2002('fig7');
%
%   To display Fig. 8, use :::
%
%     exp_hohmann2002('fig8');
%
%   References: hohmann2002
%
%   See also: demo_hohmann2002 gfb_analyzer gfb_analyzer_process
%   demo_gammatone exp_gammatone gammatone 

% AUTHOR: CK, 2014

%% ------ Check input options --------------------------------------------
    definput.import={'amtredofile'};
    definput.keyvals.FontSize = 12;
    definput.keyvals.MarkerSize = 6;
    definput.flags.type = {'missingflag', 'fig1', 'fig2', 'fig3', 'fig4', ...
    'fig5', 'fig6', 'fig7', 'fig8'};
    
    % Parse input options
    [flags,~]  = ltfatarghelper({'FontSize','MarkerSize'},definput,varargin);

    if flags.do_missingflag
        flagnames=[sprintf('%s, ',definput.flags.type{2:end-2}),...
                   sprintf('%s or %s',definput.flags.type{end-1},definput.flags.type{end})];
        error('%s: You must specify one of the following flags: %s.',upper(mfilename),flagnames);
    end;
    
%% Figure 1

    if flags.do_fig1

        fs = 10000;                 % Sampling rate in Hz;
        flow = 1000;                % Lowest center frequency in Hz;
        basef = 1000;               % Base center frequency in Hz;
        fhigh  = 1000;              % Highest center frequency in Hz;
        filters_per_ERBaud = 1;     % Filterband density on ERB scale;     
        gamma_order= 4;             % Filter order;
        bandwidth_factor = 0.75;    % Bandwidth factor;

        % Construct new analyzer object;
        analyzer = gfb_analyzer_new(fs,flow, basef, fhigh,filters_per_ERBaud,gamma_order,bandwidth_factor);
        % Impulse signal;
        impulse = [1, zeros(1,8191)];
        % Filter signal;
        [impulse_response, analyzer] = gfb_analyzer_process(analyzer, impulse);

        %Plot;
        figure;
        plot(real(impulse_response));
        hold on
        plot(imag(impulse_response),'--g');
        plot(abs(impulse_response),'r');
        xt = 0:50:200;
        axis([0, 200, -0.04, 0.04]);
        set(gca,'XTick',xt)
        title('Real part, imaginary part and envelope of impulse response at fc = 1000 Hz ');
        xlabel('Sample/ 1');   
        ylabel('Amplitude/ 1');
        box on;

    end;

%% Figure 2

    if flags.do_fig2

        fs = 10000;                 % Sampling rate in Hz;
        flow = 1000;                % Lowest center frequency in Hz;
        basef = 1000;               % Base center frequency in Hz;
        fhigh  = 1000;              % Highest center frequency in Hz;
        filters_per_ERBaud = 1;     % Filterband density on ERB scale;     
        gamma_order= 4;             % Filter order;
        bandwidth_factor = 0.75;    % Bandwidth factor;

        % Construct new analyzer object;
        analyzer = gfb_analyzer_new(fs,flow,basef,fhigh,filters_per_ERBaud,gamma_order,bandwidth_factor);
        % Impulse signal;
        impulse = [1, zeros(1,8191)];
        % Filter signal;
        [impulse_response, analyzer] = gfb_analyzer_process(analyzer, impulse);
        % Frequency response;
        frequency_response = fft(real(impulse_response)');                     
        % Normalized frequency vector;
        frequency = (0:8191) * fs / 8192 * 2/fs; 
        % Phase response;
        phi = angle(frequency_response);
        % Unwrap phase;
        phi = unwrap(phi);
        % Division of imaginary frequency reponse by real frequency response; 
        divspectra = fft(imag(impulse_response)')./frequency_response;
        % Phase response from division above;
        theta = angle(divspectra)+pi/2;

        % Plot;
        figure('units','normalized','outerposition',[0.25 0.05 0.5 0.9])
        subplot(4,1,1)
        plot(frequency(1:end/2), 20*log10(abs(frequency_response(1:end/2))))
        xt = 0:0.2:1;
        yt = -60:20:0;
        axis([0, 1, -70, 0]);
        set(gca,'XTick',xt, 'YTick', yt)
        ylabel('Magnitude/dB')
        box on
        subplot(4,1,2)
        plot(frequency(1:end/2),phi(1:end/2))
        ylabel('Phase/rad')
        xt = 0:0.2:1;
        yt = -5:5:5;
        axis([0, 1, -5, 5]);
        set(gca,'XTick',xt, 'YTick', yt)
        box on
        subplot(4,1,3)
        plot(frequency(1:end/2), 20*log10(abs(divspectra(1:end/2))))
        xt = 0:0.2:1;
        yt = -10:5:10;
        axis([0, 1, -10, 10]);
        set(gca,'XTick',xt, 'YTick', yt)
        ylabel('Magnitude/db')
        box on
        subplot(4,1,4)
        plot(frequency(1:end/2), theta(1:end/2))
        xt = 0:0.2:1;
        yt = -2:1:2;
        axis([0, 1, -2, 2]);
        set(gca,'XTick',xt, 'YTick', yt)
        xlabel('Frequency / \pi')
        ylabel('Phase + \pi / 2 /rad')
        box on
        
    end;

%% Figure 3

    if flags.do_fig3
        
        fs = 16276;                 % Sampling rate in Hz;
        flow = 70;                  % Lowest center frequency in Hz;
        basef = 1000;               % Base center frequency in Hz;
        fhigh = 6700;               % Highest center frequency in Hz;
        gamma_order= 4;             % Filter order;
        filters_per_ERBaud = 1.0;   % Filterband density on ERB scale; 
        bandwidth_factor = 1.0;     % Bandwidth factor;
        
        % Construct new analyzer object;
        analyzer = gfb_analyzer_new(fs,flow,basef,fhigh,filters_per_ERBaud,gamma_order,bandwidth_factor);
        % Impulse signal;
        impulse = [1, zeros(1,8191)];                                          
        % Filter signal;
        [impulse_response, analyzer] = gfb_analyzer_process(analyzer, impulse);
        % Frequency response;
        frequency_response = fft(real(impulse_response)');                     
        % Frequency vector;
        frequency = [0:8191] * fs / 8192;                        

        % Plot;
        figure
        plot(frequency, 20 * log10(abs(frequency_response)));
        axis([0,fs/2, -40, 0]);
        title('Frequency response of the individual filters in this filterbank.');
        xlabel('Frequency / Hz');
        ylabel('Level / dB');     
        box on
        
    end;

%% Figure 4

    if flags.do_fig4
        
        fs = 16276;                 % Sampling rate in Hz;
        flow = 1879.16;             % Lowest center frequency in Hz;
        basef = 1879.16;            % Base center frequency in Hz;
        fhigh = 1879.16;            % Highest center frequency in Hz;
        gamma_order= 4;             % Filter order;
        filters_per_ERBaud = 1.0;   % Filterband density on ERB scale; 
        bandwidth_factor = 1.0;     % Bandwidth factor;
        delay_samples = 65;         % Desired delay in Samples;
        
        % Construct new analyzer object;
        analyzer = gfb_analyzer_new(fs,flow,basef,fhigh,filters_per_ERBaud,gamma_order,bandwidth_factor);
        % Impulse signal;
        impulse = [1, zeros(1,8191)];                                          
        % Filter signal;
        [impulse_response, analyzer] = gfb_analyzer_process(analyzer, impulse);
        % Construct new delay object, which holds samples to delay and phase factors.
        delay = gfb_delay_new(analyzer,delay_samples);
        % Delay filtered signal;
        insig = impulse_response;   % Impulse response as input signal;
        [outsig, delay] = gfb_delay_process(delay, insig);
        outsigdelayenv = hilbert(real(outsig),fs);
        
        % Plot;
        figure('units','normalized','outerposition',[0.25 0.05 0.5 0.9])
        subplot(2,1,1)
        plot(real(impulse_response),'b-')
        hold on
        xt = 0:20:200;
        yt = -0.05:0.01:0.05;
        axis([0, 200, -0.05, 0.05]);
        set(gca,'XTick',xt, 'YTick', yt)
        title(['Impulse response with center frequency at ', num2str(basef), ' Hz'])
        xlabel('Sample')
        ylabel('Amplitude')
        plot(abs(impulse_response),'r-')
        box on
        hold off
        
        subplot(2,1,2)
        plot (real(outsig),'b-')
        hold on
        xt = 0:20:200;
        yt = -0.05:0.01:0.05;
        axis([0, 200, -0.05, 0.05]);
        set(gca,'XTick',xt, 'YTick', yt)
        title(['Delayed impulse response with peak at desired delay at sample ', num2str(delay_samples) ])
        xlabel('Sample')
        ylabel('Amplitude')
        plot(abs(outsigdelayenv),'r-')
        box on
        hold off
        
    end;
        
%% Figure 5

    if flags.do_fig5
        
        fs = 16276;                 % Sampling rate in Hz;
        flow = 80;                  % Lowest center frequency in Hz;
        basef = 80;                 % Base center frequency in Hz;
        fhigh = 80;                 % Highest center frequency in Hz;
        gamma_order= 4;             % Filter order;
        filters_per_ERBaud = 1.0;   % Filterband density on ERB scale; 
        bandwidth_factor = 1.0;     % Bandwidth factor;
        delay_samples = 65;         % Desired delay in Samples;
        
        % Construct new analyzer object;
        analyzer = gfb_analyzer_new(fs,flow,basef,fhigh,filters_per_ERBaud,gamma_order,bandwidth_factor);
        % Impulse signal;
        impulse = [1, zeros(1,8191)];                                          
        % Filter signal;
        [impulse_response, analyzer] = gfb_analyzer_process(analyzer, impulse);
        % Construct new delay object, which holds samples to delay and phase factors.
        delay = gfb_delay_new(analyzer,delay_samples);
        % Delay filtered signal;
        insig = impulse_response;   % Impulse response as input signal;
        [outsig, delay] = gfb_delay_process(delay, insig);
        outsigdelayenv = hilbert(real(outsig),fs);
        
        % Plot;
        figure('units','normalized','outerposition',[0.25 0.05 0.5 0.9])
        subplot(2,1,1)
        plot(real(impulse_response),'b-')
        hold on
        set(gca, 'XLim',[0 1000],'YLim',[-0.007 0.007])
        title(['Impulse response with center frequency at ', num2str(basef), ' Hz'])
        xlabel('Sample')
        ylabel('Amplitude')
        plot(abs(impulse_response),'r-')
        box on
        hold off
        
        subplot(2,1,2)
        plot (real(outsig),'b-')
        hold on
        set(gca, 'XLim',[0 1000],'YLim',[-0.007 0.007])
        title(['Delayed impulse response with a peak at desired delay at sample ', num2str(delay_samples) ])
        xlabel('Sample')
        ylabel('Amplitude')
        plot(abs(outsigdelayenv),'r-')
        box on
        hold off
        
    end;
    
%% Figure 6

    if flags.do_fig6
        
        fs = 16276;                 % Sampling rate in Hz;
        flow = 70;                  % Lowest center frequency in Hz;
        basef = 1000;               % Base center frequency in Hz;
        fhigh = 6700;               % Highest center frequency in Hz;      
        filters_per_ERBaud = 1.0;   % Filterband density on ERB scale; 
        filter_order = 4;           % Filter order;
        bw_factor = 1.0;            % Bandwidth factor;
        desired_delay = 0.004;      % Desired delay in seconds;
        
        % Construct new analyzer object;
        analyzer = gfb_analyzer_new(fs,flow,basef,fhigh,filters_per_ERBaud,filter_order,bw_factor);
        % Build synthesizer for an analysis-synthesis delay of desired_delay in seconds.
        synthesizer = gfb_synthesizer_new(analyzer, desired_delay);
        % Impulse signal;
        impulse = [1, zeros(1,8191)]; 
        % Filter signal;
        [analyzed_impulse, analyzer] = gfb_analyzer_process(analyzer, impulse);
        % Resynthesize filtered impulse response from above.
        [resynthesized_impulse, synthesizer] = gfb_synthesizer_process(synthesizer, analyzed_impulse);
    
        % Plot;
        figure('units','normalized','outerposition',[0.25 0.05 0.5 0.9])
        subplot(2,1,1)
        plot(real(resynthesized_impulse),'b-')
        hold on
        plot(zeros(1,length(resynthesized_impulse)),'r')
        hold off
        xt = -200:200:1199;
        yt = -0.2:0.2:1.2;
        axis([-199 1200 -0.2 1.2])
        set(gca,'XTick',xt, 'YTick',yt)
        title('Analysis of resynthesized impulse response')
        xlabel('Sample')
        ylabel('Amplitude')
        box on
        
        subplot(2,1,2)
        plot (real(resynthesized_impulse),'b-')
        hold on
        plot(zeros(1,length(resynthesized_impulse)),'r')
        hold off
        xt = 40:10:120;
        yt = -0.2:0.1:0.8;
        axis([40 120 -0.15 0.85])
        set(gca,'XTick',xt, 'YTick',yt)
        title('Analysis of resynthesized impulse response on a larger scale')
        xlabel('Sample')
        ylabel('Amplitude')
        box on
        
    end;   
%% Figure 7

    if flags.do_fig7
        
        fs = 16276;                 % Sampling rate in Hz;
        flow = 70;                  % Lowest center frequency in Hz;
        basef = 1000;               % Base center frequency in Hz;
        fhigh = 6700;               % Highest center frequency in Hz;      
        filters_per_ERBaud = 1.0;   % Filterband density on ERB scale; 
        filter_order = 4;           % Filter order;
        bw_factor = 1.0;            % Bandwidth factor;
        desired_delay = 0.004;      % Desired delay in seconds;
        
        % Construct new analyzer object;
        analyzer = gfb_analyzer_new(fs,flow,basef,fhigh,filters_per_ERBaud,filter_order,bw_factor);
        % Build synthesizer for an analysis-synthesis delay of desired_delay in seconds.
        synthesizer = gfb_synthesizer_new(analyzer, desired_delay);
        % Impulse signal;
        impulse = [1, zeros(1,8191)]; 
        % Filter signal;
        [analyzed_impulse, analyzer] = gfb_analyzer_process(analyzer, impulse);
        % Resynthesize filtered impulse response from above.
        [resynthesized_impulse, synthesizer] = gfb_synthesizer_process(synthesizer, analyzed_impulse);
        % Normalized frequency vector;
        frequency = [0:8191] * fs / 8192;
        % Transfer function;
        resynthesized_spectra = fft(resynthesized_impulse);
        % Group delay;
        [spectra_grpdelay, w] = grpdelay(resynthesized_impulse,1,8192);
        
        
        % Plot;
        figure('units','normalized','outerposition',[0.25 0.05 0.5 0.9])
        subplot(2,1,1)
        plot(w/(2*pi)*fs, spectra_grpdelay/fs*1000)
        hold on
        plot(zeros(1,length(frequency)),'r')
        xt = 0:1000:8000;
        yt = -15:5:20;
        axis([0 8000 -15 20])
        set(gca,'XTick',xt, 'YTick',yt)
        title('Group delay of transfer function')
        xlabel('Frequency [Hz]')
        ylabel('Group delay / ms')
        box on
        
        subplot(2,1,2)
        plot (frequency, 20*log10(abs(resynthesized_spectra)),'b-')
        hold on
        plot (zeros(1,length(frequency)),'r')
        hold off
        xt = 0:1000:8000;
        yt = -40:5:5;
        axis([0 8000 -40 5])
        set(gca,'XTick',xt, 'YTick',yt)
        title('Magnitude of transfer function')
        xlabel('Frequency / Hz')
        ylabel('Magnitude / dB')
        box on
        
   end; 
   
%% Figure 8

    if flags.do_fig8
        disp('Figure not ready yet')
    end
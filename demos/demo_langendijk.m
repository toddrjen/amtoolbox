%DEMO_LANGENDIJK  Demo of the localization model of Langendijk & Bronkhorst 2002
%
%   This script generates figures showing the results of the localization 
%   model based on the simulation shown in the related paper of Langendijk &
%   Bronkhorst 2002. 
%   You can choose between two of his listeners P3 and P6. The required
%   data (DTF data and response patterns) will be provided by precalculated
%   mat-files due to high computing time (optionally data can be calculated
%   by using the data_langendijk2002 function). 
%
%
%   FIGURE 1 Baseline condition
%   FIGURE 2 2-octave condition (4-16kHz)
%   FIGURE 3 1-octave condition (low 4-8kHz)
%   FIGURE 4 1-octave condition (middle 5.7-11.3kHz)
%   FIGURE 5 1-octave condition (high 8-16kHz)
%
%     Above-named figures are showing the probability density function (pdf) 
%     and actual responses(�) for chosen listener as a function of target 
%     position for different conditions. The shading of each cell codes the 
%     probability density (light/dark is high/low probability)
%
%   FIGURE 6 Likelihood statistics
%
%     Figure 6 shows the likelihood statistics for the actual responses
%     (bars), the average and the 99% confidence interval of the expected
%     likelihood (dots and bars). See the paper for further details.
%
%   See also: langendijk, likelilangendijk, plotlangendijk, plotlikelilangendijk


% Validation of Langendijk et al. (2002)
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% AUTHOR : Robert Baumgartner, OEAW Acoustical Research Institute
% latest update: 2010-08-16
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                               SETTINGS                                %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
listener='P6';  % ID of listener (P3 or P6)
fs = 48000;     % sampling frequency

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

load(['langendijk2002-' listener]); 
% loads hM data for all conditions which were calculated as follows:
% temp=data_langendijk2002([listener '-dtf']);
% pol=temp(1,:);
% med=temp(2:end,:);
% temp=data_langendijk2002([listener '-b']);
% targetb=temp(1,:); responseb=temp(2,:);
% medir=gr2ir(med,'b',fs);
% temp=data_langendijk2002([listener '-2o']);
% target2o=temp(1,:); response2o=temp(2,:);
% medir2o=gr2ir(med,'2o',fs);
% temp=data_langendijk2002([listener '-1ol']);
% target1ol=temp(1,:); response1ol=temp(2,:);
% medir1ol=gr2ir(med,'1ol',fs);
% temp=data_langendijk2002([listener '-1om']);
% target1om=temp(1,:); response1om=temp(2,:);
% medir1om=gr2ir(med,'1om',fs);
% temp=data_langendijk2002([listener '-1oh']);
% target1oh=temp(1,:); response1oh=temp(2,:);
% medir1oh=gr2ir(med,'1oh',fs);

% pdf calcualtion
pb  = langendijk( medir   ,medir); % baseline
disp('1/5')
p2o = langendijk( medir2o ,medir); % 2-oct (4-16kHz)
disp('2/5')
p1ol= langendijk( medir1ol,medir); % 1-oct (low:4-8kHz)
disp('3/5')
p1om= langendijk( medir1om,medir); % 1-oct (middle:5.7-11.3kHz)
disp('4/5')
p1oh= langendijk( medir1oh,medir); % 1-oct (high:8-16kHz)
disp('5/5')

% likelihood estimations
la=zeros(5,1);le=zeros(5,1);ci=zeros(5,2);
idb=1:2:length(targetb); % in order to get comparable likelihoods
[la(1),le(1),ci(1,:)] = likelilangendijk( pb,pol,pol,targetb(idb),responseb(idb) );
[la(2),le(2),ci(2,:)] = likelilangendijk( p2o,pol,pol,targetc,response2o );
[la(3),le(3),ci(3,:)] = likelilangendijk( p1ol,pol,pol,targetc,response1ol );
[la(4),le(4),ci(4,:)] = likelilangendijk( p1om,pol,pol,targetc,response1om );
[la(5),le(5),ci(5,:)] = likelilangendijk( p1oh,pol,pol,targetc,response1oh );

% pdf plots with actual responses
plotlangendijk(pb,pol,pol,[listener '; ' 'baseline']);
hold on; h=plot( targetb, responseb, 'ko'); set(h,'MarkerFaceColor','w')
plotlangendijk(p2o,pol,pol,[listener '; ' '2-oct (4-16kHz)']);
hold on; h=plot( targetc, response2o, 'ko'); set(h,'MarkerFaceColor','w')
plotlangendijk(p1ol,pol,pol,[listener '; ' '1-oct (low: 4-8kHz)']);
hold on; h=plot( targetc, response1ol, 'ko'); set(h,'MarkerFaceColor','w')
plotlangendijk(p1om,pol,pol,[listener '; ' '1-oct (middle: 5.7-11.3kHz)']);
hold on; h=plot( targetc, response1om, 'ko'); set(h,'MarkerFaceColor','w')
plotlangendijk(p1oh,pol,pol,[listener '; ' '1-oct (high: 8-16kHz)']);
hold on; h=plot( targetc, response1oh, 'ko'); set(h,'MarkerFaceColor','w')

% likelihood statistic
plotlikelilangendijk(la,le,ci)
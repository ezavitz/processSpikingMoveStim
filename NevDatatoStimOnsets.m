function [onsetTimes] = NevDatatoStimOnsets(nevData)
% INPUTS: 
% nevData:        data structure output by openNev

% OUTPUTS: 
% onsetTimes:   a partially corrected (no guarantees) interpretation of the
%               digital lines .move for move onset, .blank for blank onset.

% parse some stuff, and translate from samples to milliseconds
RawDIO = nevData.Data.SerialDigitalIO.UnparsedData; %digital value
tRes = nevData.MetaTags.TimeRes; % sampling resolution
RawTimes= double(nevData.Data.SerialDigitalIO.TimeStamp)/tRes*1000; %digital time(ms)

DIO = mod(RawDIO, 128); %digital line without photodiode

% sometimes there is an extra bit. This corrects for that. 
if min(DIO) == 64
    warning ('Extra bit detected. Subtracting.')
    DIO = DIO - 64;
end
    
% associate triggers in DIO with known stimulus events
moveOn = RawTimes(DIO == bin2dec('010101') |...
                  DIO == bin2dec('010100') |...
                  DIO == bin2dec('010001') |...
                  DIO == bin2dec('000101') |...
                  DIO == bin2dec('000001') |...
                  DIO == bin2dec('000100') |...
                  DIO == bin2dec('010000'));

blankOn = RawTimes(DIO == bin2dec('101010') |...
                   DIO == bin2dec('001010') |...
                   DIO == bin2dec('100010') |...
                   DIO == bin2dec('101000') |...
                   DIO == bin2dec('100000') |...
                   DIO == bin2dec('001000') |...
                   DIO == bin2dec('000010'));

% remove stutters
moveStutters = find(diff(moveOn) < 100); %100 ms, 1/5 expected 
moveOn = moveOn(setdiff(1:length(moveOn), moveStutters+1));

blankStutters = find(diff(blankOn) < 100); %100 ms, 1/5 expected 
blankOn = blankOn(setdiff(1:length(blankOn), blankStutters+1));
    
% sometimes there were drops in the digital line. This function
% semi-intelligently fills in any holes, given an expected latency and
% a jitter tolerance. 
% fillInDropComms is in the nPrice-lab/utilities repo
moveOn = fillInDropComs(moveOn, 1000, 500);
blankOn = fillInDropComs(blankOn, 1000, 500);

onsetTimes.move  = moveOn;
onsetTimes.blank = blankOn;
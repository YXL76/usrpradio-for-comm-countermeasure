connectedRadios = findsdru %#ok<NOPTS>

if strncmp(connectedRadios(1).Status, 'Success', 7)
    platform = connectedRadios(1).Platform;
    address = connectedRadios(1).IPAddress;
else
    address = '192.168.10.2';
    platform = 'N200/N210/USRP2';
end

compileIt = false; % true if code is to be compiled for accelerated execution
useCodegen = false; % true to run the latest generated mex file

% Transmitter parameter structure
% prmQPSKTransmitter = sdruqpsktransmitter_init(platform, useCodegen);
prmQPSKTransmitter = sdruqpsktransmitter_init(useCodegen) %#ok<NOPTS>
prmQPSKTransmitter.Platform = platform;
prmQPSKTransmitter.Address = address;

if compileIt
    codegen('runSDRuQPSKTransmitter', '-args', {coder.Constant(prmQPSKTransmitter)}); %#ok<UNRCH>
end

if useCodegen
    clear runSDRuQPSKTransmitter_mex %#ok<UNRCH>
    runSDRuQPSKTransmitter_mex(prmQPSKTransmitter);
else
    runSDRuQPSKTransmitter(prmQPSKTransmitter);
end

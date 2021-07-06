connectedRadios = findsdru %#ok<NOPTS>

if strncmp(connectedRadios(1).Status, 'Success', 7)
    platform = connectedRadios(1).Platform;
    address = connectedRadios(1).IPAddress;
else
    address = '192.168.10.2';
    platform = 'N200/N210/USRP2';
end

printReceivedData = true; % true if the received data is to be printed
compileIt = false; % true if code is to be compiled for accelerated execution
useCodegen = false; % true to run the latest generated code (mex file) instead of MATLAB code

% Receiver parameter structure
prmQPSKReceiver = sdruqpskreceiver_init(useCodegen) %#ok<NOPTS>
prmQPSKReceiver.Platform = platform;
prmQPSKReceiver.Address = address;

if compileIt
    codegen('runSDRuQPSKReceiver', '-args', {coder.Constant(prmQPSKReceiver), coder.Constant(printReceivedData)}); %#ok<UNRCH>
end

if useCodegen
    clear runSDRuQPSKReceiver_mex %#ok<UNRCH>
    BER = runSDRuQPSKReceiver_mex(prmQPSKReceiver, printReceivedData);
else
    BER = runSDRuQPSKReceiver(prmQPSKReceiver, printReceivedData);
end

% fprintf('Error rate is = %f.\n', BER(1));
% fprintf('Number of detected errors = %d.\n', BER(2));
% fprintf('Total number of compared samples = %d.\n', BER(3));

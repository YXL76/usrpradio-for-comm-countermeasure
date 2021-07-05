function runSDRuQPSKTransmitter(prmQPSKTransmitter)
    %#codegen

    persistent hTx radio

    if isempty(hTx)
        % Initialize the components
        % Create and configure the transmitter System object
        hTx = QPSKTransmitter(...
            'UpsamplingFactor', prmQPSKTransmitter.Interpolation, ...
            'RolloffFactor', prmQPSKTransmitter.RolloffFactor, ...
            'RaisedCosineFilterSpan', prmQPSKTransmitter.RaisedCosineFilterSpan, ...
            'MessageBits', prmQPSKTransmitter.MessageBits, ...
            'MessageLength', prmQPSKTransmitter.MessageLength, ...
            'NumberOfMessage', prmQPSKTransmitter.NumberOfMessage, ...
            'ScramblerBase', prmQPSKTransmitter.ScramblerBase, ...
            'ScramblerPolynomial', prmQPSKTransmitter.ScramblerPolynomial, ...
            'ScramblerInitialConditions', prmQPSKTransmitter.ScramblerInitialConditions);

        % Create and configure the SDRu System object. Set the SerialNum for B2xx
        % radios and IPAddress for X3xx, N2xx, and USRP2 radios. MasterClockRate
        % is not configurable for N2xx and USRP2 radios.
        %{

        switch prmQPSKTransmitter.Platform
            case {'B200', 'B210'}
                radio = comm.SDRuTransmitter(...
                    'Platform', prmQPSKTransmitter.Platform, ...
                    'SerialNum', prmQPSKTransmitter.Address, ...
                    'MasterClockRate', prmQPSKTransmitter.MasterClockRate, ...
                    'CenterFrequency', prmQPSKTransmitter.USRPCenterFrequency, ...
                    'Gain', prmQPSKTransmitter.USRPGain, ...
                    'InterpolationFactor', prmQPSKTransmitter.USRPInterpolationFactor);
            case {'X300', 'X310'}
                radio = comm.SDRuTransmitter(...
                    'Platform', prmQPSKTransmitter.Platform, ...
                    'IPAddress', prmQPSKTransmitter.Address, ...
                    'MasterClockRate', prmQPSKTransmitter.MasterClockRate, ...
                    'CenterFrequency', prmQPSKTransmitter.USRPCenterFrequency, ...
                    'Gain', prmQPSKTransmitter.USRPGain, ...
                    'InterpolationFactor', prmQPSKTransmitter.USRPInterpolationFactor);
            case {'N200/N210/USRP2'}
                radio = comm.SDRuTransmitter(...
                    'Platform', prmQPSKTransmitter.Platform, ...
                    'IPAddress', prmQPSKTransmitter.Address, ...
                    'CenterFrequency', prmQPSKTransmitter.USRPCenterFrequency, ...
                    'Gain', prmQPSKTransmitter.USRPGain, ...
                    'InterpolationFactor', prmQPSKTransmitter.USRPInterpolationFactor);
            case {'N300', 'N310'}
                radio = comm.SDRuTransmitter(...
                    'Platform', prmQPSKTransmitter.Platform, ...
                    'IPAddress', prmQPSKTransmitter.Address, ...
                    'MasterClockRate', prmQPSKTransmitter.MasterClockRate, ...
                    'CenterFrequency', prmQPSKTransmitter.USRPCenterFrequency, ...
                    'Gain', prmQPSKTransmitter.USRPGain, ...
                    'InterpolationFactor', prmQPSKTransmitter.USRPInterpolationFactor);
            case {'N320/N321'}
                radio = comm.SDRuTransmitter(...
                    'Platform', prmQPSKTransmitter.Platform, ...
                    'IPAddress', prmQPSKTransmitter.Address, ...
                    'MasterClockRate', prmQPSKTransmitter.MasterClockRate, ...
                    'CenterFrequency', prmQPSKTransmitter.USRPCenterFrequency, ...
                    'Gain', prmQPSKTransmitter.USRPGain, ...
                    'InterpolationFactor', prmQPSKTransmitter.USRPInterpolationFactor);
        end

        %}

        radio = comm.SDRuTransmitter(...
            'Platform', prmQPSKTransmitter.Platform, ...
            'IPAddress', prmQPSKTransmitter.Address, ...
            'CenterFrequency', prmQPSKTransmitter.USRPCenterFrequency, ...
            'Gain', prmQPSKTransmitter.USRPGain, ...
            'InterpolationFactor', prmQPSKTransmitter.USRPInterpolationFactor);
    end

    disp('start')

    % t = timer('StartDelay', 0, 'Period', 1, 'TasksToExecute', Inf, ...
        %     'ExecutionMode', 'fixedRate');

    % t.TimerFcn = @(~, ~)cb_fcn;

    % start(t)

    currentTime = 0;

    tic

    %Transmission Process
    while currentTime < prmQPSKTransmitter.StopTime

        % if radio.CenterFrequency ~= 910e6
        %     radio.CenterFrequency = 910e6
        % end

        % Bit generation, modulation and transmission filtering
        data = hTx();
        % Data transmission
        radio(data);
        % Update simulation time
        currentTime = currentTime + prmQPSKTransmitter.USRPFrameTime;

        d = clock;

        if mod(d(6), 4) > 2
            radio.CenterFrequency = 910e6;
        else
            radio.CenterFrequency = 911e6;
        end

    end

    % stop(t)

    release(hTx);
    release(radio);
end

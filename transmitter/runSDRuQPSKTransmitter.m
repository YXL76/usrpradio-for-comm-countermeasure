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

    currentTime = 0;

    timestep = 5;
    % d = datevec(datetime('now'));
    d = clock;
    fcIdx = max(ceil(d(6) / timestep), 1);
    radio.CenterFrequency = prmQPSKTransmitter.Fcs(fcIdx);

    %Transmission Process
    while currentTime < prmQPSKTransmitter.StopTime

        % d = datevec(datetime('now'));
        d = clock;
        d = max(ceil(d(6) / timestep), 1);

        % Bit generation, modulation and transmission filtering
        data = hTx();
        % Data transmission
        radio(data);
        % Update simulation time
        currentTime = currentTime + prmQPSKTransmitter.USRPFrameTime;

        if d ~= fcIdx
            fcIdx = d;
            radio.CenterFrequency = prmQPSKTransmitter.Fcs(d);
        end

        %{

        if d(6) > flag
            flag = flag + timestep;

            if flag >= 60
                flag = timestep;
                fcIdx = 1;
            else
                fcIdx = fcIdx + 1;
            end

            radio.CenterFrequency = prmQPSKTransmitter.Fcs(fcIdx);
        end

        %}
    end

    release(hTx);
    release(radio);

end

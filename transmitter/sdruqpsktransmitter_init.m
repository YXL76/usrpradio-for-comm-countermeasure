% function SimParams = sdruqpsktransmitter_init(platform, useCodegen)

function SimParams = sdruqpsktransmitter_init(useCodegen)

    %% General simulation parameters
    if useCodegen
        SimParams.Rsym = 0.4e6; % Symbol rate in Hertz
    else
        SimParams.Rsym = 0.2e6; % Symbol rate in Hertz
    end

    SimParams.ModulationOrder = 4; % QPSK alphabet size
    SimParams.Interpolation = 2; % Interpolation factor
    SimParams.Decimation = 1; % Decimation factor
    SimParams.Tsym = 1 / SimParams.Rsym; % Symbol time in sec
    SimParams.Fs = SimParams.Rsym * SimParams.Interpolation; % Sample rate

    %% Frame Specifications
    % [BarkerCode*2 | 'Hello world 000\n' | 'Hello world 001\n' ...];
    SimParams.BarkerCode = [+1 +1 +1 +1 +1 -1 -1 +1 +1 -1 +1 -1 +1]; % Bipolar Barker Code
    SimParams.BarkerLength = length(SimParams.BarkerCode);
    SimParams.HeaderLength = SimParams.BarkerLength * 2; % Duplicate 2 Barker codes to be as a header
    SimParams.Message = load("randnum.mat").randnum;
    SimParams.MessageLength = length(SimParams.Message); % 'Hello world 000\n'...
    SimParams.NumberOfMessage = 1; % Number of messages in a frame
    symbol_per_frame = 20; % 每10个符号合并为1帧
    SimParams.PayloadLength = SimParams.NumberOfMessage * symbol_per_frame * 7; % 7 bits per characters
    SimParams.FrameSize = (SimParams.HeaderLength + SimParams.PayloadLength) ...
        / log2(SimParams.ModulationOrder); % Frame size in symbols
    SimParams.FrameTime = SimParams.Tsym * SimParams.FrameSize;

    %% Tx parameters
    SimParams.RolloffFactor = 0.5; % Rolloff Factor of Raised Cosine Filter
    SimParams.ScramblerBase = 2;
    SimParams.ScramblerPolynomial = [1 1 1 0 1];
    SimParams.ScramblerInitialConditions = [0 0 0 0];
    SimParams.RaisedCosineFilterSpan = 10; % Filter span of Raised Cosine Tx Rx filters (in symbols)

    %% Message generation
    %{

    msgSet = zeros(100 * SimParams.MessageLength, 1);

    for msgCnt = 0:99
        msgSet(msgCnt * SimParams.MessageLength + (1:SimParams.MessageLength)) = ...
            sprintf('%s %03d\n', SimParams.Message, msgCnt);
    end

    bits = de2bi(msgSet, 7, 'left-msb')';
    SimParams.MessageBits = bits(:);

    %}

    bits = de2bi(SimParams.Message, 4, 'left-msb')';
    [~, column] = size(bits); % 读取发送数据矩阵维度

    for i = 1:column / symbol_per_frame
        Bits(:, :, i) = bits(:, (i - 1) * symbol_per_frame + 1:i * symbol_per_frame); %#ok<AGROW>
        final(:, :, i) = reshape(Bits(:, :, i), 4 * symbol_per_frame, 1); %#ok<AGROW>
    end

    SimParams.MessageBits = final;

    %% USRP transmitter parameters
    %{

    switch platform
        case {'B200', 'B210'}
            SimParams.MasterClockRate = 20e6; % Hz
        case {'X300', 'X310'}
            SimParams.MasterClockRate = 200e6; % Hz
        case {'N300', 'N310'}
            SimParams.MasterClockRate = 153.6e6; % Hz
        case {'N320/N321'}
            SimParams.MasterClockRate = 200e6; % Hz
        case {'N200/N210/USRP2'}
            SimParams.MasterClockRate = 100e6; % Hz
        otherwise
            error(message('sdru:examples:UnsupportedPlatform', ...
                platform))
    end

    %}

    SimParams.MasterClockRate = 100e6; % Hz

    SimParams.USRPCenterFrequency = 987e6;
    SimParams.USRPGain = 25;
    SimParams.USRPFrontEndSampleRate = SimParams.Rsym * 2; % Nyquist sampling theorem
    SimParams.USRPInterpolationFactor = SimParams.MasterClockRate / SimParams.USRPFrontEndSampleRate;
    SimParams.USRPFrameLength = SimParams.Interpolation * SimParams.FrameSize;

    % Experiment Parameters
    SimParams.USRPFrameTime = SimParams.USRPFrameLength / SimParams.USRPFrontEndSampleRate;
    SimParams.StopTime = 1000;

end

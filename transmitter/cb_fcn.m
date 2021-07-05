function cb_fcn
    persistent flag;
    global radio;

    if isempty(flag)
        flag = false;
    else
        flag = xor(flag, true);
    end

    if flag
        radio.CenterFrequency = 915e6;
    else
        radio.CenterFrequency = 914e6;
    end

end

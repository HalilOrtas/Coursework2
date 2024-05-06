% Halil Ortas
% efyho4@nottingham.ac.uk

%% TASK 3 - ALGORITHMS – TEMPERATURE PREDICTION [25 MARKS]

function temp_prediction(a)
    % Function to continuously monitor temperature and predict future temperature
    
    % Initialise LED pins
    green_led_pin = 'D2';
    yellow_led_pin = 'D3';
    red_led_pin = 'D4';
    
    % Initialise temperature monitoring variables
    temperature_history = []; % Stores historical temperature readings
    time_history = []; % Stores corresponding time values
    comfort_range_min = 18; % Minimum temperature in comfort range
    comfort_range_max = 24; % Maximum temperature in comfort range
    rate_threshold = 4; % Threshold for temperature change rate in °C/min
    
    % Main loop
    while true
        % Read temperature
        temperature = read_temperature(a);
        
        % Record temperature and time
        temperature_history = [temperature_history, temperature];
        time_history = [time_history, now];
        
        % Calculate temperature change rate (dTemp/dt) in °C/s
        if length(temperature_history) > 1
            d_temp = temperature_history(end) - temperature_history(end-1); % Change in temperature
            d_time = (time_history(end) - time_history(end-1)) * 24 * 60 * 60; % Change in time in seconds
            temp_change_rate = d_temp / d_time; % Temperature change rate in °C/s
        else
            temp_change_rate = 0; % Set initial temperature change rate to 0
        end
        
        % Print temperature change rate to screen
        fprintf('Temperature change rate: %.2f °C/s\n', temp_change_rate);
        
        % Predict temperature in 5 minutes
        predicted_temp = temperature + (temp_change_rate * 5 * 60); % Temperature change in 5 minutes
        fprintf('Predicted temperature in 5 minutes: %.2f °C\n', predicted_temp);
        
        % Control LEDs based on temperature change rate
        if temp_change_rate > rate_threshold
            control_led(a, red_led_pin, 'on'); % Turn on red LED
        elseif temp_change_rate < -rate_threshold
            control_led(a, yellow_led_pin, 'on'); % Turn on yellow LED
        else
            control_led(a, green_led_pin, 'on'); % Turn on green LED
        end
        
        % Pause for sampling interval
        pause(1); % Adjust sampling interval as needed
    end
end

% Helper function to read temperature
function temperature = read_temperature(a)
    % Function to read temperature from sensor connected to Arduino
    % (Implement this function)
end

% Helper function to control LED
function control_led(a, pin, state)
    % Function to control LED state
    % (Implement this function)
end

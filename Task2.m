% Halil Ortas
% efyho4@nottingham.ac.uk

%% TASK 2 - LED TEMPERATURE MONITORING DEVICE IMPLEMENTATION [25 MARKS]

function temp_monitor(a)
    % Function to monitor temperature and control LEDs

    % Initialise LEDs pins
    green_led_pin = 'D2';
    yellow_led_pin = 'D3';
    red_led_pin = 'D4';

    % Set up temperature monitoring
    duration = inf; % Run indefinitely
    time_interval = 1; % Sampling interval in seconds
    temperature_readings = [];
    time_seconds = [];

    % Initialise live plot
    figure;
    h = plot(nan, nan);
    xlabel('Time (s)');
    ylabel('Temperature (°C)');
    xlim([0 10]); % Initial x-axis limit
    ylim([0 30]); % Initial y-axis limit

    % Initialise LED states
    green_led_state = 0;
    yellow_led_state = 0;
    red_led_state = 0;

    % Main loop
    while true
        % Read temperature
        temperature = read_temperature(a); % Function to read temperature

        % Record temperature
        temperature_readings = [temperature_readings, temperature];
        time_seconds = [time_seconds, length(temperature_readings)];

        % Update live plot
        set(h, 'XData', time_seconds, 'YData', temperature_readings);
        xlim([max(0, length(temperature_readings) - 10), length(temperature_readings)]);
        ylim([0, 30]); % Adjust y-axis limit as needed
        drawnow;

        % Control LEDs based on temperature
        control_leds(a, green_led_pin, yellow_led_pin, red_led_pin, temperature);

        % Pause for sampling interval
        pause(time_interval);
    end
end

% temp_monitor - Function to monitor temperature and control LEDs
%
% Usage:
%    temp_monitor(a)
%
% Inputs:
%    a - Arduino object for communication with the Arduino board
%
% Description:
%    This function continuously monitors the temperature using a temperature sensor connected to the Arduino. 
%    It displays the temperature on a live plot and controls three LEDs based on the temperature range:
%    - Green LED shows a constant light when the temperature is in the range 18-24 °C.
%    - Yellow LED blinks intermittently at 0.5 s intervals when the temperature is below the range.
%    - Red LED blinks intermittently at 0.25 s intervals when the temperature is above the range.
%
% Author: [Your Name]
% Repository: [Link to your repository]

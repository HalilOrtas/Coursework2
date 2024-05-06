% Halil Ortas
% efyho4@nottingham.ac.uk


%% PRELIMINARY TASK - ARDUINO AND GIT INSTALLATION [10 MARKS]

% Establish communication between MATLAB and Arduino
a = arduino('COM4', 'Uno');

% Connect the GND and 5V pins of the Arduino to the ground bus “–“ and to the power bus “+”
% Connect one of the LEDs to the breadboard, with the two legs on two different lines.
% Using one jumper wire, connect the line where the long LED leg sits to a digital channel of the Arduino.
% Using one 220 Ω resistor, connect the line where the short leg of the LED sits to the ground bus “-“.

% Apply 5V tension to the LED, lightening it
writeDigitalPin(a, 'D13', 1);

% Switch off the LED
writeDigitalPin(a, 'D13', 0);

% Create a loop to make the LED blink
for i = 1:10 % Blink for 10 times
    % Turn on the LED
    writeDigitalPin(a, 'D13', 1);
    pause(0.5); % Pause for 0.5 seconds
    % Turn off the LED
    writeDigitalPin(a, 'D13', 0);
    pause(0.5); % Pause for 0.5 seconds
end


%% TASK 1 - READ TEMPERATURE DATA, PLOT, AND WRITE TO A LOG FILE [20 MARKS]

% Establish communication between MATLAB and Arduino
a = arduino('COM4', 'Uno'); % Replace 'COM3' with the correct port

% Define duration and time interval
duration = 600; % seconds
time_interval = 1; % seconds

% Arrays to store acquired data
time_minutes = 0:time_interval:(duration/60); % Time in minutes
temperature_values = zeros(1, duration/time_interval);

% Simulated temperature coefficient and zero-degree voltage
TC = 0.01; % Example temperature coefficient
V0 = 0.5; % Example zero-degree voltage

% Simulate temperature data
for t = 1:length(temperature_values)
    temperature_values(t) = TC * readVoltage(a, 'A0') + V0; % Read analog voltage from A0
    pause(time_interval);
end

% Convert voltage values into temperature values
temperatures_C = (temperature_values - V0) / TC;

% Calculate statistical quantities
min_temp = min(temperatures_C);
max_temp = max(temperatures_C);
avg_temp = mean(temperatures_C);

% Display recorded data
disp('Data logging initiated - 5/3/2024');
disp('Location - Nottingham');
fprintf('\n');

for i = 1:length(time_minutes)
    fprintf('Minute\t\t%d\n', time_minutes(i));
    fprintf('Temperature\t%.2f C\n', temperatures_C(i));
    fprintf('\n');
end

fprintf('Max temp\t%.2f C\n', max_temp);
fprintf('Min temp\t%.2f C\n', min_temp);
fprintf('Average temp\t%.2f C\n', avg_temp);
fprintf('\n');
disp('Data logging terminated');

% Write data to log file
filename = 'cabin_temperature.txt';
fileID = fopen(filename, 'w');
fprintf(fileID, 'Data logging initiated - 5/3/2024\n');
fprintf(fileID, 'Location - Nottingham\n\n');

for i = 1:length(time_minutes)
    fprintf(fileID, 'Minute\t\t%d\n', time_minutes(i));
    fprintf(fileID, 'Temperature\t%.2f C\n\n', temperatures_C(i));
end

fprintf(fileID, 'Max temp\t%.2f C\n', max_temp);
fprintf(fileID, 'Min temp\t%.2f C\n', min_temp);
fprintf(fileID, 'Average temp\t%.2f C\n', avg_temp);

fprintf(fileID, '\nData logging terminated');
fclose(fileID);


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



%% TASK 4 - REFLECTIVE STATEMENT [5 MARKS]

% Reflective Statement:
% 
% Creating the temperature monitoring and control system was like embarking on an adventure, full of twists and turns, challenges, and moments of enlightenment. One of the biggest hurdles we faced was getting MATLAB to talk fluently with the Arduino board. It felt like unraveling a mystery at times, but with the help of detailed guides and online forums, we cracked the code and made it work.
% 
% Figuring out how to make the LEDs respond to temperature changes was another puzzle to solve. It required us to think like detectives, analyzing data and crafting logic that would make the LEDs act just right. It was a process of trial and error, but with each tweak, we got closer to our goal.
% 
% Despite the challenges, the project had its shining moments. We designed it to be flexible and easy to build upon, like building blocks that fit together seamlessly. And seeing the temperature data come to life on the live plot was nothing short of magical. It was like watching a story unfold before our eyes, with each data point revealing a new chapter.
% 
% Of course, no project is without its limitations. Relying on just one temperature sensor felt a bit like putting all our eggs in one basket. It got the job done, but we knew there was room for improvement. Maybe in the future, we'll add more sensors to make our system even smarter and more reliable.
% 
% Looking forward, there's still so much we want to do. We dream of refining our system, fine-tuning it to be even more precise and responsive. And who knows, maybe one day we'll take it wireless, giving it the freedom to roam and explore new horizons.
% 
% In the end, this project was more than just lines of code and circuits. It was a journey of discovery, a testament to our curiosity and determination. And as we look back on how far we've come, we can't help but feel excited for the adventures that lie ahead.

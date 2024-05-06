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


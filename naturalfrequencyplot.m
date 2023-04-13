% Sample data
natural_frequencies = [15.9869, 19.4633, 33.7209, 61.7542, 63.5937, 70.1690, 71.8313, 81.4900, 82.2839, 100.2746, 104.7079, 177.6555, 228.7711, 745.4122];

% Plot first five natural frequencies
figure;
for i=1:5
    % Create a subplot for each natural frequency
    subplot(5, 1, i);
    % Generate time vector
    t = linspace(0, 0.5, 1000);
    % Plot the frequency response
    plot(t, cos(natural_frequencies(i) * t));
    % Set the title of each subplot
    title(sprintf('Frequency %d: %.4f Hz', i, natural_frequencies(i)));
    % Label the x-axis
    xlabel('Time (s)');
    % Label the y-axis
    ylabel('Amplitude');
end

% Plot superposition of all natural frequencies
figure;
% Generate time vector
t = linspace(0, 0.5, 1000);
% Initialize the superposition signal
y = zeros(size(t));
for i = 1:numel(natural_frequencies)
    % Add the frequency response of each natural frequency to the superposition signal
    y = y + cos(natural_frequencies(i) * t);
end
% Plot the superposition signal
plot(t, y);
% Set the title of the plot
title('Superposition of all natural frequencies');
% Label the x-axis
xlabel('Time (s)');
% Label the y-axis
ylabel('Amplitude');

function [leftCenterPosition, rightCenterPosition] = konfiguracijaGrafika()

% Define screen size
screenSize = get(0, 'ScreenSize');
screenWidth = screenSize(3);
screenHeight = screenSize(4);

% Define figure size
figureWidth = screenWidth / 2;
figureHeight = screenHeight / 1.5;

% Calculate positions
leftCenterPosition = [screenWidth / 4 - figureWidth / 2, screenHeight / 2 - figureHeight / 2, figureWidth, figureHeight];
rightCenterPosition = [3 * screenWidth / 4 - figureWidth / 2, screenHeight / 2 - figureHeight / 2, figureWidth, figureHeight];

end


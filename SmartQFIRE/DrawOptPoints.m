function stop = DrawOptPoints(x, optimValues, state)
% Extret del exemple matlab
% http://es.mathworks.com/help/matlab/math/output-functions.html
stop = false;
hold on;
plot(x(1),x(2),'.');
drawnow
% 2D points of interest
P = rand(2, 5);

% Candidate point set
X = rand(2, 50);

I = nearestneighbour(P, X);

disp('Candidate points:')
disp(P)
disp('Nearest neighbours')
disp(X(:, I))

% Plot the points
figure
scatter(X(1,:), X(2,:), 'b')
hold on
scatter(P(1,:), P(2,:), 'r')
quiver(P(1, :), P(2, :), X(1,I) - P(1, :), X(2, I) - P(2, :), 0, 'k');
hold off
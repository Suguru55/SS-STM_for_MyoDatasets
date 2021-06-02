function f = confidence(x, u)
% x is one sample, u1~u3 are prototypes belonging to the three emotion
% classes. f is a scalar, showing the confidence.
for i = 1:size(u,1)
    for j = 1:size(u,2)
        dist(i,j) = norm(x-u(i,j));
    end
end
D = min(dist');
D = sort(D); % ascending order
Q = (D(2)-D(1));
f = 1/(1+exp(-Q+1));
end


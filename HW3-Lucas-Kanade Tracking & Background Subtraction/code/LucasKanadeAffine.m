function M = LucasKanadeAffine(It, It1)

% input - image at time t, image at t+1 
% output - M affine transformation matrix

% initialize the coordinates and threshold
[It, It1] = deal(im2double(It), im2double(It1));
[height width] = deal(size(It, 1), size(It, 2));
[p, threshold] = deal(zeros(6, 1), 0.01);

% image vector generation
[X, Y] = meshgrid(1: ceil(width), 1: ceil(height));
[X, Y] = deal(X(:), Y(:));
% imgVec = [X'; Y'; ones(size(X'))];

% iteratively minimize error
converge = false;
while converge ~= true
   
    % affine transformation matrix
    M = [1+p(1), p(3), p(5); p(2), 1+p(4), p(6); 0, 0, 1];
    
    % warp and compute error image
    warpedIt = warpH(It, M, size(It)); 
    errorImg = It1 - warpedIt;
    [Fx, Fy] = gradient(warpedIt);

    % matrix of image derivatives 
    A = [Fx(:) .* X, Fy(:) .* X, Fx(:) .* Y, Fy(:) .* Y, Fx(:), Fy(:)];
    H = A' * A;
    
    % update p
    delta = H \ A' * errorImg(:);
    p = p - delta;
    converge = norm(delta) < threshold;
end 

[u v] = deal(p(1), p(2));

end


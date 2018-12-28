function [R] = rotMbyV(vec)
%This function returns a Matrixs by the vector we add

norm_vec = norm(vec);
Ux = [0 -vec(3) vec(2); vec(3) 0 -vec(1); -vec(2) vec(1) 0];

R = eye(3) * cosd(norm_vec) + ((1 - cosd(norm_vec)) / norm_vec ^ 2) * (vec * vec') + (sind(norm_vec) / norm_vec) * Ux; 
end


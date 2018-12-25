function [norm] = quat_norm(q)
%QUAT_NORM Given a quat it returns its norm
%   Detailed explanation goes here

norm = q(1)^2 + q(2)^2 + q(3)^2 + q(4)^2;

end


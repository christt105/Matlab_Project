function [R] = quat2RotMat(q)
%QUAT2ROTMAT Calculates rotation matrix of a quaternion
%   Detailed explanation goes here

R = [q(1)^2+q(2)^2-q(3)^2-q(4)^2, 2*q(2)*q(4)-2*q(1)*q(4), 2*q(2)*q(4)+2*q(1)*q(3);
    2*q(2)*q(3)+2*q(1)*q(4),    q(1)^2-q(2)^2+q(3)^2-q(4)^2, 2*q(3)*q(4)-2*q(1)*q(2);
    2*q(2)*q(4)-2*q(1)*q(3),    2*q(3)*q(4)+2*q(1)*q(2),    q(1)^2-q(2)^2-q(3)^2+q(4)^2];
end


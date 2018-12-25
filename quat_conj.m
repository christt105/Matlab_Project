function [quat_c] = quat_conj(quat)
%QUAT_CONJ Summary of this function goes here
%   Detailed explanation goes here
quat_c = [quat(1), -quat(2), -quat(3), -quat(4)]';
end


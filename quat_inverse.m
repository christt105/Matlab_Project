function [q_i] = quat_inverse(q)
%QUAT_INVERSE Given a quat, it returns its inverse
%   Detailed explanation goes here

q_i = quat_conj(q)/quat_norm(q);
end


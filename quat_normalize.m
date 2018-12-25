function [quat_normalized] = quat_normalize(q)
%QUAT_NORMALIZE Summary of this function goes here
%   Detailed explanation goes here
quat_normalized = q/quat_module(q);
end


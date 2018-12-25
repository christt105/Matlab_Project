function [module] = quat_module(quad)
%QUATMODULE Calculates module of a quaternion
%   Detailed explanation goes here

module = sqrt(quad(1)^2 + quad(2)^2 + quad(3)^2 + quad(4)^2);

end


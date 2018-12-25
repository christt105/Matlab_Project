function [w] = rotVbyq(q,v)
%ROTVBYQ Rotates a vector using a quaternion.
%   Detailed explanation goes here

if(quat_module(q) ~= 1) %if quaternion given is not normalized
    q = quat_normalize(q);      %we want to normalized it to be able to operate
end

v_q = [0 v(1) v(2) v(3)]';                          %Given a vector of 3 dimensions we have to 
q_c = quat_conj(q);                                 %transform it to pure quaternion
w = multiplyQuat(multiplyQuat(q,v_q),q_c);          %this is the quaterion multiplication
w = w(2:4);
end


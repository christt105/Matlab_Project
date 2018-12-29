function [q3] = multiplyQuat(q1,q2)
%MULTIPLYQUAT function that multiplies 2 quaternions
%
%             Inputs: q1: first quaternion (ORDER MATTERS)
%                     q2: Second quaternion (ORDER MATTERS)
%
%             Output: q3: outcome quaternion

  q3(1) = q1(1)*q2(1)-([q1(2);q1(3);q1(4)]'*[q2(2);q2(3);q2(4)]);
  q3(2:4) = q1(1)*[q2(2);q2(3);q2(4)]+q2(1)*[q1(2);q1(3);q1(4)]+cross([q1(2);q1(3);q1(4)],[q2(2);q2(3);q2(4)]);
 
end


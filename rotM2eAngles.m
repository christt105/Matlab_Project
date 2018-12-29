function [phi1,phi2,theta1,theta2,psi1,psi2,flag] = rotM2eAngles(R)
%[phi1,phi2,theta1,theta2,psi1,psi2] = rotM2eAngles(R)
%   Given a rotation matrix return its respective euler angles
%   Flag is 0 when there's no singularity, -1 when we only get phi-psi and
%   1 when we get phi+psi

theta1 = asind(-(R(3,1)));
theta2 = 180 - theta1;

%cos(theta1) == 0

if theta1 == 90
  
   phi_minus_psi = asind(R(1,2));
   
   psi1 = 0;
   psi2 =psi1;
   
   phi1 = phi_minus_psi + psi1;
   phi2 = phi1;
   
   flag = -1;
elseif theta1 == -90
   
    phi_plus_psi = asind(R(1,2));
    
    psi1 = 0;
    psi2 =psi1;
    
    phi1 = phi_plus_psi - psi1;
    phi2 = phi1;
    
    flag = 1;
elseif theta1 ~= 90 || theta1 ~= 90

    phi1 = atan2d((R(3,2))/cosd(theta1),(R(3,3))/cosd(theta1));
    phi2 = atan2d((R(3,2))/cosd(theta2),(R(3,3))/cosd(theta2));

    psi1  = atan2d((R(2,1))/cosd(theta1),(R(1,1))/cosd(theta1));
    psi2  = atan2d((R(2,1))/cosd(theta2),(R(1,1))/cosd(theta2));
 
    flag = 0;
end

end


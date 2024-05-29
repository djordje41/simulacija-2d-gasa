function v = arctg(x, y)
   v=zeros(size(x));
   v(x>0 & y>=0) = atan( y(x>0 & y>=0) ./ x(x>0 & y>=0) );
   v(x>0 & y<0) = 2*pi+atan( y(x>0 & y<0) ./ x(x>0 & y<0) );
   v(x<0 & y>=0) = pi+atan( y(x<0 & y>=0) ./ x(x<0 & y>=0) );
   v(x<0 & y<0) = pi+atan( y(x<0 & y<0) ./ x(x<0 & y<0) );
   v(x==0 & y>=0) = pi/2;
   v(x==0 & y<0) = 3/2*pi;
end


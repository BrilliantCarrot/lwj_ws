function z = cal_alt(x,y,X,Y,Z)
    
    
    [idx1, idx2] = find(X(1,:)-x < 0);
    [idx3, idx4] = find(Y(:,1)-y < 0);
    ix = idx3(end);
    iy = idx2(end);

    ix11 = ix; iy11 = iy;
    ix12 = ix; iy21 = iy;
    if ix == size(X,1)
        ix21 = ix;
        ix22=  ix;
    else
        ix21 = ix+1;
        ix22 = ix+1;
    end

    if iy == size(X,2)
        iy12 = iy;
        iy22 = iy;
    else
        iy12 = iy+1;
        iy22 = iy+1;
    end



    
    
    x11 = X(ix11,iy11); y11 = Y(ix11,iy11);
    x12 = X(ix12,iy12); y12 = Y(ix12,iy12);
    x21 = X(ix21,iy21); y21 = Y(ix21,iy21);
    x22 = X(ix22,iy22); y22 = Y(ix22,iy22);

    r11 = norm([x11-x y11-y]);
    r12 = norm([x12-x y12-y]);
    r21 = norm([x21-x y21-y]);
    r22 = norm([x22-x y22-y]);

    z11 = Z(ix11,iy11);
    z12 = Z(ix12,iy12);
    z21 = Z(ix21,iy21);
    z22 = Z(ix22,iy22);

    z = (r11*z11 + r12*z12 + r21*z21 + r22*z22 )/(r11+r12+r21+r22);  
   
    

end
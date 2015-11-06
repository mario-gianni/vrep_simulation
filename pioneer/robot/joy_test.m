joy = vrjoystick(1);

while(button(joy,1) == 0)
    
    if (button(joy,2) ~= 0)
        disp('Joypad Button A')
    end
    
    if (button(joy,3) ~= 0)
        disp('Joypad Button B')
    end
    
    
    if (button(joy,4) ~= 0)
        disp('Joypad Button Y')
    end
    
    if(axis(joy,1) ~= 0)
        disp('Axis 1 LEFT-RIGHT')
    end
    
    if(axis(joy,2) ~= 0)
        disp('Axis 1 UP-DOWN')
    end
    
    if(axis(joy,3) ~= 0)
        disp('Axis 2 LEFT-RIGHT')
    end
    
    if(axis(joy,4) ~= 0)
        disp('Axis 2 UP-DOWN')
    end
    
    if(axis(joy,5) ~= 0)
        axis(joy,5)
        disp('Axis 3 LEFT-RIGHT')
    end
    
    if(axis(joy,6) ~= 0)
        axis(joy,6)
        disp('Axis 3 UP-DOWN')
    end
end
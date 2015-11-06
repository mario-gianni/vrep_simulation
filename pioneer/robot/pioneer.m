function pioneer()
% youbot Illustrates the V-REP Matlab bindings.

% (C) Copyright Renaud Detry 2013.
% Distributed under the GNU General Public License.
% (See http://www.gnu.org/copyleft/gpl.html)
   
   disp('Program started');
   %Use the following line if you had to recompile remoteApi
   %vrep = remApi('remoteApi', 'extApi.h');
   vrep=remApi('remoteApi');
   vrep.simxFinish(-1);
   id = vrep.simxStart('127.0.0.1', 19997, true, true, 2000, 5);
   
   if id < 0,
   disp('Failed connecting to remote API server. Exiting.');
   vrep.delete();
   return;
   end
   fprintf('Connection %d to remote API server open.\n', id);
   
   % Make sure we close the connexion whenever the script is interrupted.
   cleanupObj = onCleanup(@() cleanup_vrep(vrep, id));
   
   % This will only work in "continuous remote API server service"
   % See http://www.v-rep.eu/helpFiles/en/remoteApiServerSide.htm
   res = vrep.simxStartSimulation(id, vrep.simx_opmode_oneshot_wait);
   % We're not checking the error code - if vrep is not run in continuous remote
   % mode, simxStartSimulation could return an error.
   vrchk(vrep, res);
   
   h = pioneer_init(vrep, id);
   h = pioneer_hokuyo_init(vrep, h);
   joy = vrjoystick(1);
   
   pause(.2);
   timestep = .05;
   
   plotData = true;
   if plotData,
   %subplot(211)
   %figure(1)
   %drawnow;
   [X,Y] = meshgrid(-10:.25:10,-10:.25:10);
   X = reshape(X, 1, []);
   Y = reshape(Y, 1, []);
   end
   
   disp('Starting robot');
   
   d = 0.17;
   
   pan_step = 0.5;
   tilt_step = 0.5;
   gain = 1.5;
   
   while (button(joy,1) == 0)
       tic
       
       % Pioneer Pose
       [res pioneerPosition] = vrep.simxGetObjectPosition(id, h.ref, -1,vrep.simx_opmode_buffer); 
       
       vrchk(vrep, res, true);
       
       [res pioneerOrientation] = vrep.simxGetObjectOrientation(id, h.ref, -1,vrep.simx_opmode_buffer); 
       
       vrchk(vrep, res, true);
       
       if plotData,
           % Read data from the Hokuyo sensor:
           [pts contacts] = pioneer_hokuyo(vrep, h, vrep.simx_opmode_buffer);
           
           in = inpolygon(X, Y, [h.hokuyo1Pos(1) pts(1,:) h.hokuyo2Pos(1)],...
               [h.hokuyo1Pos(2) pts(2,:) h.hokuyo2Pos(2)]);
           
           %subplot(211)
           %figure(1)
           plot(X(in), Y(in),'.g', pts(1,contacts), pts(2,contacts), '*r',...
               [h.hokuyo1Pos(1) pts(1,:) h.hokuyo2Pos(1)],...
               [h.hokuyo1Pos(2) pts(2,:) h.hokuyo2Pos(2)], 'r',...
               0, 0, 'ob',...
               h.hokuyo1Pos(1), h.hokuyo1Pos(2), 'or',...
               h.hokuyo2Pos(1), h.hokuyo2Pos(2), 'or');
           axis([-5.5 5.5 -5.5 5.5]);
           axis equal;
           drawnow;
           
       end
       
       % Update wheel velocities
       res = vrep.simxPauseCommunication(id, true); vrchk(vrep, res);
       
       linear_vel = - gain * axis(joy,2);
       angular_vel = - gain * axis(joy,1);
       vl = linear_vel - d * angular_vel;
       vr = linear_vel + d * angular_vel;
       
       vrep.simxSetJointTargetVelocity(id, h.wheelJoints(1),vl,vrep.simx_opmode_oneshot); vrchk(vrep, res);
       vrep.simxSetJointTargetVelocity(id, h.wheelJoints(2),vr,vrep.simx_opmode_oneshot); vrchk(vrep, res);
       
       pan = pan_step * axis(joy,5);
       tilt = tilt_step * axis(joy,6);
       vrep.simxSetJointTargetVelocity(id, h.pan,pan,vrep.simx_opmode_oneshot); vrchk(vrep, res);
       vrep.simxSetJointTargetVelocity(id, h.tilt,tilt,vrep.simx_opmode_oneshot); vrchk(vrep, res);
       
       res = vrep.simxPauseCommunication(id, false); vrchk(vrep, res);
       
       % Make sure that we do not go faster that the simulator
       elapsed = toc;
       timeleft = timestep-elapsed;
       if (timeleft > 0),
           pause(min(timeleft, .01));
       end
       
   end
   
  

end
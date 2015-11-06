function summitXL()
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
   
   h = summitXL_init(vrep, id);
   joy = vrjoystick(1);
   
   pause(.2);
   timestep = .05;
   
   summit_xl_d_tracks_m =  1.00;
   k1 = 5.0;
   
   disp('Starting robot');
   
   
   while (button(joy,1) == 0)
       tic
       % Update wheel velocities
       res = vrep.simxPauseCommunication(id, true); vrchk(vrep, res);
       
       linear_vel = axis(joy,1);
       angular_vel = axis(joy,2);
       dUl = linear_vel - 0.5 * summit_xl_d_tracks_m * angular_vel;
       dUr = linear_vel + 0.5 * summit_xl_d_tracks_m * angular_vel;
       flw = k1 * dUl;
       frw = - k1 * dUr;
       rlw = k1 * dUl;
       rrw = - k1 * dUr;
       
       vrep.simxSetJointTargetVelocity(id, h.wheelJoints(1),flw,vrep.simx_opmode_oneshot); vrchk(vrep, res);
       vrep.simxSetJointTargetVelocity(id, h.wheelJoints(2),frw,vrep.simx_opmode_oneshot); vrchk(vrep, res);
       vrep.simxSetJointTargetVelocity(id, h.wheelJoints(3),rlw,vrep.simx_opmode_oneshot); vrchk(vrep, res);
       vrep.simxSetJointTargetVelocity(id, h.wheelJoints(4),rrw,vrep.simx_opmode_oneshot); vrchk(vrep, res);
       
       res = vrep.simxPauseCommunication(id, false); vrchk(vrep, res);
       
       % Make sure that we do not go faster that the simulator
       elapsed = toc;
       timeleft = timestep-elapsed;
       if (timeleft > 0),
           pause(min(timeleft, .01));
       end
       
   end
   
  

end
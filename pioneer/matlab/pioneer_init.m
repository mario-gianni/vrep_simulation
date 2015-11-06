function handles = pioneer_init(vrep, id)

% (C) Copyright Renaud Detry 2013.
% Distributed under the GNU General Public License.
% (See http://www.gnu.org/copyleft/gpl.html)

% Retrieve all handles, and stream arm and wheel joints, the robot's pose,
% the Hokuyo, and the arm tip pose.

handles = struct('id', id);

wheelJoints = [-1,-1];
[res wheelJoints(1)] = vrep.simxGetObjectHandle(id, 'Pioneer_p3dx_leftMotor', vrep.simx_opmode_oneshot_wait); vrchk(vrep, res);
[res wheelJoints(2)] = vrep.simxGetObjectHandle(id, 'Pioneer_p3dx_rightMotor', vrep.simx_opmode_oneshot_wait); vrchk(vrep, res);

handles.wheelJoints = wheelJoints;

% The Hokuyo sensor is implemented with two planar sensors that each cover 120 degrees:
[res hokuyo1] = vrep.simxGetObjectHandle(id, 'fastHokuyo_sensor1', vrep.simx_opmode_oneshot_wait); vrchk(vrep, res);
[res hokuyo2] = vrep.simxGetObjectHandle(id, 'fastHokuyo_sensor2', vrep.simx_opmode_oneshot_wait); vrchk(vrep, res);

handles.hokuyo1 = hokuyo1;
handles.hokuyo2 = hokuyo2;

% Pan-Tilt
[res pan] = vrep.simxGetObjectHandle(id, 'Pan', vrep.simx_opmode_oneshot_wait); vrchk(vrep, res);
[res tilt] = vrep.simxGetObjectHandle(id, 'Tilt', vrep.simx_opmode_oneshot_wait); vrchk(vrep, res);

handles.pan = pan;
handles.tilt = tilt;

% Kinect
[res depthCam] = vrep.simxGetObjectHandle(id, 'kinect_visionSensor', vrep.simx_opmode_oneshot_wait); vrchk(vrep, res);
[res colorCam] = vrep.simxGetObjectHandle(id, 'kinect_camera', vrep.simx_opmode_oneshot_wait); vrchk(vrep, res);

handles.depthCam = depthCam;
handles.colorCam = colorCam;

[res ref] = vrep.simxGetObjectHandle(id, 'pioneer_center', vrep.simx_opmode_oneshot_wait); vrchk(vrep, res);
handles.ref = ref;

% Stream weel angles
res = vrep.simxGetJointPosition(id, wheelJoints(1), vrep.simx_opmode_streaming); vrchk(vrep, res, true);
res = vrep.simxGetJointPosition(id, wheelJoints(2), vrep.simx_opmode_streaming); vrchk(vrep, res, true);

% Stream robot pose
res = vrep.simxGetObjectPosition(id, ref, -1, vrep.simx_opmode_streaming); vrchk(vrep, res, true);
res = vrep.simxGetObjectOrientation(id, ref, -1, vrep.simx_opmode_streaming); vrchk(vrep, res, true);

% Stream hokuyo data
res = vrep.simxReadVisionSensor(id, hokuyo1, vrep.simx_opmode_streaming); vrchk(vrep, res, true);
res = vrep.simxReadVisionSensor(id, hokuyo2, vrep.simx_opmode_streaming); vrchk(vrep, res, true);

end
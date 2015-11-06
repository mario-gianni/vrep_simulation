function handles = summitXL_init(vrep, id)

% (C) Copyright Renaud Detry 2013.
% Distributed under the GNU General Public License.
% (See http://www.gnu.org/copyleft/gpl.html)

% Retrieve all handles, and stream arm and wheel joints, the robot's pose,
% the Hokuyo, and the arm tip pose.

handles = struct('id', id);

wheelJoints = [-1,-1,-1,-1];
[res wheelJoints(1)] = vrep.simxGetObjectHandle(id, 'joint_front_left_wheel', vrep.simx_opmode_oneshot_wait); vrchk(vrep, res);
[res wheelJoints(2)] = vrep.simxGetObjectHandle(id, 'joint_front_right_wheel', vrep.simx_opmode_oneshot_wait); vrchk(vrep, res);
[res wheelJoints(3)] = vrep.simxGetObjectHandle(id, 'joint_back_left_wheel', vrep.simx_opmode_oneshot_wait); vrchk(vrep, res);
[res wheelJoints(4)] = vrep.simxGetObjectHandle(id, 'joint_back_right_wheel', vrep.simx_opmode_oneshot_wait); vrchk(vrep, res);

handles.wheelJoints = wheelJoints;

end
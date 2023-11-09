
% SPDX-FileCopyrightText: Fondazione Istituto Italiano di Tecnologia
%
% SPDX-License-Identifier: BSD-3-Clause

function [muscleLength, muscleVelocity, framePos1, framePos2] = ...
    computeMusculotendonKinematics(s, ds, baseVelocity, kinDynComputation, gravity, W_T_B, muscleFrames)
%COMPUTEMUSCULOTENDONKINEMATICS computes the length and the velocity of the muscle.
%
% Legend:
% s, number of joints
% m, number of muscles
%
% INPUT:
% - s : joint position vector (s x 1),
% - ds : joint velocity vector (s x 1)
% - baseVelocity : base velocity vector (6 x 1)
% - kinDynComputation : iDynTreeKinematics and dynamics computation helper
% - gravity : gravity as iDynTree.Vector3
% - W_T_B : iDynTree transform of the base w.r.t. the world
% - muscleFrames : cell array (m x 2)
%
% OUTPUT:
% - muscleLength : muscle length vector (m x 1)
% - muscleVelocity : muscle velocity vector (m x 1)
% - kinDynComputation : updated iDynTreeKinematics and dynamics computation helper
% - framePos1 : cell array of muscles frame position (m x 2)

%% Initialize variables
nrOfMuscles    = size(muscleFrames,1);
muscleLength   = zeros(nrOfMuscles,1);
muscleVelocity = zeros(nrOfMuscles,1);
framePos1      = cell(nrOfMuscles, 1);
framePos2      = cell(nrOfMuscles, 1);

% Prepare iDynTree objects
s_iDynTree  = iDynTree.JointPosDoubleArray(kinDynComputation.model);
ds_iDynTree = iDynTree.JointDOFsDoubleArray(kinDynComputation.model);
baseVelocity_iDynTree = iDynTree.Twist();

%% Compute quantities throught time points
% Fill iDynTree objects
s_iDynTree.fromMatlab(s);
ds_iDynTree.fromMatlab(ds);
baseVelocity_iDynTree.fromMatlab(baseVelocity);

% Update robot state
kinDynComputation.setRobotState(W_T_B, s_iDynTree, baseVelocity_iDynTree, ds_iDynTree, gravity);

for muscleIdx = 1 : nrOfMuscles
    % Compute muscle frames position w.r.t. G
    G_T_frame1 = kinDynComputation.getWorldTransform(muscleFrames{muscleIdx,1});
    G_pos_frame1 = G_T_frame1.getPosition.toMatlab;
    framePos1{muscleIdx,1} = G_pos_frame1;
    G_pos_frame2 = kinDynComputation.getWorldTransform(muscleFrames{muscleIdx,2}).getPosition.toMatlab;
    framePos2{muscleIdx,1} = G_pos_frame2;

    % Compute length
    frame1_T_frame2_idynTree = kinDynComputation.getRelativeTransform(muscleFrames{muscleIdx,1}, muscleFrames{muscleIdx,2});
    frame1_pos_frame2 = frame1_T_frame2_idynTree.getPosition.toMatlab;
    muscleLength(muscleIdx) = norm(frame1_pos_frame2);

    % Compute velocity
    G_R_frame1 = G_T_frame1.getRotation.toMatlab;
    G_vel_frame1 = kinDynComputation.getFrameVel(muscleFrames{muscleIdx,1}).toMatlab();
    G_vel_frame2 = kinDynComputation.getFrameVel(muscleFrames{muscleIdx,2}).toMatlab();
    diff_vel = G_vel_frame2 - G_vel_frame1;
    muscleVelocity(muscleIdx) = ((G_R_frame1 * frame1_pos_frame2)' * (diff_vel(1:3,:)))/muscleLength(muscleIdx) ;
end
end


% SPDX-FileCopyrightText: Fondazione Istituto Italiano di Tecnologia
%
% SPDX-License-Identifier: BSD-3-Clause

function [W_T_base] = computeBaseTransformWrtWorld(synchroKin)
%COMPUTEBASETRANSFORMWRTWORLD computes the iDynTree transform of the base
% expressed w.r.t. the world frame.

for lenIdx = 1 : length(synchroKin.timestamp)
    % rotation
    W_T_b_rot = iDynTree.Rotation();
    W_T_b_rot_fromQuaternion = quat2Mat(synchroKin.base.orientation(:,lenIdx));
    W_T_b_rot.fromMatlab(W_T_b_rot_fromQuaternion);
    % position
    W_T_b_pos = iDynTree.Position();
    W_T_b_pos.fromMatlab(synchroKin.base.position(:,lenIdx)); % in m
    % transform
    W_T_base{lenIdx,1} = iDynTree.Transform(W_T_b_rot, W_T_b_pos);
end

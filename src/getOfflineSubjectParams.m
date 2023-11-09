
% SPDX-FileCopyrightText: Fondazione Istituto Italiano di Tecnologia
%
% SPDX-License-Identifier: BSD-3-Clause

function [subjectParams] = getOfflineSubjectParams(muscleNames, trialsMVC, kinDynComputation, paths, muscleToModelInfo)
%GETOFFLINESUBJECTPARAMS computes subject-specific parameters used for
% analysis normalization.  The entry point is to consider those trials
% acquired with EMG in Maximum Voluntary Contraction (MVC) condition.
%
% INPUT:
% - muscleNames : cell array of muscle names
% - trialsMVC : number of trials acquired in MVC condition
% - kinDynComputation : iDynTree object for kinematics
% - paths : path to analysis folders
% - muscleToModelInfo : struct with model info
%
% OUTPUT:
% - subjectParams : struct with computed parameters for analysis normalization

%% Preliminaries
nrOfMuscles = length(muscleNames);
GRAVITY = iDynTree.Vector3();
GRAVITY.zero();
W_T_B = iDynTree.Transform.Identity();

%% Compute MVC values for EMGs normalization
subjectParams.MVC = zeros(nrOfMuscles,1);
for muscleIdx = 1 : nrOfMuscles
    trialPath = fullfile(paths.pathToSubject,sprintf('Trial%d/data/emg/emg.tdf',trialsMVC(muscleIdx)));

    [~, ~, ~, emgDataMVC.labels, emgDataMVC.raw] = tdfReadDataEmg(trialPath);
    emgDataMVC.labels = cellstr(emgDataMVC.labels);

    for emgIdx = 1 : size(emgDataMVC.labels,1)
        if strcmp(emgDataMVC.labels(emgIdx), muscleNames{muscleIdx})
            subjectParams.MVC(muscleIdx) = max(abs(emgDataMVC.raw(emgIdx,:)));
        end
    end
end

%% Compute l_O_M from MVC trials for length normalization
subjectParams.l_0_M = zeros(nrOfMuscles, 1);
for muscleIdx = 1 : nrOfMuscles
    humanDataPath = fullfile(paths.pathToSubject,sprintf('Trial%d/data/kinematics/human_data.mat',trialsMVC(muscleIdx)));
    masterFileKinematics = load(humanDataPath);

    s = squeeze(masterFileKinematics.human_data.human_state.joint_positions.data);
    ds = zeros(size(s,1),1);
    muscleFrames = [muscleToModelInfo.frame1(muscleIdx,:), muscleToModelInfo.frame2(muscleIdx,:)];
    muscleLength = zeros(size(s,2),1);

    for sIdx = 1 : size(s,2)
        [muscleLength(sIdx,1),~,~,~] = computeMusculotendonKinematics(s(:,sIdx), ds, zeros(6,1), kinDynComputation, GRAVITY, W_T_B, muscleFrames);
    end
    subjectParams.l_0_M(muscleIdx,1) = mean(muscleLength);
end

% Validity check
if ~(all(subjectParams.MVC))
    error('Cannot find MVC for all the muscles!');
end
end

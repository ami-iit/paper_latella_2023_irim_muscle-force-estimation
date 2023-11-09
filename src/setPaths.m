
% SPDX-FileCopyrightText: Fondazione Istituto Italiano di Tecnologia
%
% SPDX-License-Identifier: BSD-3-Clause

function [paths] = setPaths(experiment_dir, subjectID, trialID)
%SETPATHS sets experiment paths
%
% INPUT:
% - experiment_dir : path to experiment directory
% - subjectID : subject id
% - trialID: trial id
%
% OUTPUT:
% - paths : path to analysis folders

%% Set paths
paths.datasetRoot         = fullfile(pwd, experiment_dir);
paths.pathToSubject       = fullfile(paths.datasetRoot , sprintf('S%02d',subjectID));
paths.pathToURDF          = fullfile(paths.pathToSubject,'urdf');
paths.pathToTrial         = fullfile(paths.pathToSubject, sprintf('Trial%d',trialID));
paths.pathToRawData       = fullfile(paths.pathToTrial, 'data');
paths.pathToiFeel         = fullfile(paths.pathToRawData, 'wearable');
paths.pathToEmg           = fullfile(paths.pathToRawData, 'emg');
paths.pathToKinematics    = fullfile(paths.pathToRawData, 'kinematics');
end

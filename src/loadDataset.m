
% SPDX-FileCopyrightText: Fondazione Istituto Italiano di Tecnologia
%
% SPDX-License-Identifier: BSD-3-Clause

function [dataset] = loadDataset(paths, muscleNames, jointNames, subjectParams)
%LOADDATASET loads a dataset with human kinematics data (acquired via
% nodes) and EMGs data.
%
% INPUT:
% - paths : path to analysis folders
% - muscleNames : cell array of muscle names
% - jointNames :
% - subjectParams : struct with computed parameters for analysis normalization
%
% OUTPUT:
% - dataset : struct with at least the following fields:
%    - jointKinematics : data of human kinematics
%    - muscle data : raw data from EMG acquisition including also their
%      filtering, rectification, normalization to Maximum Voluntary
%      Contraction (MVC), and envelope.

%% Load human kinematics
masterFileKinematics = load(fullfile(paths.pathToKinematics,'human_data.mat'));

% Squeeze base data
dataset.jointKinematics.base.position    = squeeze(masterFileKinematics.human_data.human_state.base_position.data);
dataset.jointKinematics.base.velocity6D  = squeeze(masterFileKinematics.human_data.human_state.base_velocity.data);
dataset.jointKinematics.base.orientation = squeeze(masterFileKinematics.human_data.human_state.base_orientation.data);
% Squeeze joint quantities
dataset.jointKinematics.s   = squeeze(masterFileKinematics.human_data.human_state.joint_positions.data);
dataset.jointKinematics.ds  = squeeze(masterFileKinematics.human_data.human_state.joint_velocities.data);
dataset.jointKinematics.dds = zeros(size(dataset.jointKinematics.s));

% Get time information
dataset.jointKinematics.timestamp          = masterFileKinematics.human_data.human_state.joint_positions.timestamps;
dataset.jointKinematics.totalDurationInSec = dataset.jointKinematics.timestamp(end) - dataset.jointKinematics.timestamp(1); % in sec
diff_timestamp                             = diff(dataset.jointKinematics.timestamp);
dataset.jointKinematics.samplingTime       = mean(diff_timestamp); % sampling time
dataset.jointKinematics.samplingFrequency  = floor(1/dataset.jointKinematics.samplingTime); % approx sampling frequency

% Get joint names
dataset.jointKinematics.names = jointNames;

%% Load EMGs
pathTodataset.emgData = fullfile(paths.pathToTrial,'data/emg/emg.tdf');
[emgData.startTime,emgData.frequency,emgData.emgMap,emgData.labels,emgData.raw] = ...
    tdfReadDataEmg(pathTodataset.emgData);
emgData.labels = cellstr(emgData.labels);

nrOfEMGs = size(emgData.labels,1);
nrOfMuscles = length(muscleNames);
emgToMuscles = zeros(nrOfEMGs,1);
for muscleIdx = 1 : nrOfMuscles
    for emgIdx = 1 : size(emgData.labels,1)
        if strcmp(emgData.labels(emgIdx), muscleNames{muscleIdx})
            emgToMuscles(emgIdx) = muscleIdx;
        end
    end
end

% Validity check
if ~(sum(emgToMuscles>0)==nrOfMuscles)
    error('Cannot find EMGs for all the muscles!');
end

% Select and reorder rows

mappedIdx = emgToMuscles(emgToMuscles>0);
dataset.muscleData.raw = emgData.raw(emgToMuscles>0, :);
dataset.muscleData.raw = dataset.muscleData.raw(mappedIdx,:);

% Bandpass filtering
filterOrder = 4;
[a,b] = butter(filterOrder, [20,450]/(emgData.frequency/2), 'bandpass');
dataset.muscleData.filtered = filter(a,b,dataset.muscleData.raw,[],2);
% Rectification
dataset.muscleData.rectified = abs(dataset.muscleData.filtered);
% Normalization to MVC
dataset.muscleData.normalizedMVC = dataset.muscleData.rectified ./ subjectParams.MVC;
% Smoothing
cutOffFrequency = 10; % cut-off frequency
[a,b] = butter(filterOrder, cutOffFrequency/(emgData.frequency/2), 'low');
dataset.muscleData.envelope = filter(a,b,dataset.muscleData.normalizedMVC,[],2);

% Get time information
dataset.muscleData.samplingFrequency  = emgData.frequency;
dataset.muscleData.timestamp          = (1:1:size(dataset.muscleData.raw,2)) / dataset.muscleData.samplingFrequency;
dataset.muscleData.totalDurationInSec = dataset.muscleData.timestamp(end) - dataset.muscleData.timestamp(1); % in sec
diff_timestamp                        = diff(dataset.muscleData.timestamp);
dataset.muscleData.samplingTime       = mean(diff_timestamp);

% Get muscle names
dataset.muscleData.names = muscleNames;
end

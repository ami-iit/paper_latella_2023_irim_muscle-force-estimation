
% SPDX-FileCopyrightText: Fondazione Istituto Italiano di Tecnologia
%
% SPDX-License-Identifier: BSD-3-Clause

function [synchroData] = synchronizeDataset(dataset, plotFlag)
%SYNCHRONIZEDATASET synchronizes the dataset.
%
% INPUT:
% - dataset : struct with at least the following fields:
%    - jointKinematics : data of human kinematics
%    - muscle data : data from EMG acquisition including raw, filtered,
%      rectified, normalized to MVC, and enveloped signals.
% - plotFlag : flag for synchronization
%
% OUTPUT:
% - synchroData : strcut with synchronized data

%% Find cutting samples for muscle data
muscleDiffVect = diff(dataset.muscleData.envelope,1,2);
thresholdForMVC = 0.0008;

% Initial sample to cut the signal
risingEdges = muscleDiffVect>=thresholdForMVC;
[~, muscle.cut.range.sampleToCut_init] = find(risingEdges, 1, 'first');

% Final sample to cut the signal
fallingEdges = muscleDiffVect<=-thresholdForMVC;
[~, muscle.cut.range.sampleToCut_final] = find(fallingEdges, 1, 'last');

%% Find samples to cut kinematics
kinematicsDiffVect = diff(dataset.jointKinematics.s,1,2);
thresholdInDeg = 0.05;
thresholdInRad = thresholdInDeg * pi/180;

% Initial sample to cut the signal
risingEdges = kinematicsDiffVect>=thresholdInRad;
[risingEdgesJoint, kinematics.cut.range.sampleToCut_init] = find(risingEdges, 1, 'first');

% Final sample to cut the signal
fallingEdges = kinematicsDiffVect<=-thresholdInRad;
[fallingEdgesJoint, kinematics.cut.range.sampleToCut_final] = find(fallingEdges, 1, 'last');

%% Cluster the angles quantities
kinematics.cluster.s           = dataset.jointKinematics.s;
kinematics.cluster.ds          = dataset.jointKinematics.ds;
kinematics.cluster.dds         = dataset.jointKinematics.dds;
kinematics.cluster.orientation = dataset.jointKinematics.base.orientation;
kinematics.cluster.position    = dataset.jointKinematics.base.position;
kinematics.cluster.baseVel     = dataset.jointKinematics.base.velocity6D;

%% Cut non interpolated signals
% Muscle
muscle.cut.cut  = dataset.muscleData.normalizedMVC(:,muscle.cut.range.sampleToCut_init:muscle.cut.range.sampleToCut_final);
muscle.cut.time = dataset.muscleData.timestamp(:,muscle.cut.range.sampleToCut_init:muscle.cut.range.sampleToCut_final);
% Kinematics
kinematics.relativeTimestamp   = dataset.jointKinematics.timestamp - dataset.jointKinematics.timestamp(1);
kinematics.cut.time            = kinematics.relativeTimestamp(:,kinematics.cut.range.sampleToCut_init:kinematics.cut.range.sampleToCut_final);
kinematics.cut.cut_s           = kinematics.cluster.s(:,kinematics.cut.range.sampleToCut_init:kinematics.cut.range.sampleToCut_final);
kinematics.cut.cut_ds          = kinematics.cluster.ds(:,kinematics.cut.range.sampleToCut_init:kinematics.cut.range.sampleToCut_final);
kinematics.cut.cut_dds         = kinematics.cluster.dds(:,kinematics.cut.range.sampleToCut_init:kinematics.cut.range.sampleToCut_final);
kinematics.cut.cut_orientation = kinematics.cluster.orientation(:,kinematics.cut.range.sampleToCut_init:kinematics.cut.range.sampleToCut_final);
kinematics.cut.cut_position    = kinematics.cluster.position(:,kinematics.cut.range.sampleToCut_init:kinematics.cut.range.sampleToCut_final);
kinematics.cut.cut_baseVel     = kinematics.cluster.baseVel(:,kinematics.cut.range.sampleToCut_init:kinematics.cut.range.sampleToCut_final);

%% Downsampling cut signals
if dataset.jointKinematics.samplingFrequency < dataset.muscleData.samplingFrequency
    downsampledMuscleFlag = true;
    disp('[Info]  EMG signals have to be downsampled.');
    toDownsampleTime   = muscle.cut.time;
    toDownsampleSignal = muscle.cut.cut';
    downsamplingTime   = kinematics.cut.time;
    % downsampling
    toDownsampleTime_abs = toDownsampleTime - toDownsampleTime(1);
    downsamplingTime_abs = downsamplingTime - downsamplingTime(1);
    downsampledSignal = interp1(toDownsampleTime_abs, toDownsampleSignal, downsamplingTime_abs)';
    downsampledSignal(isnan(downsampledSignal)) = 0;
else
    downsampledMuscleFlag = false;
    disp('[Info]  Kinematics signals have to be downsampled.');
    toDownsampleTime               = kinematics.cut.time;
    toDownsampleSignal_s           = kinematics.cut.cut_s';
    toDownsampleSignal_ds          = kinematics.cut.cut_ds';
    toDownsampleSignal_dds         = kinematics.cut.cut_ds';
    toDownsampleSignal_orientation = kinematics.cut.cut_orientation';
    toDownsampleSignal_position    = kinematics.cut.cut_position';
    toDownsampleSignal_baseVel     = kinematics.cut.cut_baseVel';
    downsamplingTime               = muscle.cut.time;
    % downsampling
    toDownsampleTime_abs          = toDownsampleTime - toDownsampleTime(1);
    downsamplingTime_abs          = downsamplingTime - downsamplingTime(1);
    downsampledSignal.s           = interp1(toDownsampleTime_abs, toDownsampleSignal_s, downsamplingTime_abs)';
    downsampledSignal.ds          = interp1(toDownsampleTime_abs, toDownsampleSignal_ds, downsamplingTime_abs)';
    downsampledSignal.dds         = interp1(toDownsampleTime_abs, toDownsampleSignal_dds, downsamplingTime_abs)';
    downsampledSignal.orientation = interp1(toDownsampleTime_abs, toDownsampleSignal_orientation, downsamplingTime_abs)';
    downsampledSignal.position    = interp1(toDownsampleTime_abs, toDownsampleSignal_position, downsamplingTime_abs)';
    downsampledSignal.baseVel     = interp1(toDownsampleTime_abs, toDownsampleSignal_baseVel, downsamplingTime_abs)';
    downsampledSignal(isnan(downsampledSignal)) = 0;
end

%% Save synchronize dataset
if downsampledMuscleFlag
    synchroData.muscleData                       = downsampledSignal;
    synchroData.jointKinematics.timestamp        = downsamplingTime;
    synchroData.jointKinematics.s                = kinematics.cut.cut_s;
    synchroData.jointKinematics.ds               = kinematics.cut.cut_ds;
    synchroData.jointKinematics.dds              = kinematics.cut.cut_dds;
    synchroData.jointKinematics.base.orientation = kinematics.cut.cut_orientation;
    synchroData.jointKinematics.base.position    = kinematics.cut.cut_position;
    synchroData.jointKinematics.base.velocity    = kinematics.cut.cut_baseVel;
else
    synchroData.jointKinematics        = downsampledSignal;
    synchroData.dataset.muscleDataData = muscle.cut.cut;
end
synchroData.nrOfSamples  = size(synchroData.jointKinematics.s,2);
synchroData.samplingTime = mean(diff(downsamplingTime));

%% Plots
if plotFlag
    nrOfMuscles = size(synchroData.muscleData,1);

    % Find the the most representative joints
    if risingEdgesJoint == fallingEdgesJoint
        representativeJoints = risingEdgesJoint;
    else
        representativeJoints = [risingEdgesJoint, fallingEdgesJoint];
    end
    nrOfJoints = length(representativeJoints);
    nrOfPlotRows = nrOfMuscles + nrOfJoints;
    nrOfPlotCols = 3;
    
    figure('Name', 'Synchronized data','NumberTitle','off');

    % MUSCLES
    for muscleIdx = 1 : nrOfMuscles
        % original
        MVCplotIdx = (muscleIdx-1) * nrOfPlotCols + 1;
        subplot(nrOfPlotRows,nrOfPlotCols,MVCplotIdx)
        plot(dataset.muscleData.envelope(muscleIdx,:))
        hold on
        plot(muscle.cut.range.sampleToCut_init,0, 'or', LineWidth=30) % init point to cut
        hold on
        plot(muscle.cut.range.sampleToCut_final,0, 'or', LineWidth=30) % final point to cut
        if muscleIdx == 1
            title('Original','Fontsize', 22)
        end
        xlabel('Samples','FontSize',18);
        ylabel('% MVC', 'Fontsize', 18);
        leg = legend(dataset.muscleData.names(muscleIdx),'Location','northeast','FontSize',18);
        axis tight;

        % cut
        MVCplotIdx = MVCplotIdx + 1;
        subplot(nrOfPlotRows,nrOfPlotCols,MVCplotIdx)
        plot(toDownsampleTime, toDownsampleSignal(:,muscleIdx));
        if muscleIdx == 1
            title('Cut','Fontsize', 22)
        end
        xlabel('Time [s]','FontSize',18);
        ylabel('% MVC', 'Fontsize', 18);
        leg = legend(dataset.muscleData.names(muscleIdx),'Location','northeast','FontSize',18);
        axis tight;

        % downsampled
        MVCplotIdx = MVCplotIdx + 1;
        subplot(nrOfPlotRows,nrOfPlotCols,MVCplotIdx)
        plot(downsamplingTime, downsampledSignal(muscleIdx,:));
        if muscleIdx == 1
            title('Downsampled','Fontsize', 22)
        end
        xlabel('Time [s]','FontSize',18);
        ylabel('% MVC', 'Fontsize', 18);
        leg = legend(dataset.muscleData.names(muscleIdx),'Location','northeast','FontSize',18);
        axis tight;
    end

    % JOINTS
    for representativeJointsIdx = 1 : nrOfJoints
        currentJoint = representativeJoints(representativeJointsIdx);
        % original
        jointPlotIdx = (nrOfMuscles + representativeJointsIdx - 1) * nrOfPlotCols + 1;
        subplot(nrOfPlotRows,nrOfPlotCols,jointPlotIdx)
        plot(dataset.jointKinematics.s(currentJoint,:)*180/pi)
        hold on
        plot(kinematics.cut.range.sampleToCut_init, ...
            dataset.jointKinematics.s(currentJoint,kinematics.cut.range.sampleToCut_init), 'or', LineWidth=30) % init point to cut
        hold on
        plot(kinematics.cut.range.sampleToCut_final, ...
            dataset.jointKinematics.s(currentJoint,kinematics.cut.range.sampleToCut_final), 'or', LineWidth=30) % final point to cut
        xlabel('Samples','FontSize',18);
        ylabel('Angle [deg]','FontSize',18);
        leg = legend(dataset.jointKinematics.names(currentJoint),'Location','northeast','FontSize',18);
        axis tight;

        % cut
        jointPlotIdx = jointPlotIdx + 1;
        subplot(nrOfPlotRows,nrOfPlotCols,jointPlotIdx)
        plot(kinematics.cut.time,kinematics.cut.cut_s(currentJoint,:)*180/pi);
        xlabel('Time [s]','FontSize',18);
        ylabel('Angle [deg]','FontSize',18);
        leg = legend(dataset.jointKinematics.names(currentJoint),'Location','northeast','FontSize',18);
        axis tight;

        % downsampled
        jointPlotIdx = jointPlotIdx + 1;
        subplot(nrOfPlotRows,nrOfPlotCols,jointPlotIdx)
        plot(kinematics.cut.time,synchroData.jointKinematics.s(currentJoint,:)*180/pi);
        xlabel('Time [s]','FontSize',18);
        ylabel('Angle [deg]','FontSize',18);
        leg = legend(dataset.jointKinematics.names(currentJoint),'Location','northeast','FontSize',18);
        axis tight;
    end
end
end

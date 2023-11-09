
% SPDX-FileCopyrightText: Fondazione Istituto Italiano di Tecnologia
%
% SPDX-License-Identifier: BSD-3-Clause

%% ------------------------------------------------------------------------
%% --------------------------- INITIALIZATION -----------------------------
%% ------------------------------------------------------------------------
% Create mapping between nodes and attached links
ifeelParams = getSensorToLinkMap(NODES_ID, ATTACHED_LINKS);

% Create mapping between muscle frames and attached links
muscleToModelInfo = getMuscleToModelInfo(MUSCLE_NAMES);

%% Initialiaze iDynTree models
disp('-------------------------------------------------------------------');
disp('[Start] URDF model loading...');
modelFilePath = fullfile(paths.pathToURDF, URDF_NAME);
humanModelLoader = iDynTree.ModelLoader();
if ~humanModelLoader.loadReducedModelFromFile(modelFilePath, ...
        cell2iDynTreeStringVector(JOINT_NAMES))
    % here the model loads the same order of JOINT_NAMES.
    error('Something wrong with the model loading.');
end
humanModel = humanModelLoader.model();
disp('[End]   URDF model loading.');

% Build iDynTree object for kinematics
kinDynComputation = iDynTree.KinDynComputations();
kinDynComputation.loadRobotModel(humanModel);

%% Build iDynTree object for visualization
kinDynComputationViz = iDynTreeWrappers.loadReducedModel(JOINT_NAMES, ...
    BASE_NAME, fullfile(paths.pathToURDF, '/'), URDF_NAME, false);
[Visualizer, ~] = iDynTreeWrappers.prepareVisualization(kinDynComputationViz, MESH_FILE_PREFIX);
Visualizer.mainHandler.Name = sprintf("Subject %02d, Trial %02d", SUBJECT_ID, TRIAL_ID);
Visualizer.mainHandler.CurrentAxes.Title.String = "";
% set camera view
view(45,0)
% set background
set(gcf,'color','w');
% set visualization limits and title
xlim([ -1.0  1.0]);
ylim([ -1.0  1.0]);
zlim([ -1.2  1.0]);

viz.muscleLine = cell(length(MUSCLE_NAMES), 1);
for muscleIdx = 1 : length(MUSCLE_NAMES)
    viz.muscleLine{muscleIdx,1}           = line([0 0], [0 0], [0 0]);
    viz.muscleLine{muscleIdx,1}.LineWidth = 5;
    viz.muscleLine{muscleIdx,1}.Color     = [ 0.5020  0.5020  0.5020];
end

%% Load muscle parameters and create a table view
muscleTable  = loadMuscleTable();
muscleParams = getMuscleParams(muscleTable, MUSCLE_NAMES);

% Override table params with subject-specific measured params
subjectParams = getOfflineSubjectParams(MUSCLE_NAMES, OFFLINE_TRIALS_MVC, ...
    kinDynComputation, paths, muscleToModelInfo);
muscleParams.l_0_M = subjectParams.l_0_M;

%% Load and synchronize dataset
disp('-------------------------------------------------------------------');
disp('[Start] Dataset loading ...');
dataset = loadDataset(paths, MUSCLE_NAMES, JOINT_NAMES, subjectParams);
disp('[End]   Dataset loading.');
disp('-------------------------------------------------------------------');
disp('[Start] Data synchronization...');
synchroData = synchronizeDataset(dataset, OPTS.SYNCHDATAPLOT);
disp('[End]   Data synchronization.');

%% Compute the base transform w.r.t. world frame
W_T_B = computeBaseTransformWrtWorld(synchroData.jointKinematics);

%% ------------------------------------------------------------------------
%% ------------------------------- RUNTIME --------------------------------
%% ------------------------------------------------------------------------
disp('-------------------------------------------------------------------');
disp('[Start] Computation of musculoskeletal quantities...');

% Initialize variables
nrOfMuscles = length(MUSCLE_NAMES);
muscle.activation  = zeros(nrOfMuscles,synchroData.nrOfSamples);
muscle.length      = zeros(nrOfMuscles,synchroData.nrOfSamples);
muscle.velocity    = zeros(nrOfMuscles,synchroData.nrOfSamples);
muscle.force       = zeros(nrOfMuscles,synchroData.nrOfSamples);
muscle.framePos1   = cell(nrOfMuscles,synchroData.nrOfSamples);
muscle.framePos2   = cell(nrOfMuscles,synchroData.nrOfSamples);
muscle.l_M_tilde   = zeros(nrOfMuscles,synchroData.nrOfSamples);
muscle.v_M_tilde   = zeros(nrOfMuscles,synchroData.nrOfSamples);
muscle.F_L_CE      = zeros(nrOfMuscles,synchroData.nrOfSamples);
muscle.F_L_PE      = zeros(nrOfMuscles,synchroData.nrOfSamples);
muscle.F_V_CE      = zeros(nrOfMuscles,synchroData.nrOfSamples);
muscle.F_M_active  = zeros(nrOfMuscles,synchroData.nrOfSamples);
muscle.F_M_passive = zeros(nrOfMuscles,synchroData.nrOfSamples);

muscleFrames = [muscleToModelInfo.frame1, muscleToModelInfo.frame2];
muscle.activation(:,1) = synchroData.muscleData(:,1);

for lenIdx = 1 : synchroData.nrOfSamples
    %% ====================================================================
    %% Muscle activation dynamics
    % The nervous system generates muscle stimulation signals over time u(t),
    % measured by EMG. Due to biochemical processes, these muscle stimulations
    % lead to muscle activities $a(t)$.
    if lenIdx > 1
        muscle.activation(:,lenIdx) = computeActivationDynamics(synchroData.muscleData(:,lenIdx), ...
            muscle.activation(:, lenIdx-1), synchroData.samplingTime, muscleParams);
    end

    %% ====================================================================
    %% Musculotendon kinematics
    % Modelling the kinematics of the musculotendon element: from the joint
    % kinematics to length and velocity of the muscle.
    [muscle.length(:,lenIdx), muscle.velocity(:,lenIdx), muscle.framePos1(:,lenIdx), muscle.framePos2(:,lenIdx)] = ...
        computeMusculotendonKinematics(synchroData.jointKinematics.s(:,lenIdx), ...
        synchroData.jointKinematics.ds(:,lenIdx), synchroData.jointKinematics.base.velocity(:,lenIdx), ...
        kinDynComputation, GRAVITY, W_T_B{lenIdx}, muscleFrames);

    %% ====================================================================
    %% Muscle contraction dynamics
    % Modelling the musculotendon dynamics: from activation to force production.
    [muscle.force(:,lenIdx), muscle.l_M_tilde(:,lenIdx), muscle.v_M_tilde(:,lenIdx), muscle.F_L_CE(:,lenIdx), ...
        muscle.F_L_PE(:,lenIdx), muscle.F_V_CE(:,lenIdx), muscle.F_M_active(:,lenIdx), muscle.F_M_passive(:,lenIdx)] = ...
        computeContractionDynamics(muscle.length(:,lenIdx), muscle.velocity(:,lenIdx), muscle.activation(:,lenIdx), muscleParams);
end
disp('[End]   Computation of musculoskeletal quantities.');

%% Plot estimated quantities
plotMusculoskeletalQuantities;

%% Muscle visualization
if OPTS.MUSCULOSKELETONVIZ
    muscle.maxForce = prctile(muscle.force, 98, 2);
    muscle.minForce = 0;

    for lenIdx = 1 : synchroData.nrOfSamples
        tic;
        % Update kinematics
        iDynTreeWrappers.setRobotState(kinDynComputationViz, ...
            W_T_B{lenIdx,1}.asHomogeneousTransform.toMatlab, ...
            synchroData.jointKinematics.s(:,lenIdx), ...
            synchroData.jointKinematics.base.velocity(:,lenIdx), ...
            synchroData.jointKinematics.ds(:,lenIdx), ...
            GRAVITY.toMatlab);
        iDynTreeWrappers.updateVisualization(kinDynComputationViz, Visualizer);

        % Update muscles
        for muscleIdx = 1 : length(MUSCLE_NAMES)
            tmp.value = max(0, muscle.force(muscleIdx,lenIdx));
            tmp.color = [min(tmp.value/muscle.maxForce(muscleIdx,1),1), max(1 - min(tmp.value/muscle.maxForce(muscleIdx,1),1),0), 0];

            viz.muscleLine{muscleIdx,1}.XData = [muscle.framePos1{muscleIdx,lenIdx}(1) muscle.framePos2{muscleIdx,lenIdx}(1)];
            viz.muscleLine{muscleIdx,1}.YData = [muscle.framePos1{muscleIdx,lenIdx}(2) muscle.framePos2{muscleIdx,lenIdx}(2)];
            viz.muscleLine{muscleIdx,1}.ZData = [muscle.framePos1{muscleIdx,lenIdx}(3) muscle.framePos2{muscleIdx,lenIdx}(3)];
            viz.muscleLine{muscleIdx,1}.Color = tmp.color;
        end
        drawnow;
    end
end

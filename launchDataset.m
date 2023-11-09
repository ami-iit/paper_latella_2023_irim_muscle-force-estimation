
% SPDX-FileCopyrightText: Fondazione Istituto Italiano di Tecnologia
%
% SPDX-License-Identifier: BSD-3-Clause

%% Preliminaries
clc; clear all; close all;
rng(1); % force the casual generator to be const
format long;

addpath(genpath('src'));
addpath(genpath('plot'));
addpath(genpath('external'));

%% Define experiment variables
EXPERIMENT_DIR = 'dataset';
SUBJECT_ID = 1;

% Create a dialog box for user choice of the TRIAL_ID
prompt = {'Type a number of trial present in the dataset, e.g., 5:'};
dlgtitle = 'TRIAL ID user choice';
userAnswer = inputdlg(prompt, dlgtitle,[1 80]);
TRIAL_ID = str2double(cell2mat(userAnswer));

MUSCLE_NAMES = {
    'Right Tibialis anterior', ...
    'Right Gastrocnemius lateralis', ...
    'Right Gastrocnemius medialis'};
OFFLINE_TRIALS_MVC = [1, 3, 3];

JOINT_NAMES = {
    'jRightHip_rotx'; ...
    'jRightHip_roty'; ...
    'jRightHip_rotz'; ...
    'jRightKnee_roty'; ...
    'jRightKnee_rotz'; ...
    'jRightAnkle_rotx'; ...
    'jRightAnkle_roty'; ...
    'jRightAnkle_rotz'};

NODES_ID = [3; 5; 7];
ATTACHED_LINKS = [
    "RightFoot"; ...
    "RightLowerLeg"; ...
    "RightUpperLeg"];

URDF_NAME = sprintf(('URDF_subj0%d.urdf'), SUBJECT_ID);
BASE_NAME = 'Pelvis';
GRAVITY = iDynTree.Vector3();
GRAVITY.fromMatlab([0, 0, -9.81]);
MESH_FILE_PREFIX ='meshes/';

%% Define paths
paths = setPaths(EXPERIMENT_DIR, SUBJECT_ID, TRIAL_ID);

%% Define options
OPTS.SYNCHDATAPLOT      = false;
OPTS.PLOTSAVEON         = false;
OPTS.MUSCULOSKELETONVIZ = true;

%% Launch main
disp(' ');
disp('=====================================================================');
fprintf('[Start] Analysis SUBJECT_%02d, TRIAL_%d\n', SUBJECT_ID, TRIAL_ID);
main;
fprintf('[End]   Analysis SUBJECT_%02d, TRIAL_%d\n', SUBJECT_ID, TRIAL_ID);
disp('=====================================================================');


% SPDX-FileCopyrightText: Fondazione Istituto Italiano di Tecnologia
%
% SPDX-License-Identifier: BSD-3-Clause

function [muscleToModelInfo] = getMuscleToModelInfo(muscleNames)
%GETMUSCLEMODELINFO returns a struct with model info.
%
% INPUT:
% - muscleFrames : cell array of muscle names
% - completeModelInfo : cell ordered as: 
%   muscle name, frame 1, frame 2, link 1, link 2
%
% OUTPUT:
% - muscleToModelInfo : struct with model info

%% Model info with the following order: muscle name, frame 1, frame 2, link 1, link 2
completeModelInfo = { ...
    'Right Tibialis anterior', 'TIBANT_RLL', 'TIBANT_RF', 'RightLowerLeg', 'RightFoot'; ...
    'Right Gastrocnemius lateralis', 'LATGAS_RUL', 'LATGAS_RF', 'RightUpperLeg', 'RightFoot'; ...
    'Right Gastrocnemius medialis', 'MEDGAS_RUL', 'MEDGAS_RF', 'RightUpperLeg', 'RightFoot'; ...
    'Left Tibialis anterior', 'TIBANT_LLL', 'TIBANT_LF', 'LeftLowerLeg', 'LeftFoot'; ...
    'Left Gastrocnemius lateralis', 'LATGAS_LUL', 'LATGAS_LF', 'LeftUpperLeg', 'LeftFoot'; ...
    'Left Gastrocnemius medialis', 'MEDGAS_LUL', 'MEDGAS_LF', 'LeftUpperLeg', 'LeftFoot'};

%% Initialize variables
nrOfMuscles = length(muscleNames);
muscleToModelInfo.frame1 = cell(nrOfMuscles,1);
muscleToModelInfo.frame2 = cell(nrOfMuscles,1);
muscleToModelInfo.link1  = cell(nrOfMuscles,1);
muscleToModelInfo.link2  = cell(nrOfMuscles,1);

%% Build struct
for muscleIdx = 1 : nrOfMuscles
    indexInTable = 0;
    for paramsIdx = 1 : size(completeModelInfo,1)
        if strcmp(muscleNames(muscleIdx), completeModelInfo(paramsIdx,1))
            indexInTable = paramsIdx;
        end
    end
    % Validity check
    if indexInTable == 0
        error(sprintf('No entry in table associated to the muscle %s!', char(muscleNames(muscleIdx))));
    end
    
    % Assign values to variables
    muscleToModelInfo.frame1(muscleIdx) = completeModelInfo(indexInTable,2);
    muscleToModelInfo.frame2(muscleIdx) = completeModelInfo(indexInTable,3);
    muscleToModelInfo.link1(muscleIdx)  = completeModelInfo(indexInTable,4);
    muscleToModelInfo.link2(muscleIdx)  = completeModelInfo(indexInTable,5);
end
end

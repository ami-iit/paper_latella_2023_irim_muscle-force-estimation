
% SPDX-FileCopyrightText: Fondazione Istituto Italiano di Tecnologia
%
% SPDX-License-Identifier: BSD-3-Clause

function [muscleParams] = getMuscleParams(muscleTable, muscleNames)
%GETMUSCLEPARAMS returns a view of the muscle parameters loaded from muscle
% table.
%
% INPUT:
% - muscleTable : table of the muscle parameters from literature
% - muscleNames : cell array of muscle names
%
% OUTPUT:
% - muscleParams : struct of a view of the muscle parameters

%% Initialize variables
nrOfMuscles = length(muscleNames);
muscleParams.alfa_0 = zeros(nrOfMuscles,1);
muscleParams.c1     = zeros(nrOfMuscles,1);
muscleParams.c2     = zeros(nrOfMuscles,1);
muscleParams.l_0_M  = zeros(nrOfMuscles,1);
muscleParams.gamma  = zeros(nrOfMuscles,1);
muscleParams.KCE1   = zeros(nrOfMuscles,1);
muscleParams.KCE2   = zeros(nrOfMuscles,1);
muscleParams.F_0_M  = zeros(nrOfMuscles,1);
muscleParams.Fv_max = zeros(nrOfMuscles,1);
muscleParams.time_c = zeros(nrOfMuscles,1);

%% Build struct
for muscleIdx = 1 : nrOfMuscles
    indexInTable = 0;
    for paramsIdx = 1 : size(muscleTable,1)
        if strcmp(muscleNames(muscleIdx), muscleTable.Muscle(paramsIdx))
            indexInTable = paramsIdx;
        end
    end

    % Validity check
    if indexInTable == 0
        error(sprintf('No entry in table associated to the muscle %s!', char(muscleNames(muscleIdx))));
    end

    % Assign values to variables
    muscleParams.alfa_0(muscleIdx) = str2double(muscleTable.alfa_0(indexInTable));
    muscleParams.c2(muscleIdx)     = 1/str2double(muscleTable.time_deact(indexInTable));
    muscleParams.c1(muscleIdx)     = 1/str2double(muscleTable.time_act(indexInTable)) - muscleParams.c2(muscleIdx);
    muscleParams.l_0_M(muscleIdx)  = str2double(muscleTable.l_0_M_meas(indexInTable));
    muscleParams.gamma(muscleIdx)  = str2double(muscleTable.gamma(indexInTable));
    muscleParams.KCE1(muscleIdx)   = str2double(muscleTable.KCE1(indexInTable));
    muscleParams.KCE2(muscleIdx)   = str2double(muscleTable.KCE2(indexInTable));
    muscleParams.F_0_M(muscleIdx)  = str2double(muscleTable.F_0_M(indexInTable));
    muscleParams.Fv_max(muscleIdx) = str2double(muscleTable.Fv_max(indexInTable));
    muscleParams.time_c(muscleIdx) = str2double(muscleTable.time_c(indexInTable));
end
end

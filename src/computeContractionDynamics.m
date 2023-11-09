
% SPDX-FileCopyrightText: Fondazione Istituto Italiano di Tecnologia
%
% SPDX-License-Identifier: BSD-3-Clause

function [muscleForce, l_M_tilde, v_M_tilde, F_L_CE, F_L_PE, F_V_CE, F_M_active, F_M_passive] = ....
    computeContractionDynamics(muscleLength, muscleVelocity, muscleActivation, muscleParams)
%COMPUTECONTRACTIONDYNAMICS computes the dynamics of the force for the
% specified musculotendon complex.
% Equations source:[Romero & Alonso, 2016].
%
% INPUT:
% - muscleLength : muscle length vector (m x 1)
% - muscleVelocity : muscle velocity vector (m x 1)
% - a: muscle activation vector (m x 1)
% - muscelParams : struct with the following fields:
%    - v_max : max muscle velocity vector in [m/s]
%    - l_0_M : optimal fiber length vector in [m]
%    - gamma : half-width of 1/exp(.) curve vector
%    - KCE1 : force-velocity shape factor vector
%    - KCE2 : force-velocity shape factor vector
%    - F_0_M : peak isometric force vector in [N]
%    - alfa_0 : pennation angle at optimal length vector in [rad]
%    - Fv_max : peak nomalized force when lengthening vector in [N]
%
% OUTPUT:
% - muscleForce : muscle force vector in [N]
%    - l_M_tilde : normalized muscle length vector
%    - v_M_tilde : normalized muscle velocity vector
%    - F_L_CE : muscle CE element force-length vector in [N]
%    - F_L_PE : muscle PE element force-length vector in [N]
%    - F_V_CE : muscle force-velocity vector in [N]
%    - F_M_active : active muscle force vector in [N]
%    - F_M_passive : passive muscle force vector in [N]

%% Normalize length and velocity
l_M_tilde = muscleLength ./ muscleParams.l_0_M;
v_M_tilde = muscleVelocity ./ (muscleLength ./ muscleParams.time_c);

%% Compute muscle force-lenght relation
[F_L_CE_nofilt, F_L_PE_nofilt] = computeForcesRelatedToLength(l_M_tilde, muscleParams);

% % TODO: Savitzy-Golay filtering, if needed
% [F_L_CE,~,~] = SgolayFilterAndDifferentiation(Sg.polinomialOrder,Sg.window, ...
%     F_L_CE_nofilt, synchroData.samplingTime);
% [F_L_PE,~,~] = SgolayFilterAndDifferentiation(Sg.polinomialOrder,Sg.window, ...
%     F_L_PE_nofilt, synchroData.samplingTime);

F_L_CE = F_L_CE_nofilt;
F_L_PE = F_L_PE_nofilt;

%% Compute muscle force-velocity relation
F_V_CE_nofilt = computeForcesRelatedToVelocity(v_M_tilde, muscleParams);

% % TODO: Savitzy-Golay filtering, if needed
% [F_V_CE,~,~] = SgolayFilterAndDifferentiation(Sg.polinomialOrder,Sg.window, ...
%     F_V_CE_nofilt, synchroData.samplingTime);

F_V_CE = F_V_CE_nofilt;

%% Compute active/passive muscle forces
% The total force of the musclulotendon system is composed of:
% - active force:      a * F_0_M * F_L_CE * F_V_CE
% - passive force:     F_0_M * F_L_PE

% Active force
F_M_active  =  muscleActivation .* muscleParams.F_0_M .* F_L_CE .* F_V_CE;
% Passive force
F_M_passive = muscleParams.F_0_M .* F_L_PE;

%% Compute totale muscle force
% The total force is: muscleForce = (F_active + F_passive) * cos(pennationAngle)
pennationAngle = asin(muscleParams.l_0_M) .* sin(muscleParams.alfa_0) ./ muscleLength;
muscleForce = (F_M_active + F_M_passive) .* cos(pennationAngle);
end


% SPDX-FileCopyrightText: Fondazione Istituto Italiano di Tecnologia
%
% SPDX-License-Identifier: BSD-3-Clause

function [muscleTable] = loadMuscleTable()
%LOADMUSCLEPARAMS returns a table of the muscle parameters from literature.
% Literature provides tabulated parameters as follows: 
%
% | Parameter  | Description                               |
% ----------------------------------------------------------
% | F_0_M      | Peak isometric force [N]                  |
% | l_0_M      | Optimal fiber length [m]                  |
% | l_T_slack  | Tendon slack length [m]                   |
% | alfa_0     | Pennation angle at optimal length [deg]   |
% | time_act   | Activation time [s]                       |
% | time_deact | Deactivation time [s]                     |
% | epsilon_T  | Tendon strain (Elongation/Original Length)|
% | K_time     | Time constant [s] (?)                     |
% | gamma      | Half-width of 1/exp(.) curve              |
% | KCE1       | Force-velocity shape factor               |
% | KCE2       | Force-velocity shape factor               |
% | Fv_max     | Peak nomalized force when lengthening     |
% | time_c     | Time-scaling parameter [s]                |

%% Fill table elements with parameters
Muscle     = ["Right Tibialis anterior"; "Right Gastrocnemius lateralis"; "Right Gastrocnemius medialis"];
F_0_M      = [603.0 "[Delp, 1990]"; 488.0 "[Delp, 1990]"; 1113 "[Delp, 1990]"];
l_0_M_meas = [0.39 ; 0.51 ; 0.475]; % measured reasonable value from specific subject
l_T_slack  = [0.2230 "[Delp, 1990]"; 0.3850 "[Delp, 1990]"; 0.408 "[Delp, 1990]"];
alfa_0     = [5.0 "[Delp, 1990]"; 8.0 "[Delp, 1990]"; 17 "[Delp, 1990]"];
time_act   = [0.068 "[Umberger,2003]"; 0.055 "[Umberger,2003]"; 0.055 "[Umberger,2003]"];
time_deact = [0.080 "[Umberger, 2003]"; 0.065 "[Umberger, 2003]"; 0.065 "[Umberger, 2003]"];
epsilon_T  = [0.02 "[Maganaris, 2002]"; 0.03 "[Maganaris, 2002]"; 0.03 "[Maganaris, 2002]"];
K_time     = [0.02 "[Romero, 2016]"; 0.016 "[Romero, 2016]"; 0.01 "[Romero, 2016]"];
gamma      = [0.6708 "[Thelen, 2003]"; 0.6708 "[Thelen, 2003]"; 0.6708 "[Thelen, 2003]"];
KCE1       = [0.25 "[Thelen, 2003]"; 0.25 "[Thelen, 2003]"; 0.25 "[Thelen, 2003]"];
KCE2       = [0.04 "[Michaud, 2020]"; 0.04 "[Michaud, 2020]"; 0.04 "[Michaud, 2020]"];
Fv_max     = [1.4 "[Thelen, 2003]"; 1.4 "[Thelen, 2003]"; 1.4 "[Thelen, 2003]"];
time_c     = [0.1 "[Ou, 2003]"; 0.1 "[Ou, 2003]"; 0.1 "[Ou, 2003]"];

%% Create table
muscleTable = table(Muscle, F_0_M, l_0_M_meas, l_T_slack, alfa_0, ...
    time_act, time_deact, epsilon_T, K_time, gamma, KCE1, KCE2, Fv_max, time_c);
end

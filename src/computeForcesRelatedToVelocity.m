
% SPDX-FileCopyrightText: Fondazione Istituto Italiano di Tecnologia
%
% SPDX-License-Identifier: BSD-3-Clause

function [F_V_CE] = computeForcesRelatedToVelocity(v_M_tilde, muscleParams)
%COMPUTEFORCESRELATEDTOVELOCITY computes the force-velocity relation for
% the contractile (CE) element.
% Equations source: [Romero & Alonso, 2016].

%% Compute force-velocity for CE
% Condition v_M_tilde <= 1
F_V_CE(v_M_tilde<=-1,1) = 0;

% Condition -1 < v_M_tilde <=0
cond1 = v_M_tilde>-1 & v_M_tilde<=0;
F_V_CE(cond1,1) = (1 + v_M_tilde(cond1,1)) ./ ...
    ((1 - v_M_tilde(cond1,1) ./ muscleParams.KCE1(cond1,1)));

% Condition v_M_tilde > 0
cond2 = v_M_tilde>0;
F_V_CE(cond2,1) = (1 + v_M_tilde(cond2,1) .* muscleParams.Fv_max(cond2,1) ./ ...
    (muscleParams.KCE2(cond2,1))) ./ (1 + v_M_tilde(cond2,1) ./ (muscleParams.KCE2(cond2,1)));
end

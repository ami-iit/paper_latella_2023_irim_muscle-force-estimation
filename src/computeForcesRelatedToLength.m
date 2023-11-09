
% SPDX-FileCopyrightText: Fondazione Istituto Italiano di Tecnologia
%
% SPDX-License-Identifier: BSD-3-Clause

function [F_L_CE, F_L_PE] = computeForcesRelatedToLength(l_M_tilde, muscleParams)
%COMPUTEFORCESRELATEDTOLENGTH computes the force-length relation both for
% the contractile (CE) and parallel (PE) elements.
% Equations source: [Romero & Alonso, 2016].

%% Compute force-length for CE
F_L_CE = exp(- (l_M_tilde - 1).^2 ./ muscleParams.gamma.^2);
% Note: F_L_CE computation differs from source to remove discontinuity.

%% Compute force-length for PE
F_L_PE(l_M_tilde<1,1) = 0;
F_L_PE(l_M_tilde>=1,1) = 4 .* (l_M_tilde(l_M_tilde>=1,1) - 1).^2;
end

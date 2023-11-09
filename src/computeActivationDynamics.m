
% SPDX-FileCopyrightText: Fondazione Istituto Italiano di Tecnologia
%
% SPDX-License-Identifier: BSD-3-Clause

function [a] = computeActivationDynamics(u, aPrev, dt, muscleParams)
%COMPUTEACTIVATIONDYNAMICS computes the muscle activation.
% Equations source: [Nagano & Gerritsen, 2001].
%
% INPUT:
% - u : synchronized (and MVC normalized) measurements vector
% - aPrev : previous muscle activation value
% - dt : time variation w.r.t. previous step
% - muscelParams : struct with at least the following fields:
%    - c2 : coefficient 1/time_deact vector
%    - c1 : coefficient 1/time_act - c2 vector
%
% OUTPUT:
% - a: muscle activation vector (m x 1)

%% Compute muscle activation
da = ((u .* muscleParams.c1) + muscleParams.c2) .* (u - aPrev);
a = da * (dt) + aPrev;
end

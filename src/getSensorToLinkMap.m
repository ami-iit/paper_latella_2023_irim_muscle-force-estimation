
% SPDX-FileCopyrightText: Fondazione Istituto Italiano di Tecnologia
%
% SPDX-License-Identifier: BSD-3-Clause

function [sensor2linkMap] = getSensorToLinkMap(nodeID, attachedLink)
%GETSENSORTOLINKMAP creates a table for mapping nodes ID and links where
% the nodes are attached to.
%
% INPUT:
% - nodeID : node id
% - attachedLink : string array of attached links
%
% OUTPUT:
% - sensor2linkMap : table of mapping

%% Create mapping table
sensor2linkMap = table(nodeID, attachedLink);
end

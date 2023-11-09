
% SPDX-FileCopyrightText: Fondazione Istituto Italiano di Tecnologia
%
% SPDX-License-Identifier: BSD-3-Clause

%% Preliminaries
if OPTS.PLOTSAVEON
    paths.pathToPlots = fullfile(paths.pathToTrial,'/plot');
    if ~exist(paths.pathToPlots)
        mkdir (paths.pathToPlots)
    end
end

%% PLOT 1
% Plot of several computed musculoskeletal quantities:
% activation, normalized length, F_L_CE, normalized velocity, F_V_CE.
fig = figure('Name', sprintf('Musculoskeletal quantities [Subj %02d, Trial %02d]', ...
    SUBJECT_ID, TRIAL_ID),'NumberTitle','off');
axes1 = axes('Parent',fig,'FontSize',16);
box(axes1,'on');
hold(axes1,'on');
grid on;

nrOfrows = 5; % quantities
for muscleIdx = 1 : nrOfMuscles
    % Activation
    subplot(nrOfrows,nrOfMuscles,muscleIdx)
    plot(muscle.activation(muscleIdx,:), 'Linewidth',2, 'Color','r');
    ylabel('$a$', 'interpreter','latex');
    xlabel('sample', 'interpreter','latex');
    title(dataset.muscleData.names(muscleIdx),'Fontsize', 18);
    grid on;
    ax = gca;
    ax.FontSize = 22;
    axis tight;

    % Normalized length
    subplot(nrOfrows,nrOfMuscles,muscleIdx+3)
    plot(muscle.l_M_tilde(muscleIdx,:), 'Linewidth',2);
    ylabel('$\tilde{l}^M$', 'interpreter','latex');
    xlabel('sample', 'interpreter','latex');
    grid on;
    ax = gca;
    ax.FontSize = 22;
    axis tight;

    % F_L_CE
    subplot(nrOfrows,nrOfMuscles,muscleIdx+6)
    plot(muscle.F_L_CE(muscleIdx,:), 'Linewidth',2);
    ylabel('$F^{CE}_L [N]$', 'interpreter','latex');
    xlabel('sample', 'interpreter','latex');
    grid on;
    ax = gca;
    ax.FontSize = 22;
    axis tight;

    % Normalized velocity
    subplot(nrOfrows,nrOfMuscles,muscleIdx+9)
    plot(muscle.v_M_tilde(muscleIdx,:),'Linewidth',2, 'Color','m');
    ylabel('$\tilde{v}^M$', 'interpreter','latex');
    xlabel('sample', 'interpreter','latex');
    grid on;
    ax = gca;
    ax.FontSize = 22;
    axis tight;

    % F_V_CE
    subplot(nrOfrows,nrOfMuscles,muscleIdx+12)
    plot(muscle.F_V_CE(muscleIdx,:), 'Linewidth',2, 'Color','m');
    ylabel('$F^{CE}_V [N]$', 'interpreter','latex');
    xlabel('sample', 'interpreter','latex');
    grid on;
    ax = gca;
    ax.FontSize = 22;
    axis tight;
end

%% PLOT 2
% Plot of muscle comparison of forces (active, passive, total).
fig = figure('Name', sprintf('Musculoskeletal forces [Subj %02d, Trial %02d]', ...
    SUBJECT_ID, TRIAL_ID),'NumberTitle','off');
axes1 = axes('Parent',fig,'FontSize',16);
box(axes1,'on');
hold(axes1,'on');
grid on;

nrOfrows = 3; % quantities
for muscleIdx = 1 : nrOfMuscles
    % Active force
    subplot(nrOfrows,1,muscleIdx)
    plot(muscle.F_M_active(muscleIdx,:), 'Linewidth',2, 'Color','r');
    hold on
    % Passive force
    plot(muscle.F_M_passive(muscleIdx,:), 'Linewidth',2, 'Color','b');
    hold on
    % Total force
    plot(muscle.force(muscleIdx,:), 'Linewidth',2, 'Color','k');
 
    ylabel('$F [N]$', 'interpreter','latex');
    if muscleIdx == 3
        xlabel('sample', 'interpreter','latex');
    end
    title(dataset.muscleData.names(muscleIdx),'Fontsize', 18);
    grid on;
    ax = gca;
    ax.FontSize = 22;
    axis tight;
    legend('active','passive','total');
end

%% PLOT 3
% Plot of the musculoskeletal forces: active, passive, total .
fig = figure('Name', sprintf('Musculoskeletal forces [Subj %02d, Trial %02d]', ...
    SUBJECT_ID, TRIAL_ID ),'NumberTitle','off');
axes1 = axes('Parent',fig,'FontSize',16);
box(axes1,'on');
hold(axes1,'on');
grid on;

nrOfrows = 3; % active, passive, total forces
for rowsIdx = 1 : nrOfrows
    subplot(nrOfrows,1,rowsIdx)
    leg = cell(3,1);
    for muscleIdx = 1 : nrOfMuscles
        if rowsIdx == 1 % active
            plot(muscle.F_M_active(muscleIdx,:), 'Linewidth',2);
            hold on
            axis tight;
            leg(muscleIdx) = dataset.muscleData.names(muscleIdx);
            ylabel('$F_{act} [N]$', 'interpreter','latex');
            grid on;
            ax = gca;
            ax.FontSize = 22;
        elseif rowsIdx == 2 % passive
            plot(muscle.F_M_passive(muscleIdx,:), 'Linewidth',2);
            hold on
            axis tight;
            leg(muscleIdx) = dataset.muscleData.names(muscleIdx);
            ylabel('$F_{passive} [N]$', 'interpreter','latex');
            grid on;
            ax = gca;
            ax.FontSize = 22;
        else % total
            plot(muscle.force(muscleIdx,:), 'Linewidth',2);
            hold on
            axis tight;
            leg(muscleIdx) = dataset.muscleData.names(muscleIdx);
            ylabel('$F_{total} [N]$', 'interpreter','latex');
            xlabel('sample', 'interpreter','latex');
            grid on;
            ax = gca;
            ax.FontSize = 22;
        end
    end
    legend(leg);
end

%% PLOT 4 (paper-custom plot)
% Plot of the musculoskeletal total forces.
fig = figure('Name', sprintf('Musculoskeletal forces [Subj %02d, Trial %02d]', ...
    SUBJECT_ID, TRIAL_ID ),'NumberTitle','off');
axes1 = axes('Parent',fig,'FontSize',16);
box(axes1,'on');
hold(axes1,'on');
grid on;

for muscleIdx = 1 : nrOfMuscles
    plot(muscle.force(muscleIdx,:), 'Linewidth',4);
    hold on
    axis tight;
    leg(muscleIdx) = dataset.muscleData.names(muscleIdx);
    ylabel('$F^{MT} [N]$', 'interpreter','latex');
    xlabel('sample', 'interpreter','latex');
    grid on;
    ax = gca;
    ax.FontSize = 26;
end
legend(leg);

% Save
if OPTS.PLOTSAVEON
    tightfig();
    save2pdf(fullfile(paths.pathToPlots,'muscleForce'), fig, 600);
end

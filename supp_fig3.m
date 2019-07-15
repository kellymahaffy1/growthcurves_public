%% Supplementary Figure 3
% creates a histogram of the linear and quadratic effects across all raw measures for control
% data for Donnelly, et al (2018)
% prerequisites: preprocess.m
% Patrick Donnelly; University of Washington; July 14th, 2019

%% organize data
% name tests of interest and their associated names for future plotting 
tests_raw = {'wj_lwid_raw','wj_wa_raw', ...
    'twre_swe_raw','twre_pde_raw'}; 
names_raw = {'WJ LWID RAW', 'WJ WA RAW', 'TOWRE SWE RAW', ...
    'TOWRE PDE RAW'};
location = find(ismember(lmb_data.Properties.VariableNames, tests_raw));
% initialize data structure
stats_raw = struct; cntrl_stats_raw = struct; inter_stats_raw = struct;
% loop over tests and create data structure with linear, quadratic, and
% cubic models; using a centered time variable (intervention hours)
for test = 1:length(tests_raw)
    loc = location(test);
    int_data.score = int_data{:,loc};
    cntrl_data.score = cntrl_data{:,loc};
    case_cntrl_data.score = case_cntrl_data{:,loc};
    stats_raw(test).name = names_raw(test);
    cntrl_stats_raw(test).name = names_raw(test);
    inter_stats_raw(test).name = names_raw(test);
    % linear model fit
    stats_raw(test).lme = fitlme(int_data, 'score ~ 1 + int_hours_cen + (1|record_id) + (int_hours_cen - 1|record_id)');
    cntrl_stats_raw(test).lme = fitlme(cntrl_data, 'score ~ 1 + cntrl_days_cen + (1|record_id) + (cntrl_days_cen - 1|record_id)');
    % quadratic model fit
    stats_raw(test).lme_quad = fitlme(int_data, 'score ~ 1 + int_hours_cen^2 + (1|record_id) + (int_hours_cen - 1|record_id)');
    % cubic model fit
    stats_raw(test).lme_cube = fitlme(int_data, 'score ~ 1 + int_hours_cen^2 + int_hours_cen^3 + (1|record_id) + (int_hours_cen - 1|record_id)');
    % interaction model fit for case_cntrl data
    inter_stats_raw(test).lme_int = fitlme(case_cntrl_data, 'score ~ 1 + int_days_cen + int_days_cen*group + (1|record_id) + (int_days_cen - 1|record_id)');
end

%% Figure 3a
% creates a histogram of the linear effects across all measures
% place estimates, standard errors, and p values in table
for test = 1:length(names_raw)
    linear_data_raw(test, :) = table(stats_raw(test).name, stats_raw(test).lme.Coefficients.Estimate(2), stats_raw(test).lme.Coefficients.SE(2));
    linear_data_raw.Properties.VariableNames = {'test_name', 'growth', 'se'};
end
% plot
figure; hold;
h = bar(linear_data_raw.growth, 'FaceColor', 'w', 'EdgeColor', 'k');
errorbar(linear_data_raw.growth, linear_data_raw.se, 'kx');
% add p value astrisks
for test = 1:length(names_raw)
    if stats_raw(test).lme.Coefficients.pValue(2) <= 0.001
        text(test, linear_data_raw.growth(test) + linear_data_raw.se(test) + .002, ...
            '**', 'HorizontalAlignment', 'center', 'Color', 'b');
    elseif stats_raw(test).lme.Coefficients.pValue(2) <= 0.05
        text(test,linear_data_raw.growth(test) + linear_data_raw.se(test) + .002, ...
            '*', 'HorizontalAlignment', 'center', 'Color', 'b');
    end
end
% Format
ylabel('Growth Estimate'); xlabel('Test Name');
ax = gca; axis('tight');
ax.XTick = 1:length(names_raw);
ax.XTickLabel = names_raw;
ax.XTickLabelRotation = 45;
title('Linear Growth Estimate by Test');

%% Figure 3b
% creates histogram of quadratic effects of all measures using LME model
for test = 1:length(names_raw)
    quad_data_raw(test, :) = table(stats_raw(test).name, stats_raw(test).lme_quad.Coefficients.Estimate(3), stats_raw(test).lme_quad.Coefficients.SE(3));
    quad_data_raw.Properties.VariableNames = {'test_name', 'growth', 'se'};
end
% plot
figure; hold;
h = bar(quad_data_raw.growth, 'FaceColor', 'w', 'EdgeColor', 'k');
errorbar(quad_data_raw.growth, quad_data_raw.se, 'kx');
% add p value astrisks
for test = 1:length(names_raw)
    if stats_raw(test).lme_quad.Coefficients.pValue(3) <= 0.001
        text(test, quad_data_raw.growth(test) + quad_data_raw.se(test) + .00002, ...
            '**', 'HorizontalAlignment', 'center', 'Color', 'b');
    elseif stats_raw(test).lme_quad.Coefficients.pValue(3) <= 0.05
        text(test, quad_data_raw.growth(test) + quad_data_raw.se(test) + .00002, ...
            '*', 'HorizontalAlignment', 'center', 'Color', 'b');
    end
end
% Format
ylabel('Growth Estimate'); xlabel('Test Name');
ax = gca; axis('tight');
ax.XTick = 1:length(names_raw);
ax.XTickLabel = names_raw;
ax.XTickLabelRotation = 45;
title('Quadratic Growth Estimate by Test');
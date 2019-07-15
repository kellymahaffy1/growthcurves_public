%% Predictor Analysis for Age and Initial Reading Score
% performs predictor analysis for age of participant and initial reading
% score for Donnelly, et al (2018)
% prerequisites: preprocess.m
% Patrick Donnelly; University of Washington; July 14th, 2019


%% extract predictor variables
% Intial Reading Score
brs_init = int_data.wj_brs(int_data.int_session == 1);
% Age
age = int_data.visit_age(int_data.int_session == 1);
%% Zero in on intervention sessions (no baseline)
sessions = [1 2 3 4];
sess_indx = ismember(int_data.int_session, sessions);
int_data = int_data(sess_indx,:);
% center time variables
int_data.int_sess_cen = center(int_data, 'int_session', 'record_id');
int_data.int_hours_cen = center(int_data, 'int_hours', 'record_id');

%% 

s = unique(int_data.record_id);
for jj = 1:length(s)
    indx = ismember(int_data.record_id, s(jj));
    tbl = table(int_data.record_id(indx), int_data.int_hours_cen(indx), int_data.wj_brs(indx));
    tbl.Properties.VariableNames = {'sid', 'long_var', 'score'};
    % Rather than using a mixed linear model we want to use an ordinary least
    % squares regression. Many functions impliment this. For example
    % regress regstats or polyfit
    indiv_slopes(jj,:) = polyfit(tbl.long_var-1,tbl.score,1);
end
% reshape predictor matrix to get one score per subject
% NOTE: the argument following the original predictor matrix is the number
% of sessions involved in the analysis
% tmp = reshape(predictor, 4, numel(predictor)/4);
% % zero in on first column for unique scores
% predictor = tmp(1,:)';
% For altering predictor based on mean/median/etc
% for sub = 1:numel(predictor)
%     predictor(sub) = predictor(sub) - median(predictor);
% end
% Compute correlation
figure; hold;
[c, p] = corr(brs_init, indiv_slopes(:,1),'rows','pairwise');
scatter(brs_init, indiv_slopes(:,1), ifsig(brs_init, indiv_slopes(:,1)));
xlabel('brs_init'); ylabel('indiv slopes');
%title(sprintf('%s as a predictor of %s growth rate (r=%.2f p =%.3f)', predictor_name, test_names{test}, c, p));
lsline;
% Save image
fname = sprintf('C:/Users/Patrick/Desktop/figures/LMB/%s_%s_%s_%s.eps', predictor_name, test_names{test},'growth_predictor', date);
fname2 = sprintf('C:/Users/Patrick/Desktop/figures/LMB/%s_%s_%s_%s.png', predictor_name, test_names{test},'growth_predictor', date);
print(fname, '-depsc');
print(fname2, '-dpng');



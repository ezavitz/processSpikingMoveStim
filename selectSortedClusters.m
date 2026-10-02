% selectSortedClusters
%
% Pick the curated clusters to export from a Kilosort/phy cluster_info.tsv,
% identified by their Kilosort cluster IDs.
%
% spike_clusters.npy labels every spike with its cluster ID (cluster_info
% column 'cluster_id': 0-based, with gaps after merging or splitting in phy).
% Spikes must be selected by that ID. Before 2026-10-02, combineData used the
% ROW NUMBER of cluster_info.tsv instead (clust.index = 1:N), which exported
% whichever clusters had IDs equal to those row numbers, including clusters
% curated as noise, and gave empty rows where no such ID existed.
%
% INPUTS:
%   clusterInfo  string matrix, one row per cluster, no header row
%   header       string vector of column names, same width as clusterInfo
%
% OUTPUT: struct with fields
%   clusterInfo, header  as given
%   ID       Kilosort cluster ID of every row (double, 1 x nClusters)
%   index    same as ID; kept so existing callers that use
%            clust.index(clust.isUnit) select by ID
%   isUnit   curated 'good' or 'mua' (nClusters x 1)
%   isSU     curated 'good' (nClusters x 1)
%   ch       channel of each exported unit (string, nUnits x 1, as before)
%   unitIDs  cluster IDs of the exported units, in output row order
%
% WRITTEN BY: data-quality audit, 2026-10-02

function clust = selectSortedClusters(clusterInfo, header)
header = strtrim(string(header(:)'));
assert(numel(header) == size(clusterInfo, 2), 'selectSortedClusters:Header', ...
    'Header has %d names but cluster_info has %d columns.', numel(header), size(clusterInfo, 2));
iID  = findColumn(header, ["cluster_id", "id"]);
iGrp = findColumn(header, "group");
iCh  = findColumn(header, "ch");

ids = str2double(clusterInfo(:, iID))';
assert(all(isfinite(ids)) && all(ids == fix(ids)) && all(ids >= 0), ...
    'selectSortedClusters:BadID', 'Cluster IDs must be non-negative integers.');
assert(numel(unique(ids)) == numel(ids), 'selectSortedClusters:DuplicateID', ...
    'Cluster IDs must be unique.');

grp = strtrim(clusterInfo(:, iGrp));
clust.clusterInfo = clusterInfo;
clust.header  = header;
clust.ID      = ids;
clust.index   = ids;
clust.isUnit  = grp == "good" | grp == "mua";
clust.isSU    = grp == "good";
clust.ch      = clusterInfo(clust.isUnit, iCh);
clust.unitIDs = ids(clust.isUnit);
end

function i = findColumn(header, names)
i = find(ismember(header, names), 1);
assert(~isempty(i), 'selectSortedClusters:MissingColumn', ...
    'cluster_info has no column named %s.', strjoin(names, ' or '));
end

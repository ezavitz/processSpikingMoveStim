% testSelectSortedClusters
%
% Regression tests for cluster selection by Kilosort ID (2026-10-02 fix).
% Run: runtests('tests/testSelectSortedClusters.m') from the repo root.

function tests = testSelectSortedClusters
tests = functiontests(localfunctions);
end

function setupOnce(tc)
root = fileparts(fileparts(mfilename('fullpath')));
tc.TestData.paths = {root, fullfile(fileparts(root), 'utilities', 'dataTools')};
addpath(tc.TestData.paths{:});
end

function teardownOnce(tc)
rmpath(tc.TestData.paths{:});
end

% A curated sort: 0-based IDs with gaps, as phy leaves them after merges.
function [info, header] = fixture()
header = ["cluster_id" "Amplitude" "ContamPct" "KSLabel" "amp" "ch" "depth" "fr" "group" "n_spikes" "sh"];
ids   = ["0" "1" "4" "6" "9" "12"];
group = ["good" "noise" "mua" "good" "noise" "mua"];
ch    = ["3" "3" "8" "11" "11" "20"];
n = numel(ids);
info = repmat("x", n, numel(header));
info(:, 1) = ids'; info(:, 6) = ch'; info(:, 9) = group';
end

function testSelectsByClusterID(tc)
[info, header] = fixture();
c = selectSortedClusters(info, header);
verifyEqual(tc, c.unitIDs, [0 4 6 12]);
verifyEqual(tc, c.index(c.isUnit), [0 4 6 12]);
verifyEqual(tc, c.ID(c.isSU), [0 6]);
verifyEqual(tc, c.ch, ["3"; "8"; "11"; "20"]);
end

function testOldRowNumberSelectionWasWrong(tc)
% Documents the defect: the good/mua rows are rows [1 3 4 6]. Used as IDs,
% they export cluster 1 (curated noise), 4 and 6 (units, in the wrong rows),
% and an empty row for 3, which is not a cluster ID.
[info, header] = fixture();
c = selectSortedClusters(info, header);
rowNumbers = find(c.isUnit)';
verifyEqual(tc, rowNumbers, [1 3 4 6]);
verifyNotEqual(tc, rowNumbers, c.unitIDs);
verifyEqual(tc, intersect(rowNumbers, c.ID), [1 4 6]);
verifyFalse(tc, c.isUnit(c.ID == 1));          % captured cluster 1 is noise
verifyFalse(tc, ismember(3, c.ID));            % row 3 would be silent
end

function testSpikeTrainRowsHoldTheirOwnCluster(tc)
[info, header] = fixture();
c = selectSortedClusters(info, header);
spikeCluster = [0 1 4 6 9 12 0 4 12 9 6 1]';
spikeMs      = (10:10:120)';
get = ismember(spikeCluster, c.index(c.isUnit));
s = buildSpikeTrain(spikeMs(get), spikeCluster(get), 1000, c.index(c.isUnit));
verifySize(tc, s, [4, max(spikeMs(get)) + 1000]);   % ends at last exported spike
for r = 1:numel(c.unitIDs)
    verifyEqual(tc, find(s(r, :)), spikeMs(spikeCluster == c.unitIDs(r))', ...
        sprintf('row %d should hold cluster %d', r, c.unitIDs(r)));
end
verifyEqual(tc, nnz(s), sum(get));   % noise clusters 1 and 9 excluded
verifyTrue(tc, all(any(s, 2)));      % no empty rows
end

function testColumnsFoundByName(tc)
[info, header] = fixture();
p = [9 1 6 2 3 4 5 7 8 10 11];        % shuffled column order
c = selectSortedClusters(info(:, p), header(p));
verifyEqual(tc, c.unitIDs, [0 4 6 12]);
verifyEqual(tc, c.ch, ["3"; "8"; "11"; "20"]);
end

function testRejectsDuplicateOrMissing(tc)
[info, header] = fixture();
dup = info; dup(2, 1) = "0";
verifyError(tc, @() selectSortedClusters(dup, header), 'selectSortedClusters:DuplicateID');
verifyError(tc, @() selectSortedClusters(info(:, [1:5 7:11]), header([1:5 7:11])), ...
    'selectSortedClusters:MissingColumn');
end

function testReadClusterInfoRoundTrip(tc)
[info, header] = fixture();
info(:, 11) = "";                      % empty trailing column, as phy writes
f = [tempname '.tsv'];
cleanup = onCleanup(@() delete(f));
fid = fopen(f, 'w');
fprintf(fid, '%s\n', strjoin(header, sprintf('\t')));
for r = 1:size(info, 1)
    fprintf(fid, '%s\n', strjoin(info(r, :), sprintf('\t')));
end
fclose(fid);
[got, h] = readClusterInfo(f);
verifyEqual(tc, h, header);
verifySize(tc, got, size(info));
c = selectSortedClusters(got, h);
verifyEqual(tc, c.unitIDs, [0 4 6 12]);
end

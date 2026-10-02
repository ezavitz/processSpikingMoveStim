% readClusterInfo
%
% Read a phy cluster_info.tsv as a string matrix plus its header names.
% The header is needed to find columns by name: their order differs
% between phy versions.
%
% WRITTEN BY: data-quality audit, 2026-10-02

function [clusterInfo, header] = readClusterInfo(tsvPath)
fid = fopen(tsvPath);
assert(fid > 0, 'readClusterInfo:Open', 'Cannot open %s.', tsvPath);
cleanup = onCleanup(@() fclose(fid));
header = string(strsplit(strtrim(fgetl(fid)), sprintf('\t')));
clusterInfo = readmatrix(tsvPath, 'FileType', 'text', 'Delimiter', '\t', ...
    'OutputType', 'string', 'NumHeaderLines', 1);
% readmatrix drops trailing columns that are empty in every row
if size(clusterInfo, 2) < numel(header)
    clusterInfo(:, end + 1:numel(header)) = "";
end
end

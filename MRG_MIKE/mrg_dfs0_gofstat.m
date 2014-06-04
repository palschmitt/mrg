function gofstat = mrg_dfs0_gofstat(Pred_fname, Obs_fname)
% A wrapper around 'mrg_gofstat' code for use with MIKE DFS0 files
%
% INPUT
%   Pred_fname  Optional. A filename for a DFS0 file to act as the
%   'prediction'
%   Obs_fname   Optional. A filename for a DFS0 file to act as the
%   'observations'
%
% OUTPUT
%   gofstat     A MATLAB structure containing model comparision statistics,
%               with the addition of Pred_fname and Obs_fname, the supplied 
%               files names used in the comparision.  
%               See doc mrg_gofstat for further information on the
%               statistics returned.  
%
% REQUIREMENTS
%   Requires mrg_gofstat and mrg_read_DFS0 from the MRG toolbox
%   DHI MIKE toolbox (tested with v. 20130222)
%
% AUTHORS
%   Daniel Pritchard
%
% LICENCE
%   Code distributed as part of the MRG toolbox from the Marine Research
%   Group at Queens Univeristy Belfast (QUB) School of Planning
%   Architecture and Civil Engineering (SPACE). Distributed under a
%   creative commons CC BY-SA licence, retaining full copyright of the
%   original authors.
%
%   http://creativecommons.org/licenses/by-sa/3.0/
%   http://www.qub.ac.uk/space/
%   http://www.qub.ac.uk/research-centres/eerc/
%
% DEVELOPMENT
%   v 1.0   August 2013
%           First version. DP
%
%% Function Begin!

if ~exist('Pred_fname', 'var')
    [Pred_fname, Pred_path] = uigetfile('.dfs0','Select predictions');
    Pred_fname = [Pred_path, Pred_fname];
end

if ~exist('Obs_fname', 'var')
    [Obs_fname, Obs_path] = uigetfile([Pred_path,'.dfs0'],['Select observations to compare against ', Pred_fname]);
    Obs_fname = [Obs_path, Obs_fname];
end

preds = mrg_read_dfs0(Pred_fname);
obs = mrg_read_dfs0(Obs_fname);

if size(preds.items,1)~=size(obs.items,1)
    error('The files have a different number of items. For now, this is an error')
end

gofstat = mrg_gofstat(preds.dData, obs.dData);  

gofstat.Pred_fname = preds.Fullname;
gofstat.Obs_fname = obs.Fullname;


end

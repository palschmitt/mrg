function data = mrg_assign(data, test, comparision, assign)
% A simple wrapper function for simple logical indexing (i.e '<', '>' and '==')
% 
% INPUT
%   data            The data to test. A matrix or a vector.
%   test            The value to be tested for using comparision
%   comparision     A string specifying the comparision / test to perform
%   assign          The value to assign if the test is true
%
% OUTPUT
%   data    The modified input, with logical matches of test to data using
%           comaprsion replaced with assign.
%
% USAGE
%   This funciton is not really intended for wide-scale usage. It is here
%   only for use with mrg_dfsu_apply
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
%   v 1.0   July 2013
%           Initial attempt. Documentation. DP.
%%
if test =='<'
    data(data<comparision)=assign;
elseif test == '>'
    data(data>comparision)=assign;
elseif test == '='
    data(data==comparision)=assign;
else
    error('Function only supports ">", "<", or "=", tests')
end
end

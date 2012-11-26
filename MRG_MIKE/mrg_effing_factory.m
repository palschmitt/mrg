function factory = mrg_effing_factory()
% A function to generate the factory object required in a number of MIKE
% toolbox examples.  Should prevent errors in functions.  
%
% USAGE
%   Wherever a MIKE toolbox example shows this:
%       factory = DfsFactory();
%   replace it with this:
%       factory = mrg_effing_factory();
%

NET.addAssembly('DHI.Generic.MikeZero.DFS');
import DHI.Generic.MikeZero.DFS.*;
factory = DfsFactory();

end

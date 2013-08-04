function data = mrg_assign(data, test, comparision, assign)
% A simple function to convert all
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

classdef MlpPyRun < handle
%   AUTHORSHIP
%   Developer: Stephen Meehan <swmeehan@stanford.edu>,
%              Connor Meehan <connor.gw.meehan@gmail.com>
%   Copyright (c) 2022 The Board of Trustees of the Leland Stanford Junior University; Herzenberg Lab 
%   License: BSD 3 clause

    properties(Constant)
        OLDEST_COMPATIBLE_MATLAB_RELEASE='R2019b';
    end
    
    methods(Static)
        function ok=CanDo()
            if ~MatBasics.usingOlderThan(MlpPyRun.OLDEST_COMPATIBLE_MATLAB_RELEASE)&&~isdeployed
                ok=MlpPyRun.Flag;
            else
                ok=false;
            end
        end

        function ok=Flag(setting)
            ok=true;
            app=BasicMap.Global;
            if isfield(app.python, 'pyRun')
                ok=app.python.pyRun;
            end
            if nargin>0
                app.python.pyRun=setting;
            end
        end
        
        function InitEnv(tellUser)
            try
                [~,~,cmd]=MlpPython.IsAvailable;
                pyenv;
                pyenv('Version', cmd);
            catch ex
                if nargin> 0 && tellUser
                    ex.getReport;
                    msg(Html.WrapTable([ex.message '<br>' ...
                        '<br>So after restarting MATLAB the next time type:<br>'...
                        '<br><b>pyenv,pyenv(''Version'', ''' cmd...
                        ''')</b><hr><br><b>NOTE</b>:  These commands are '...
                        'copied to the clipboard.<br>You only have to'...
                        'do this ONCE....but for <b>NOW</b> we can proceed ' ...
                        '(<i>albeit more slowly</i>) by calling Python '...
                        'externally...no problem!' ], ...
                        3, 5, '0', 'left', 'in'), 24, 'south+');
                    disp('Restart MATLAB and type')
                    disp(['     pyenv, pyenv(''Version'', ' ...
                        '''' cmd ''')'])
                    clipboard('Copy', ['pyenv, pyenv(''Version'', ' ...
                        '''' cmd ''')']);
                end
            end
        end
        
        function Init
            try
                MlpPyRun.InitEnv(false);
                P = py.sys.path;
                directory = fileparts(mfilename('fullpath'));
                if count(P,directory) == 0
                    insert(P,int32(0),directory);
                end
                py.importlib.import_module('mlp')
            catch ex
                ex.getReport
            end
        end

        function [labels, confidenceMatrix]=Predict(inputData, model, ~)
            labels=[];
            confidenceMatrix=[];
            if ~MlpPyRun.Flag
                return;
            end
            if MatBasics.usingOlderThan(MlpPyRun.OLDEST_COMPATIBLE_MATLAB_RELEASE)
                msgError('You need MATLAB R2019b or later!')
                return;
            end
            try
                npInputData = py.numpy.array(inputData);
                values = py.mlp2.mlp_predict2(npInputData, model);
            catch
                MlpPyRun.Init;
                try
                    npInputData = py.numpy.array(inputData);
                    values = py.mlp2.mlp_predict2(npInputData, model);
                catch ex
                    if ~contains(ex.message, 'h5py is not available')
                        MlpPyRun.InitEnv(true);
                    else
                        ex.getReport
                    end
                    MlpPyRun.Flag(false);
                    return;
                end
            end
            MlpPyRun.Flag(true);
            labels = double(values{1})';
            confidenceMatrix = double(values{2});
        end
    end
end

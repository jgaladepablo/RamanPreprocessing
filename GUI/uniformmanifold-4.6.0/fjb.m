function fjb
if Is2025aOrGreater
    return;
end
suh_pipelines;
if ~isdeployed 
    try
        PyEnvironment.Setup;
    catch ex
        disp(ex.message);
    end
end
end
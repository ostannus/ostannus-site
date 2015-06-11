




% "Flecktarn"-inspired three-layered digital camouflage image generation script.
% --
% This function generates and composites a series of layer masks of different colours,
% based on a sum of a wave and ripple function in each layer being greater than a threshold.
% All parameters are randomised in this implementation. The resulting image is saved
% locally for display.


% Function to build a layer mask based on layer parameters.
function fleckMask = getFleckMask(gridSize, layerIndex, layerSettings)
    
    % Take the current layer settings.
    l = layerSettings(layerIndex);
    
    
    % Find the large-scale low-granularity probability map - "waves".
    gridSizeSmall = floor(gridSize./4);
    poles = struct('x', rand([1, l.waveFrequency]), 'y', rand([1, l.waveFrequency]), 'v', max(0, l.waveOffset + l.waveHeight.*(1.*rand([1, l.waveFrequency])-0.0)) );
      
    grid = struct('x', repmat((([1:gridSizeSmall]-1)./(gridSizeSmall-1)),[gridSizeSmall,1]), 'y', repmat((([1:gridSizeSmall]-1)./(gridSizeSmall-1))',[1 gridSizeSmall]));
      
    x = [-1+grid.x, grid.x, 1+grid.x; -1+grid.x, grid.x, 1+grid.x; -1+grid.x, grid.x, 1+grid.x];
    y = [-1+grid.y, -1+grid.y, -1+grid.y; grid.y, grid.y, grid.y; 1+grid.y, 1+grid.y, 1+grid.y];
      
    vv = repmat(poles.v,[1,3*3]);
      
    xx = [-1+poles.x, poles.x, 1+poles.x, -1+poles.x, poles.x, 1+poles.x, -1+poles.x, poles.x, 1+poles.x];
    yy = [-1+poles.y, -1+poles.y, -1+poles.y, poles.y, poles.y, poles.y, 1+poles.y, 1+poles.y, 1+poles.y];
    
    [xq,yq,vq] = griddata(xx,yy,vv,x,y,'nearest');
    
    voronoiMap = imresize(repmat(vq((gridSizeSmall):(2*gridSizeSmall),(gridSizeSmall+1):(2*gridSizeSmall)),[1,1,3]),[gridSize, gridSize]);
    
    lowFrequencyMap = voronoiMap(:,:,1);
    
    for i = 1:l.waveBlurIterations
        lowFrequencyMap = imfilter(lowFrequencyMap,fspecial('gaussian',l.waveBlurKernelSize,l.waveBlurStrength),'symmetric');
    end
    
    
    % Find the small-scale high-granularity probability map - "ripples".
    staticMap = l.rippleOffset + l.rippleHeight.*(2.*rand([gridSize, gridSize])-1.0);
    
    highFrequencyMap = staticMap;
    for i = 1:l.rippleBlurIterations
        highFrequencyMap = imfilter(highFrequencyMap,fspecial('gaussian',l.rippleBlurKernelSize,l.rippleBlurStrength),'symmetric');
    end
    
    
    % Build the resultant mask a composite of the two masks.
    fleckMask = logical((highFrequencyMap+lowFrequencyMap(:,:,1)) > l.heightThreshold);
    
end


% Basic image parameters of grid size and rough hue value.
gridSize = 512.00;

overallH = 1.0 .* rand([1 1]);


% Base layer parameters.
layerSettings = struct();

layerSettings(1).h = mod(overallH + 0.1 .* rand([1 1]),1.0);
layerSettings(1).s = 1.0 .* rand([1 1]);
layerSettings(1).v = 0.3 .* rand([1 1]);


% Primary layer parameters.
layerSettings(2).waveFrequency = max(floor(300.* rand([1 1])),100);
layerSettings(2).waveBlurIterations = max(floor(20.* rand([1 1])),10);
layerSettings(2).waveBlurKernelSize = max(floor(30.* rand([1 1])),10);
layerSettings(2).waveBlurStrength = max((10.* rand([1 1])),5);
layerSettings(2).waveHeight = 0.8 + (0.0* rand([1 1]));
layerSettings(2).waveOffset = -0.0 + max((0.0* rand([1 1])),0);
layerSettings(2).rippleBlurIterations = max(floor(10.* rand([1 1])),5);
layerSettings(2).rippleBlurKernelSize = max(floor(08.* rand([1 1])),4);
layerSettings(2).rippleBlurStrength = max((10.* rand([1 1])),1);
layerSettings(2).rippleHeight = 1.0 + (0.0* rand([1 1]));
layerSettings(2).rippleOffset = -0.0 + max((0.2* rand([1 1])),0);
layerSettings(2).heightThreshold = 0.4 + (0.1* rand([1 1]));
layerSettings(2).h = mod(overallH + 0.1 .* rand([1 1]),1.0);
layerSettings(2).s = 1.0 .* rand([1 1]);
layerSettings(2).v = 0.7 .* rand([1 1]);


% Secondary layer parameters.
layerSettings(3).waveFrequency = max(floor(200.* rand([1 1])),1);
layerSettings(3).waveBlurIterations = max(floor(20.* rand([1 1])),10);
layerSettings(3).waveBlurKernelSize = max(floor(30.* rand([1 1])),10);
layerSettings(3).waveBlurStrength = max((10.* rand([1 1])),5);
layerSettings(3).waveHeight = 0.8 + (0.0* rand([1 1]));
layerSettings(3).waveOffset = -0.0 + max((0.0* rand([1 1])),0);
layerSettings(3).rippleBlurIterations = max(floor(10.* rand([1 1])),5);
layerSettings(3).rippleBlurKernelSize = max(floor(08.* rand([1 1])),4);
layerSettings(3).rippleBlurStrength = max((10.* rand([1 1])),1);
layerSettings(3).rippleHeight = 1.0 + (0.0* rand([1 1]));
layerSettings(3).rippleOffset = -0.0 + max((0.2* rand([1 1])),0);
layerSettings(3).heightThreshold = 0.5 + (0.1* rand([1 1]));
layerSettings(3).h = mod(overallH + 0.1 .* rand([1 1]),1.0);
layerSettings(3).s = 1.0 .* rand([1 1]);
layerSettings(3).v = 0.9 .* rand([1 1]);


% Tertiary layer parameters.
layerSettings(4).waveFrequency = max(floor(200.* rand([1 1])),1);
layerSettings(4).waveBlurIterations = max(floor(20.* rand([1 1])),10);
layerSettings(4).waveBlurKernelSize = max(floor(30.* rand([1 1])),10);
layerSettings(4).waveBlurStrength = max((10.* rand([1 1])),5);
layerSettings(4).waveHeight = 0.8 + (0.0* rand([1 1]));
layerSettings(4).waveOffset = -0.0 + max((0.0* rand([1 1])),0);
layerSettings(4).rippleBlurIterations = max(floor(10.* rand([1 1])),5);
layerSettings(4).rippleBlurKernelSize = max(floor(08.* rand([1 1])),4);
layerSettings(4).rippleBlurStrength = max((10.* rand([1 1])),1);
layerSettings(4).rippleHeight = 1.0 + (0.0* rand([1 1]));
layerSettings(4).rippleOffset = -0.0 + max((0.2* rand([1 1])),0);
layerSettings(4).heightThreshold = 0.6 + (0.1* rand([1 1]));
layerSettings(4).h = mod(overallH + 0.1 .* rand([1 1]),1.0);
layerSettings(4).s = 1.0 .* rand([1 1]);
layerSettings(4).v = 1.0 .* rand([1 1]);


% Save layer settings to file for display (overwriting existing data).
save_header_format_string ('');
textOut = ''
f = fieldnames(layerSettings)
for i = 1:numel(layerSettings)
    for j = 1:numel(fieldnames(layerSettings))
        textOut = [textOut, '(', num2str(i), ')', ': ', f{j}, ' = ', num2str(getfield(layerSettings(i),f{j}))];
        textOut = [textOut, '  '];
    end
end
fid = fopen ('/var/www/html/camo/camo_parameters.txt', 'w+t');
fdisp (fid, textOut);
fclose (fid);



% Build the logical fleck masks.
fleckMask = struct('primary',[],'secondary',[],'tertiary',[]);

fleckMask.primary = repmat(getFleckMask(gridSize, 2, layerSettings), [1, 1, 3]);
fleckMask.secondary = repmat(getFleckMask(gridSize, 3, layerSettings), [1, 1, 3]);
fleckMask.tertiary = repmat(getFleckMask(gridSize, 4, layerSettings), [1, 1, 3]);


% Generate fleck maps based on masks and HSV colours for each layer.
fleckMap = struct('primary',[],'secondary',[],'tertiary',[]);

fleckMap.primary = fleckMask.primary .* repmat(reshape([layerSettings(2).h, layerSettings(2).s, layerSettings(2).v],[1,1,3]),[gridSize, gridSize, 1]);
fleckMap.secondary = fleckMask.secondary .* repmat(reshape([layerSettings(3).h, layerSettings(3).s, layerSettings(3).v],[1,1,3]),[gridSize, gridSize, 1]);
fleckMap.tertiary = fleckMask.tertiary .* repmat(reshape([layerSettings(4).h, layerSettings(4).s, layerSettings(4).v],[1,1,3]),[gridSize, gridSize, 1]);


% Generate image from fleck maps.
fleckImage = double(ones([gridSize, gridSize, 3])) .* repmat(reshape([layerSettings(1).h, layerSettings(1).s, layerSettings(1).v],[1,1,3]),[gridSize, gridSize, 1]);

fleckImage(fleckMask.primary) = fleckMap.primary(fleckMask.primary);
fleckImage(fleckMask.secondary) = fleckMap.secondary(fleckMask.secondary);
fleckImage(fleckMask.tertiary) = fleckMap.tertiary(fleckMask.tertiary);


% Convert from HSV to RGB space.
fleckImage = hsv2rgb(fleckImage);


% Save the image locally.
imwrite(fleckImage, '/var/www/html/camo/camo.png');





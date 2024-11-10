function animate(outputFolder)
    outputGif = fullfile(outputFolder, 'animation.gif');
    frameDelay = 1 / 20;

    for m = 0:100
        img = imread(fullfile(outputFolder, sprintf('out_%d.png', m)));
        [ind, map] = rgb2ind(img, 256);

        if m == 0
            imwrite(ind, map, outputGif, 'gif', 'LoopCount', Inf, 'DelayTime', frameDelay);
        else
            imwrite(ind, map, outputGif, 'gif', 'WriteMode', 'append', 'DelayTime', frameDelay);
        end
    end

    for m = 99:-1:1
        img = imread(fullfile(outputFolder, sprintf('out_%d.png', m)));
        [ind, map] = rgb2ind(img, 256);
        imwrite(ind, map, outputGif, 'gif', 'WriteMode', 'append', 'DelayTime', frameDelay);
    end
end

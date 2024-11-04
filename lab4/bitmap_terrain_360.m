function bitmap_terrain_360(filename,elements,p,y_angle,rotation_step)

    bitmap_terrain(filename, elements, p);
    set(gcf, 'WindowState', 'maximized');
    
    % Tworzenie odpowienich folderów do zapisywania plików
    framesFolder = sprintf('frames_%d_%d_%d', elements, y_angle, rotation_step);
    if ~exist(framesFolder, 'dir')
        mkdir(framesFolder);
    end
    videoFolder = 'videos';
    if ~exist(videoFolder, 'dir')
        mkdir(videoFolder);
    end
    
    % Generowanie sekwencji obrotu o 360 stopni
    for x_angle = 0:rotation_step:359
        view(x_angle, y_angle);
        axis off;
        framePath = sprintf('%s/frame_%03d.png', framesFolder, x_angle);
        saveas(gcf, framePath);
    end
    
    % Tworzenie pliku wideo w formacie MP4
    videoFile = sprintf('%s/%s_%d_%d_%d',videoFolder, filename, elements, y_angle, rotation_step);
    v = VideoWriter(videoFile, 'MPEG-4');
    v.Quality = 100;
    open(v);
    for x_angle = 0:rotation_step:359
        framePath = sprintf('%s/frame_%03d.png', framesFolder, x_angle);
        img = imread(framePath);
        writeVideo(v, img);
    end
    close(v);

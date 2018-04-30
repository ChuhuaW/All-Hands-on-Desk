load('metadata.mat');
for i =1:size(video,2)
    %for j = 1:size(video(i).labelled_frames,2)

    %activity_id
    if strcmp(video(i).activity_id,'CARDS')
        id = '1';

    elseif strcmp(video(i).activity_id,'CHESS')
        id = '2';

    elseif strcmp(video(i).activity_id,'JENGA')
        id = '3';

    elseif strcmp(video(i).activity_id,'PUZZLE')
        id = '4';
    end

    %location_id
    if strcmp(video(i).location_id,'COURTYARD')
        id = strcat(id,'1');

    elseif strcmp(video(i).location_id,'LIVINGROOM')
        id = strcat(id,'2');

    elseif strcmp(video(i).location_id,'OFFICE')
        id = strcat(id,'3');
    end      

    %viewer_id
    if strcmp(video(i).ego_viewer_id,'B')
        id = strcat(id,'1');

    elseif strcmp(video(i).ego_viewer_id, 'H')
        id = strcat(id,'2');

    elseif strcmp(video(i).ego_viewer_id,'S')
        id = strcat(id,'3');

    elseif strcmp(video(i).ego_viewer_id,'T')
        id = strcat(id,'4');
    end

    %fprintf('%s\n',id);
    %partner_id
    if strcmp(video(i).partner_id,'B')
        id = strcat(id,'1');

    elseif strcmp(video(i).partner_id,'H')
        id = strcat(id,'2');

    elseif strcmp(video(i).partner_id,'S')
        id = strcat(id,'3');

    elseif strcmp(video(i).partner_id,'T')
        id = strcat(id,'4');
    end
    %fprintf('%s\n',id);





    %disp(id);
    video(i).id = id;


end
    
newdata = [];
for j=1:size(video,2)
    for k=1:size(video(j).labelled_frames,2)
        video(j).labelled_frames(k).id = str2num(strcat(video(j).id,sprintf('%04d',video(j).labelled_frames(k).frame_num))); 
        flatteneddata = cellfun(@(x) video(j).labelled_frames(k).(x), {'myleft','myright','yourleft','yourright'}, 'UniformOutput', false)';
        flatteneddata = horzcat(flatteneddata,repmat({video(j).labelled_frames(k).id},4,1));
        newdata = [newdata;flatteneddata];

    end
end

annotation = struct('segmentation',{},'area',{},'iscrowd',{},'image_id',{},'bbox',{},'category_id',{},'id',{},'ignore',{});


for row=1:size(newdata,1)
    annotation(row).segmentation = cell2mat(newdata(row,1));
    annotation(row).image_id = cell2mat(newdata(row,2));
    annotation(row).ignore = 0;
    annotation(row).iscrowd = 0;
    annotation(row).id = row;
    if mod(row,4) ==0
        annotation(row).category_id = 4;
    else
        annotation(row).category_id = mod(row,4);
    end
end
clear flatteneddata newdata;
savejson('',annotation,'testjson.json')

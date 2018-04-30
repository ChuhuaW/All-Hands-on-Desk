%load('metadata.mat');
split = {'Train','Valid','Test'}; split=split{3};

%sub-instance
%image
dir_filename=dir(sprintf('/Users/Joshua/Documents/egohands_data/%s/*.jpg',split));
video = getMetaBy('MainSplit',upper(split));
for i=1:size(dir_filename)
    dir_filename(i).id=str2num(dir_filename(i).name(1:end-4));
end

% initialize image structure
image = struct('file_name',{dir_filename.name},'height',{ones(1)*720},'width',{ones(1)*1280},'id',{dir_filename.id});
%image = image(1:2);
save 'image_instance.mat' image;

%annotation
%initialize structure
annotation = struct('segmentation',{},'area',{},'iscrowd',{},'image_id',{},'bbox',{},'category_id',{},'id',{});




% generate iamge_id prefix
for i =1:size(video,2)

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
    
    video(i).id = id;


end

%flatten segmentation structure
newdata = [];
for j=1:size(video,2)
    for k=1:size(video(j).labelled_frames,2)
        video(j).labelled_frames(k).id = str2num(strcat(video(j).id,sprintf('%04d',video(j).labelled_frames(k).frame_num))); 
        flatteneddata = cellfun(@(x) video(j).labelled_frames(k).(x), {'myleft','myright','yourleft','yourright'}, 'UniformOutput', false)';
        flatteneddata = horzcat(flatteneddata,repmat({video(j).labelled_frames(k).id},4,1));
        newdata = [newdata;flatteneddata];
    end
end


% fill in annotation structure
for row=1:size(newdata,1)
    annotation(row).segmentation = cell2mat(newdata(row,1));
    
    if ~isempty(annotation(row).segmentation)
        annotation(row).bbox = segmentation2box(annotation(row).segmentation);
        annotation(row).segmentation = reshape(annotation(row).segmentation.',1,[]);
        annotation(row).area = double(MaskApi.area(MaskApi.frPoly({annotation(row).segmentation},720,1280)));
        annotation(row).segmentation = {annotation(row).segmentation};
        
        
    end
    annotation(row).image_id = cell2mat(newdata(row,2));
    %annotation(row).ignore = 0;
    annotation(row).iscrowd = 0;
    annotation(row).id = row;
    
    act_id = num2str(annotation(row).image_id);
    %disp(act_id);
    act_id = act_id(1);
    
    if mod(row,4) ==0
        annotation(row).category_id = str2double(strcat('4',act_id));
    else
        annotation(row).category_id = str2double(strcat(num2str(mod(row,4)),act_id));
    end
    
    
end

%remove empty segmentation
annotation = annotation(~cellfun(@isempty,{annotation.segmentation}));

%Test code
%annotation = annotation(1:8);

%categories
categories = struct('supercategory', {},'id',{},'name',{});
hands = horzcat(repmat({'myleft'},1,4),repmat({'myright'},1,4),repmat({'yourleft'},1,4),repmat({'yourright'},1,4));
acts = repmat({'CARDS','CHESS','JENGA','PUZZLE'},1,4);
for i= 1:16

    categories(i).supercategory =  hands{i};
    if mod(i,4) ==0
        cat = 4;
    else
        cat = mod(i,4);
    end
    categories(i).id =  str2double(strcat(num2str(ceil(i/4)),num2str(cat)));
    categories(i).name =  strcat(hands{i},'_',acts{i});

end

 
%save 'cat_instance.mat' categories;

json_file = struct('images',{image},'type',{'instances'},'annotations',{annotation},'categories',{categories});


clear flatteneddata i id j k row dir_filename;
output_filename = sprintf('ego_annotation_act_%s_box_union.json',lower(split));

savejson('',json_file,output_filename);
%savejson('',json_file,'ego_annotation_valid.json');
%savejson('',json_file,'ego_annotation_test.json');
%savejson('',json_file,'test.json');




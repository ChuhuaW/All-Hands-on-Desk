%load('metadata.mat');
split = {'Train','Valid','Test'}; split=split{1};

%sub-instance
%image
dir_filename=dir(sprintf('/Users/Joshua/Documents/egohands_data/%s/*.jpg',split));
video = getMetaBy('MainSplit',upper(split));


for i=1:size(dir_filename)
    dir_filename(i).id=str2double(dir_filename(i).name(1:end-4));
end

image = struct('file_name',{dir_filename.name},'height',{ones(1)*720},'width',{ones(1)*1280},'id',{dir_filename.id});
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
    %disp(size(video,2))
    for k=1:size(video(j).labelled_frames,2)
        video(j).labelled_frames(k).id = str2num(strcat(video(j).id,sprintf('%04d',video(j).labelled_frames(k).frame_num))); 
        flatteneddata = cellfun(@(x) video(j).labelled_frames(k).(x), {'myleft','myright','yourleft','yourright'}, 'UniformOutput', false);
        %disp(flatteneddata);
        %flatteneddata = flatteneddata(~cellfun('isempty',flatteneddata));
        flatteneddata = horzcat(flatteneddata,repmat({video(j).labelled_frames(k).id},1,1));
        %disp(flatteneddata);
        newdata = [newdata;flatteneddata];
    end
end


% fill in annotation structure
for row=1:size(newdata,1)
    %disp(row);
    area=0;
    seg = {};
    seg_rles=struct('size',{},'counts',{});
    for col = 1:4
        segmentation = cell2mat(newdata(row,col));
        if ~isempty(segmentation)
            segmentation = reshape(segmentation.',1,[]);
            area = area + double(MaskApi.area(MaskApi.frPoly({segmentation},720,1280)));
            seg{end+1} = segmentation;
            seg_rles=[seg_rles;MaskApi.frPoly({segmentation},720,1280)];
        end
    
    end
    seg_rle = MaskApi.merge(seg_rles,false);
    bbox = MaskApi.toBbox( seg_rle );
    if size(seg,2)>1
        annotation(row).segmentation = padcat(seg{1:end});
    elseif size(seg,2)==1
        annotation(row).segmentation = {seg{1}};
    else
        continue
    end
    %y = MaskApi.merge(x, false );
    annotation(row).area = area;
    annotation(row).bbox = bbox;
    annotation(row).image_id = cell2mat(newdata(row,end));
    %annotation(row).ignore = 0;
    annotation(row).iscrowd = 0;
    annotation(row).id = row;
    
    
    id = num2str(annotation(row).image_id);
    annotation(row).category_id = str2double(id(1));
    
    
    
end

%remove empty segmentation
annotation = annotation(~cellfun(@isempty,{annotation.segmentation}));


%categories
categories = struct('supercategory', {"none"},'id',{1,2,3,4},'name',{'CARDS','CHESS','JENGA','PUZZLE'});
%save 'cat_instance.mat' categories;


json_file = struct('images',{image},'type',{'instances'},'annotations',{annotation},'categories',{categories});


%clear flatteneddata i id j k row dir_filename;
output_filename = sprintf('ego_annotation_%s_mask.json',lower(split));

savejson('',json_file,output_filename);
%savejson('',json_file,'ego_annotation_valid.json');
%savejson('',json_file,'ego_annotation_test.json');
%savejson('',json_file,'test.json');
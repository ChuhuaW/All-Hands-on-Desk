% directory of image
%d = '_LABELLED_SAMPLES_BY_ID';
dire = {'Train_mask','Valid_mask','Test_mask'};
d = dire{3};
% get all *.jpg file in the directory
listing = dir(fullfile(d, '*.jpg'));

activities = {'CARDS','CHESS','JENGA','PUZZLE'};
locations = {'COURTYARD','LIVINGROOM','OFFICE'};
viewers = {'B','H','S','T'};
partners = {'B','H','S','T'};

% loop all file in the folder
for i=1:length(listing)
    % full file name
    filename_ext = listing(i).name;
    % remove extention
    filename = filename_ext(1:end-4);
    % spilt the name
    firstpart = filename(1:4);
    frame = filename(5:end);
    frame_num = str2double(frame);
    % find the corresponding id of a file
    location = char(locations(str2double(firstpart(2))));
    activity = char(activities(str2double(firstpart(1))));
    viewer = char(viewers(str2double(firstpart(3))));
    partner = char(partners(str2double(firstpart(4))));
    videos = getMetaBy('Location', location, 'Activity', activity, 'Viewer', viewer, 'Partner', partner);
    % find file path
    frame_path = ['_LABELLED_SAMPLES/' videos.video_id sprintf('/frame_%s.jpg', frame)];
    % find index of an image
    k=find([videos(1).labelled_frames(:).frame_num] == frame_num);
    img = imread(frame_path);
    %imshow(img);
    
    % get mean gray background
    %gray_img = rgb2gray(img);
    
    %mean gray calculated by each image
    %mean_gray = mean(mean(gray_img));
    
    %mean gray calculated from COCO:[102.9801, 115.9465, 122.7717]
    mean_gray = 0.2989 * 102.9801  + 0.5870 * 115.9465 + 0.1140 * 122.7717;

    gray_mask = uint8(ones(720, 1280, 3)).*mean_gray;
    %imshow(gray_mask)
    
    % hand mask
    hand_mask = getSegmentationMask(videos, k, 'all');
    
    % caculate the masked image
    mask_image = bsxfun(@times, img, cast(hand_mask,class(img)));
    % caculate the masked gray background using inverse mask
    gray_mask = bsxfun(@times, gray_mask, cast(1-hand_mask,class(gray_mask)));
    % adding up the masked image and masked gray backgound
    mask_image = bsxfun(@plus, gray_mask, cast(mask_image,class(gray_mask)));
    %imshow(mask_image);
    output = strcat(d,'_gray_new/');
    imwrite(mask_image,[output filename_ext]);
    %imshow(mask_image)
    %imshow(mask_image);
end

%videos = getMetaBy('Location', 'COURTYARD', 'Activity', 'PUZZLE');
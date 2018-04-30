# CS B657 Computer Vision Project
## Hand Segmentation and Activity Localization in EgoHands Dataset
Chuhua Wang

# AIs please note: My project is based on 'Detectron' library, and this repo is forked from original [Detectron](https://github.com/facebookresearch/Detectron) repo 

In order to reproduce my results, you will need to install Caffe2 and Detectron. The instruction can be found in Detectron repo. You can also consult my docs ([Caffe2](https://docs.google.com/document/d/18dUvJUz7bGeaD5fKzSbhCj37QFNoklR8-hgX3Z5_xVA/edit?usp=sharing), [Detectron](https://docs.google.com/document/d/1XGjWH1H3u340TG-uQy4dKNRCtGACTIzcCfct9XRzbOo/edit?usp=sharing)). Although they may be outdated since Caffe2 is now part of Pytorch. You can always contact me at cw234@iu.edu for any questions regarding installing and configuration.



The dataset and model files are uploaded to my IU Box, and you can download them from here.
When download is complete, please move all file under the directory to '/lib/datasets/data/egohands_data'

## I'm listing all the codes I have contributed to the repo:

1. All matlab codes under 'Matlab_data_processing/'. In order to use them, you will need to download [EgoHands data](http://vision.soic.indiana.edu/projects/egohands/) and EgoHands API
2. 'lib/utils/vis.py', line 92-103, 263, 314-316
3. 'lib/datasets/dataset_catalog.py', line 188-355
4. 'lib/datasets/json_dataset_evaluator.py', line 23-26, 59-62, 120-124, 145-148, 201-205, 217-218, 223-277, 283-312, 315
5. 'Plots' folder containes precision-recall curves for models 

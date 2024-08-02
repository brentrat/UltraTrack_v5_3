# UltraTrack_v5_4 is now available
Several bugs were fixed and image display was sped up. Automatic imaging cropping was improved and images can now be flipped about the middle vertical axis via a checkbox. Redundant settings such as sigma and step size were removed and replaced by block size, which can now be changed within the GUI. 
---
Tracking large displacements over long durations will still be problematic due to drift, which is inherent to optical-flow-based tracking, and we are currently in the process of creating a new and improved fascicle tracking version that uses sensor fusion with object and line-based-detection to minimise drift. 

Unfortunately, I did not extensively test all features in this latest version, so there might still be bugs when: 1) plotting fascicle lengths after correcting keyframes (I try to avoid correcting keyframes by cropping long videos into shorter ones to reduce drift), and; 2) loading in and trying to save additional data (e.g. C3D data). Therefore, please get in contact with me at brent.raiteri@rub.de if you find any bugs or have any questions.

---
The text below describes how this updated version and its predecessor (UltraTrack_v5_3) differ from the version of UltraTrack available at: https://sites.google.com/site/ultratracksoftware/home?authuser=0 
---
# UltraTrack_v5_3 and later
The graphical user interface (GUI) implements an updated version of UltraTrack (Farris and Lichtwark, 2016), which estimates the lengths and angles (relative to the horizontal) of representative fascicles from a muscle or muscles of interest from each ultrasound image of an ultrasound video (I recommend tracking .mp4 videos). 

Briefly, the tracking software was updated to track detected feature points within automatically-defined regions of interest across sequential images using a Kanade-Lucas-Tomasi (KLT) feature-point tracking algorithm (Lucas and Kanade, 1981; Shi and Tomasi, 1994). 
The KLT algorithm was implemented instead of the Lucas-Kanade algorithm (Lucas and Kanade, 1981) because it results in lower root-mean-squared errors between automatically-determined and manually-defined fascicle lengths compared with the earlier version of UltraTrack as mentioned in Drazan et al. (2019).

Absolute lengths and angles of representative fascicles from the must of interest can first be calculated automatically from one ultrasound image using open-source MATLAB code (https://github.com/JasperVerheul/hybrid-muscle-tracking). 
The aponeuroses can be initially identified by the user and the image is then cropped to 1 mm around each aponeurosis. Similar to previous work (van der Zee and Kuo, 2022), vessel-like structures within the cropped images are then determined using a Hessian-based Frangi vesselness filter (Frangi et al., 1998) that has been implemented in MATLAB (https://www.mathworks.com/matlabcentral/fileexchange/24409-hessian-based-frangi-vesselness-filter). 
A Frangi scale range of 1-2 mm is then used and the cropped and filtered images are binarized using adaptive thresholding. 
The centroid and orientation of the vessel structures with the largest perimeter in each image are then used to define a line representing each aponeurosis. 
Using the aponeurosis lines, a region of interest is then defined over the entire width of the image as the area 1 mm below the upper (i.e. superficial or central) aponeurosis and 1 mm above the lower (i.e. central or deep) aponeurosis. 
To estimate the dominant fascicle orientation within the automatically-defined regions of interest from the same ultrasound image, open-source code was modified to implement a Jerman enhancement filter (https://www.mathworks.com/matlabcentral/fileexchange/63171-jerman-enhancement-filter) to improve the filter response for vessels of varying contrasts and sizes (Jerman et al., 2016a, 2016b). 
The region of interest is then stretched vertically by a factor of three using bicubic interpolation and the Hough transform (Hough, 1962) is then applied. 
Hough lines with orientations of 45° and less than 0-25° are discarded. Note that this 0-25° range is provided as the exact value will be image dependent, and the lower limit should be changed when the dominant fascicle line obviously disagrees with what is visually expected. 
Linear extrapolation is then performed to find the fascicle endpoints, which reflect the intersections between the aponeurosis lines and the dominant fascicle line, which is centred within the region of interest. 

Fascicle length and angle changes are estimated by tracking the automatically-defined fascicle endpoints and region of interest locations forward one image at a time using the KLT algorithm (Lucas and Kanade, 1981; Shi and Tomasi, 1994). 
A point-tracker object is implemented with a block size of 21 (width) × 71 (height) pixels, four pyramid levels, and it performs up to 50 iterations. 
Feature points are renewed for each image and are detected as corners from within a moving region of interest using a minimum eigenvalue criterion (Shi and Tomasi, 1994). 
Matched feature-point pairs between successive images are then used to estimate a two-dimensional affine geometric transformation, which requirs a desired confidence of 99% to find the maximum number of matched feature-point pairs, and allows a maximum distance of 50 pixels from one point to the projected location of its corresponding point. 

Absolute lengths and angles of the tracked fascicles are provided within the output. Multiple fascicles and regions can be defined, tracked, and output.

**References**

Drazan, J.F., Hullfish, T.J., Baxter, J.R., 2019. An automatic fascicle tracking algorithm quantifying gastrocnemius architecture during maximal effort contractions. PeerJ 7, e7120. https://doi.org/10.7717/peerj.7120
Farris, D.J., Lichtwark, G.A., 2016. UltraTrack: Software for semi-automated tracking of muscle fascicles in sequences of B-mode ultrasound images. Comput Methods Programs Biomed 128, 111–118. https://doi.org/10.1016/j.cmpb.2016.02.016
Frangi, A.F., Niessen, W.J., Vincken, K.L., Viergever, M.A., 1998. Multiscale vessel enhancement filtering, in: Wells, W.M., Colchester, A., Delp, S. (Eds.), Medical Image Computing and Computer-Assisted Intervention. Springer, Berlin, Heidelberg, pp. 130–137. https://doi.org/10.1007/BFb0056195
Hough, P.V.C., 1962. Method and means for recognizing complex patterns. US3069654A.
Jerman, T., Pernus, F., Likar, B., Spiclin, Z., 2016a. Enhancement of vascular structures in 3D and 2D angiographic images. IEEE Trans Med Imaging 35, 2107–2118. https://doi.org/10.1109/TMI.2016.2550102
Jerman, T., Pernus, F., Likar, B., Spiclin, Z., 2016b. Blob enhancement and visualization for improved intracranial aneurysm detection. IEEE Trans Visual Comput Graphics 22, 1705–1717. https://doi.org/10.1109/TVCG.2015.2446493
Lucas, B., Kanade, T., 1981. An iterative image registration technique with an application to stereo vision, in: Proceedings of the 7th International Joint Conference on Artificial Intelligence. Morgan Kaufmann Publishers Inc., Vancouver, BC, Canada, pp. 674–679.
Shi, J., Tomasi, C., 1994. Good features to track, in: Proceedings of IEEE Conference on Computer Vision and Pattern Recognition. IEEE, Seattle, WA, USA, pp. 593–600. https://doi.org/10.1109/CVPR.1994.323794
van der Zee, T.J., Kuo, A.D., 2022. TimTrack: A drift-free algorithm for estimating geometric muscle features from ultrasound images. PLoS One 17, e0265752. https://doi.org/10.1371/journal.pone.0265752

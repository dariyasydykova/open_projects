# Animations with receiver operating characteristic curve (ROC curve)
This folder contains scripts `animate_ROC.r` and `animate_cutoff.r`. This folder also contains animations that these scripts generate. The animations are produced in GIF format.  

You will need the following packages to run both scripts:

- `ggplot2`
- `dplyr`
- `tidyr`
- `cowplot`
- `gganimate`
- `magick`
- `mgcv`

You can install `gganimate` using Thomas Lin Pederson's repository <https://github.com/thomasp85/gganimate>. `gganimate` also needs `tweenr` and `transformr` packages to run. These do not get installed as dependencies when you install `gganimate`. You can install `tweenr` using this repository <https://github.com/thomasp85/tweenr>, and you can install `transformr` using this repository <https://github.com/thomasp85/transformr>.

The script `animate_ROC.r` will generate `ROC.gif`:
![](ROC.gif)


The script `animate_cutoff.r` will generate `cutoff.gif`:
![](cutoff.gif)
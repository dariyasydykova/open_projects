Animations with receiver operating characteristic and precision-recal curves.
=============================================================================

Usage
-----

Please feel free to use the animations and scripts in this repository
for teaching or learning. If you want to recreate the animations in this
repository, you will need the following packages to run the various
scripts:

-   `ggplot2`
-   `dplyr`
-   `tidyr`
-   `cowplot`
-   `gganimate`
-   `magick`
-   `mgcv`

Receiver operating characteristic (ROC) curve
---------------------------------------------

Receiver operating characteristic curve displays how well a model can
classify binary outcomes. For example, a model is made to distinguish
between benign and malignant tumors. An ROC curve demonstrates how well
the model can tell whether a benign tumor is benign and whether the
malignant tumor is malignant. To make an ROC curve a false positive rate
is plotted against a true positive rate.

![](animations/cutoff.gif)

The plot on the left is the distribution of predictors for two outcomes.
The vertical line that travels left-to-right is the cutoff that
separates the positive and negative outcomes. In my tumor example, a
cutoff is a predictor value that seperates benign from malignant tumors.
A predictor value above the cutoff would classify a tumor as malignant,
and a predictor value below the cutoff would classify a tumor as benign
(assuming that positive outcome is malignant). Changing the cutoff value
does not change the shape of the ROC curve.

“AUC” in the title of the right plot stands for area under the curve.
AUC tells us the area under the ROC curve, and, generally, an AUC values
that is larger is preffered over an AUC value that is lower.

The shape of the ROC curve changes only if the model separates two
outcomes differently, or if the distribution of predictors change like
in the animation below.

![](animations/ROC.gif)

The model that makes an ROC curve that is closer to the left top corner
would be considered

Precision-recall curve
----------------------

Precision-recall curve also displays how well a model can classify
binary outcomes. However, it does it differently than an ROC curve.
Precision-recall curve plots true positive rate (recall or sensitivity)
against the positive predictive value (precision). Positive predictive
value is defined as the number of true positives divided by the number
of total positive calls, and it is meant to measure the positive
outcomes that were called correctly among all positive results. Unlike
the ROC curve that

1. The class that serves as a controller object for the snapping_sheet library is the
SnappingSheetController class. using this controller we can get the state of the snapping sheet and
mutate it at any given time. for example, this allows us to control the current snapping position
and to create the blurry background whenever we drag the snapping sheet handle

2. the parameters that controls the animation of the snapping sheet widget is "snappingCurve" and
"snappingDuration", inside the "snappingPosition" parameter. "snappingCurve" is in charge of the
type of animation, while "snappingDuration" controls how much time it takes for the animation to
complete

3. InkWell implements a "ripple effect" on tap, which creates a nice animation of click next to the
tapping position. GestureDetector on the other hands allows detecting more complex interactions,
such as drag, swipe etc..


# LiFi Notes


Attempting to replicate some of the results in this [paper][light_anchor_paper].


## Modifications:
- Try to get camera run at 120 fps -> might have to resort to 60fps to work with
the AR sceneview. 
- Still can only detect data at .5x the rate of measurement. t.f. we can
transmit at 60bps/30bps depending on how fast we can get the camera to go. 
- Instead of a single LED, use a larger led square, that way color can be
detected from further away and is more robust. 
- Instead of using amplitude modulation, use color modulation.
  - vary color using RGB -> (1, 0, 0) -> (0, 1, 0) or something similar 
  - also makes light source easier to search for by searching for a color in a
  known colors of a known color specturum. 
- Look at sample code to figure out how to add in the phase shift -> should
prevent problems involved with frame writes lining up. 
- Transmit 8bit id number over transmission. query status/rest of information
from a db call. Using the Light Anchor frame schema, should only need to
transfer a single frame in order to transmit id. 
- Instead of using a single led -> use an 8x8 LED matrix. Can look into using
shapes in the 8x8 matrix to make the signal more distinctive. 


## Preliminary algorithm
- downsample image (need this to run fast)
- filter based on color spaces
- filter bsed on shape
- find largest "blobs" -> record center of mass
- find and match nearest historical blob using euclidean distance in pixel space. 
- add to history for blob
- break history apart into states using N frames to State 
  - (i.e. if expected signal rate is 30 hz and expected capture rate is 60 hz
    then every 2 frames form a single state estimate)
  - If we can get a higher ratio, we can use a max over the last N frames to
  determine state if we lost/missed something. For example if we had 3 camera
  frames for every tx frame, one camera frame might not find the tx frame but
  the other two will. can choose to attribute that time step to either the
  argmax of the state (2 green vs 1 orange) or simply the presence (state was
  green if you detected any green).
**Not sure about these parts**
- moving window to determine if the last N frames created a preamble? 
- can also take the assumption that if a preamble was detected -> the next N
frames will be guaranteed to contain state info? 
- need to be conscious of the case where the preamble shoes up in the data
message







[light_anchor_paper]: https://karan-ahuja.com/assets/docs/paper/lightanchors.pdf

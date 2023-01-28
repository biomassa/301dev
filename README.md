# joe biomassa's ER-301 stuff

- **harmonic** is a scannable harmonic oscillator “inspired by” a certain Eurorack module, done in middle layer (“bespoke unit”). 
  Please see [this post](https://forum.orthogonaldevices.com/t/scannable-harmonic-oscillator-in-middle-layer-this-time/6094) for description / discussion.
- **msproc** is a utility that lets you control stereo width by converting the stereo signal to M/S, 
  adjusting M and S levels and going back to stereo. 
  I need it specifically for my Ciat Lonbarde Plumbutter — it tends to pan things hard left / right which is not always appropriate. 
- **wf259** is a Buchla 259's wavefolder algorithm modeled in Faust by [yorgoszachos](https://github.com/yorgoszachos). While it sounds great, it's consuming 24% CPU on the ER-301 and that would probably make it unusable for most.

Please refer to [this thread](https://forum.orthogonaldevices.com/t/using-faust-for-er-301-dsp-development/5890) for the tools and instructions on how to compile Faust code for  the ER-301.  
Thanks ljw!



TODO:

- *make an effect that would allow separate processing for M and S*?

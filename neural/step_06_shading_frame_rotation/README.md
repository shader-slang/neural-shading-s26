# Step 06: Shading Frame Rotation

This step keeps the step 05 sampling, Rusinkiewicz halfway/difference-vector
parameterization, decoder activations, and color augmentation, but adds learned
shading-frame rotation.

A small linear layer predicts two local shading frames from the latent texture.
The half and difference vectors are rotated into both frames before they are
passed to the decoder. This gives the decoder a compact way to account for local
normal variation while keeping rendering and validation unchanged.

Run:

```powershell
python neural/step_06_shading_frame_rotation/run.py
```

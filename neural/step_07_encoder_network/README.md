# Step 07: Encoder Network

This final step keeps the sampling, Rusinkiewicz halfway/difference-vector
parameterization, decoder activations, color augmentation, and learned
shading-frame rotation from the previous examples, but replaces directly
trained latent textures with an encoder network.

The encoder reads a compact set of material properties at each `uv` location and
predicts the latent vector used by the rotation and decoder networks. The latent
images shown on screen are therefore generated previews of the encoder output,
not trainable texture memory.

Run:

```powershell
python neural/step_07_encoder_network/run.py
```

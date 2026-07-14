# Step 01: Latent Texture

This is the minimal neural material training example for the course material.

It trains a latent texture and a small decoder to match the ceramic MDL target
material. The decoder receives the sampled latent vector plus raw incoming and
outgoing directions. This first example intentionally uses uniform UV and
direction sampling, no color augmentation, and no direction parameterization.

Run:

```powershell
python neural/step_01_latent_texture/run.py
```

Useful options:

```powershell
python neural/step_01_latent_texture/run.py --checkpoint path/to/checkpoint
python neural/step_01_latent_texture/run.py --no-train
```


# Step 08: Multi-Instance Training

This step keeps the encoder, learned shading-frame rotation, Rusinkiewicz
parameterization, decoder activations, and color augmentation from step 07, but
trains a population of networks instead of one network.

The sample starts with 64 random networks trained on 8x8 batches. At each
quarter of the run it measures log L1 error for every active network, keeps the
best subset, and increases the batch size:

```text
64 networks -> 8x8 batches
16 networks -> 16x16 batches
 4 networks -> 32x32 batches
 1 network  -> 64x64 batches
```

Unlike the original neural appearance trainer, this example does not pack all
instances into one optimized dispatch. Python simply loops over the active
network list and launches the normal training pass for each one. It is slower,
but the orchestration is visible and small enough for course material.

Checkpoints save every active network in `networks.npz`, while the preview
images are rendered only from the current best network.

Run:

```powershell
python neural/step_08_multi_instance_training/run.py
```

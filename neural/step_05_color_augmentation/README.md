# Step 05: Color Augmentation

This step keeps the step 04 sampling, Rusinkiewicz halfway/difference-vector
parameterization, and decoder activations, but adds color augmentation during
training.

The target RGB channels are randomly permuted or duplicated for early training
samples, then annealed back to the identity mapping. Rendering and validation use
the real target material without augmentation.

Run:

```powershell
python neural/step_05_color_augmentation/run.py
```

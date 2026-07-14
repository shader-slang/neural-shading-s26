# Step 02: Rusinkiewicz Sampling

This step keeps the same latent texture and decoder from step 01, but changes
the training and validation samples from independent uniform hemisphere
directions to uniform Rusinkiewicz half/difference angle samples.

The network inputs are still raw incoming and outgoing directions. This step is
only about where the training samples come from.

Run:

```powershell
python neural/step_02_rusinkiewicz_sampling/run.py
```

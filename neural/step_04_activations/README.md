# Step 04: Activations

This step keeps the step 03 sampling and Rusinkiewicz halfway/difference-vector
parameterization, but changes the decoder activations.

The hidden layers keep the leaky ReLU from the earlier examples. The RGB output
uses a scaled sigmoid instead of `exp`, so this step isolates the output
activation change.

Run:

```powershell
python neural/step_04_activations/run.py
```

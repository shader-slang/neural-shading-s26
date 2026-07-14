# Step 03: Rusinkiewicz Parameterization

This step builds on step 02. Training and validation still use uniform
Rusinkiewicz half/difference angle samples, but the decoder now receives the
Rusinkiewicz halfway/difference-vector parameterization instead of raw incoming
and outgoing directions.

For each pair of directions, the shader computes the halfway vector `wh`, then
rotates `wi` into the halfway-vector frame to produce the difference vector
`wd`. The decoder receives `wh` and `wd` as its six direction inputs.

Run:

```powershell
python neural/step_03_rusinkiewicz_parameterization/run.py
```

# Static validation report

- Source JSON parses and contains 80 nodes / 110 links.
- Packaged original SHA-256 matches source: `35eb269ce61793891daafeb9a84bc2235b7c1475789900bc133cbf140a65aa57`.
- Adapted workflow parses and retains all nodes/links; only node 2889 LoRA row values differ, to add Realism Engine disabled at strength 0.8.
- LCOptimizer node 2888 matches the source model selections exactly: Krea 2 (Turbo) base mode, Krealism V3.1 INT8 ConvRot checkpoint, Heretic v10 text encoder, HDR VAE.
- ZIP creation and extraction check passed (10 files).
- No Docker build, GitHub publication, RunPod startup, workflow load, or image generation was run.


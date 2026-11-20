# Static validation report

- Preserved original workflow: 80 nodes / 110 links; packaged source SHA-256 remains `35eb269ce61793891daafeb9a84bc2235b7c1475789900bc133cbf140a65aa57`.
- Adapted workflow parses with 80 nodes / 110 links and retains the same node IDs and link list.
- Adapted fields: node 2889 adds optional Realism Engine at 0.8, disabled; node 171 uses the Linux identity-LoRA path; nodes 2892 and 2893 use the exact LC MaskMaker download selectors for BiRefNet General and ViTMatte Base.
- Bootstrap now installs BiRefNet General as `models/background_removal/BiRefNet-general.safetensors` (the exact filename recognized by the pinned LC MaskMaker code) and ViTMatte Base in `models/vitmatte/vitmatte-base-composition-1k/` with its weights and config files.
- Required custom-node repositories include Krea2Edit, LC123, LC MaskMaker (pinned at the workflow-recorded revision), and rgthree. The shell bootstrap is LF-normalized; Dockerfile heredoc closes at `PYCODE`.
- Static validation only. The latest modified source has not been built, published to GHCR, started on a fresh Pod, or tested through workflow execution/output.
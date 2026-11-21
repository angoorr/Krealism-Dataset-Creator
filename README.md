# Krealism + Realism Engine Dataset Template (RunPod)

This package preserves Lonecat's 80-node graph, adds Realism Engine as an optional disabled LoRA row, and fixes Linux model paths and LC Remove Background selectors for a fresh ComfyUI install.

## Models in the workflow

- Base family: Krea 2 Turbo.
- Actual diffusion file: `Krealism_V3.1_int8_convrot.safetensors` (about 14.1 GB). Its creator describes Krealism as a photorealism/film-look fine-tune of Krea 2 Turbo and says it needs no extra style LoRA.
- Text encoder: the workflow's Qwen3-VL 4B Heretic v10 file.
- VAE: the workflow's `hdrVAE_fp32.safetensors`. The bootstrap fetches the Krea2/Anima HDR VAE weights and saves them under the filename already selected in the workflow.
- Required `krea2_identity_edit_v2` stays loaded for identity-preserving editing. The workflow now uses its Linux path (`Krea 2/Utilities/...`).
- Both LC Remove Background nodes select `⬇ Download: BiRefNet general (MIT)` and `⬇ Download: vitmatte-base-composition-1k (Apache-2.0)`, matching the node's downloadable model entries. The bootstrap also places BiRefNet General and ViTMatte Base under their expected model folders.
- Realism Engine v3.1 is installed in the LC LoRA Loader at 0.8 strength, initially disabled. Toggle its row on/off in ComfyUI to compare.

Realism Engine is a LoKr adapter, not a conventional low-rank LoRA. The LC LoRA Loader routes it through ComfyUI's generic LoRA application path; whether this specific stack improves this dataset still needs an actual generation comparison. Because Krealism already has a realism look, compare with the extra row off first, then on.

The Heretic text encoder does not guarantee that the whole Krea 2 system will generate every sensitive prompt. A VAE decodes latents; it does not enable/disable content policy. Follow applicable model terms and law. Use fictional adults or consenting adults only; never create sexual imagery involving minors or non-consenting real people.

## Build and deploy

1. Add `CIVITAI_TOKEN` as a RunPod Secret. The setup also downloads public Hugging Face files; no Hugging Face token is required for this configuration.
2. Upload the contents of this folder to a GitHub repository and push to `main`. GitHub Actions publishes `ghcr.io/<owner>/<repo>:latest` and a commit-SHA tag.
3. Allow at least 80 GB of container disk for the 14.1 GB Krealism model, other models, base runtime, downloads, and headroom. No Network Volume is required.
4. A 24 GB GPU is a plausible first test for the INT8 model, but model weights, Qwen encoder, two reference images, and this workflow's resolution can raise peak use. 48 GB gives more comfortable headroom. These are estimates, not measured results.
5. Open ComfyUI, import `Lonecat_Krealism_Realism_Dataset_V10.json`, and select your own files for its two image inputs. The sample images from the author's machine are not included.
6. Run one prompt with Realism Engine off, then toggle its row on and compare using the same seed and inputs.
7. Download outputs locally before terminating the Pod.

The LC123 custom node and rgthree are installed from their upstream branches; Krea2Edit and MaskMaker are pinned to revisions saved in the source workflow. Static package validation only: Docker build, GHCR push, Pod startup, workflow loading, and generation have not been run. The setup validates model sizes and SafeTensors headers both after download and before reusing cached files. For the detailed audit and known blocker from the earlier published image, see `validation-report.md`.

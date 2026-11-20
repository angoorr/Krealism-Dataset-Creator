#!/usr/bin/env bash
set -Eeuo pipefail
umask 077
LOG=/workspace/krea2_setup.log
mkdir -p /workspace
exec > >(tee -a "$LOG") 2>&1
TEMP_CFG=""
cleanup(){ [[ -z "$TEMP_CFG" ]] || rm -f "$TEMP_CFG"; }
trap cleanup EXIT
trap 'rc=$?; echo "Setup failed at line ${LINENO} (exit ${rc}); see ${LOG}"; exit "$rc"' ERR
COMFY="${COMFY_DIR:-/workspace/runpod-slim/ComfyUI}"
PY="$COMFY/.venv-cu128/bin/python"
N="$COMFY/custom_nodes"; M="$COMFY/models"
[[ -n "${CIVITAI_TOKEN:-}" ]] || { echo 'CIVITAI_TOKEN RunPod Secret required'; exit 2; }

[[ -d "$N" && -x "$PY" ]] || { echo "ComfyUI not ready at $COMFY"; exit 2; }
install_node(){ local repo="$1" dir="$2" ref="${3:-}"; if [[ -d "$dir/.git" ]]; then git -C "$dir" fetch --depth 1 origin; git -C "$dir" reset --hard FETCH_HEAD; elif [[ ! -e "$dir" ]]; then git clone --depth 1 "$repo" "$dir"; else echo "Node path exists but is not a Git clone: $dir"; exit 3; fi; if [[ -n "$ref" ]]; then git -C "$dir" fetch --depth 1 origin "$ref"; git -C "$dir" checkout --detach FETCH_HEAD; fi; [[ -f "$dir/__init__.py" ]] || { echo "Invalid node repo $dir"; exit 3; }; if [[ -f "$dir/requirements.txt" ]]; then "$PY" -m pip install --disable-pip-version-check -r "$dir/requirements.txt"; fi; if [[ -f "$dir/install.py" ]]; then "$PY" "$dir/install.py"; fi; }
install_node https://github.com/lbouaraba/comfyui-krea2edit "$N/comfyui-krea2edit" 7e68e90983b25e64dd02ac5d0c10593ea72a4cde
install_node https://github.com/lonecatone23/ComfyUI_LC123_nodes "$N/ComfyUI_LC123_nodes"
install_node https://github.com/lonecatone23/ComfyUI_LC_MaskMaker_nodes "$N/ComfyUI_LC_MaskMaker_nodes" 7641e153d15b5da332888db1d460fbf5466a7626
install_node https://github.com/rgthree/rgthree-comfy "$N/rgthree-comfy"
if ! "$PY" -c 'import cv2' >/dev/null 2>&1; then "$PY" -m pip install --disable-pip-version-check opencv-python-headless; fi
"$PY" - <<'PY'
import cv2
print("Verified OpenCV for MaskMaker:", cv2.__version__)
PY
make_curl_config(){ local url="$1" target="$2" kind="$3"; TEMP_CFG="$(mktemp /workspace/.model-curl.XXXXXX)"; chmod 600 "$TEMP_CFG"; "$PY" - "$url" "$target" "$kind" > "$TEMP_CFG" <<'PY'
import json,os,sys
url,target,kind=sys.argv[1:]
print('url = '+json.dumps(url)); print('output = '+json.dumps(target)); print('fail'); print('location'); print('retry = 5'); print('retry-delay = 4'); print('connect-timeout = 30')
if kind=='civitai': print('get'); print('data-urlencode = '+json.dumps('token='+os.environ['CIVITAI_TOKEN']))

PY
}
download(){ local url="$1" dest="$2" minimum="$3" auth="$4" tmp="${2}.part"; mkdir -p "$(dirname "$dest")"; if [[ -s "$dest" ]]; then echo "Already present: $(basename "$dest")"; return; fi; rm -f "$tmp"; echo "Downloading $(basename "$dest")"; make_curl_config "$url" "$tmp" "$auth"; curl --config "$TEMP_CFG"; rm -f "$TEMP_CFG"; TEMP_CFG=""; [[ -s "$tmp" ]] || { echo "Empty download: $dest"; exit 4; }; local bytes; bytes=$(stat -c %s "$tmp"); (( bytes >= minimum )) || { echo "File too small ($bytes): $dest"; exit 4; }; if [[ "$dest" == *.safetensors ]]; then "$PY" - "$tmp" <<'PY'
import json,struct,sys
with open(sys.argv[1],'rb') as f:
 n=struct.unpack('<Q',f.read(8))[0]
 if n<2 or n>100000000: raise SystemExit('invalid safetensors header size')
 h=json.loads(f.read(n))
 if not isinstance(h,dict) or not h: raise SystemExit('invalid safetensors header')
PY
fi; mv "$tmp" "$dest"; echo "Verified $(basename "$dest") ($bytes bytes)"; }
download 'https://huggingface.co/Lonecatone23/Krealism/resolve/main/Krealism_V3.1_int8_convrot.safetensors' "$M/diffusion_models/Krea 2/Your models/Krealism V3.1/Krealism_V3.1_int8_convrot.safetensors" 10000000000 public
download 'https://civitai.red/api/download/models/3066989?fileId=2945735' "$M/text_encoders/Qwen 3/qwen3VL-4B - Instruct-Heretic_v10.safetensors" 1000000000 civitai
download 'https://huggingface.co/p3cyc/KREA2/resolve/main/hdrVAEAnimaKrea2QWEN_fp32.safetensors' "$M/vae/hdrVAE_fp32.safetensors" 100000000 public
download 'https://huggingface.co/conradlocke/krea2-identity-edit/resolve/main/krea2_identity_edit_v2_r128.safetensors?download=true' "$M/loras/Krea 2/Utilities/krea2_identity_edit_v2.safetensors" 1000000 public
download 'https://civitai.red/api/download/models/3109006?fileId=2988982' "$M/loras/realism_engine_krea2_v3.1.safetensors" 1000000000 civitai
download 'https://huggingface.co/ZhengPeng7/BiRefNet/resolve/main/model.safetensors' "$M/background_removal/BiRefNet-general.safetensors" 200000000 public
download 'https://huggingface.co/hustvl/vitmatte-base-composition-1k/resolve/main/model.safetensors' "$M/vitmatte/vitmatte-base-composition-1k/model.safetensors" 350000000 public
download 'https://huggingface.co/hustvl/vitmatte-base-composition-1k/resolve/main/config.json' "$M/vitmatte/vitmatte-base-composition-1k/config.json" 100 public
download 'https://huggingface.co/hustvl/vitmatte-base-composition-1k/resolve/main/preprocessor_config.json' "$M/vitmatte/vitmatte-base-composition-1k/preprocessor_config.json" 100 public
echo 'Original workflow models, required identity adapter, optional Realism Engine, and workflow matting assets are installed.'




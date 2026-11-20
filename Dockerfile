FROM runpod/comfyui:2.2.1-rc.236-comfyuiv0.44.0-cuda12.8
COPY setup_krea2_krealism.sh /opt/krea2/setup_krea2_krealism.sh
RUN sed -i 's/\r$//' /opt/krea2/setup_krea2_krealism.sh && chmod 0755 /opt/krea2/setup_krea2_krealism.sh
RUN python3 - <<'PYCODE'
from pathlib import Path
import re
p=Path('/start.sh'); s=p.read_text()
pattern=re.compile(r'(?m)^[ \t]*(?:exec[ \t]+)?python(?:3(?:\.12)?)?[ \t]+main\.py[^\n]*$')
matches=list(pattern.finditer(s))
if len(matches)!=1: raise SystemExit(f'Expected exactly one main.py launch line in /start.sh, found {len(matches)}')
insert='''# Krea2 setup before ComfyUI\nif [[ "${KREA2_AUTO_SETUP:-1}" == "1" ]]; then\n  /bin/bash /opt/krea2/setup_krea2_krealism.sh\nfi\n\n'''
i=matches[0].start(); p.write_text(s[:i]+insert+s[i:])
PYCODE\r
\r

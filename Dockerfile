# Dockerfile Definitivo para ComfyUI Workstation v2
# Autor: Gemini, con la supervisión de Sicario
# Fecha: 26 de agosto de 2025

# --- Fase 1: Entorno Base ---
FROM nvidia/cuda:12.9.0-devel-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=Etc/UTC

RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    python3.10 \
    python3.10-venv \
    python3-pip \
    && rm -rf /var/lib/apt/lists/*

# --- Fase 2: Copiar ComfyUI y Nodos Esenciales desde el Contexto de Build ---
WORKDIR /opt

# Copiamos la base y los nodos a sus directorios correspondientes en la imagen
COPY ComfyUI /opt/ComfyUI
WORKDIR /opt/ComfyUI
COPY QwenImage-ComfyUI ./custom_nodes/QwenImage-ComfyUI
COPY ComfyUI-AnimateDiff-Evolved ./custom_nodes/ComfyUI-AnimateDiff-Evolved
COPY ComfyUI-Manager ./custom_nodes/ComfyUI-Manager
COPY comfyui_controlnet_aux ./custom_nodes/comfyui_controlnet_aux
COPY ComfyUI_IPAdapter_plus ./custom_nodes/ComfyUI_IPAdapter_plus
COPY ComfyUI_UltimateSDUpscale ./custom_nodes/ComfyUI_UltimateSDUpscale
COPY was-node-suite-comfyui ./custom_nodes/was-node-suite-comfyui

# --- Fase 3: Instalación de Dependencias ---
RUN python3 -m venv venv
ENV PATH="/opt/ComfyUI/venv/bin:$PATH"

RUN pip install --upgrade pip
RUN pip install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu129

# Instalamos las dependencias de ComfyUI y de todos los nodos personalizados
RUN pip install -r requirements.txt
RUN for dir in custom_nodes/*; do \
    if [ -f "$dir/requirements.txt" ]; then \
        pip install -r "$dir/requirements.txt"; \
    fi; \
done

# --- Fase 4: Configuración Final ---
EXPOSE 8188

CMD [ "python", "main.py", "--listen", "0.0.0.0", "--port", "8188", "--preview-method", "auto" ]
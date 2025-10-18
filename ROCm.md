

## Download uv (Secondary)
Backup to homebreww

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh~
```

## Default UV Setup
```bash
# You're already activated, so just use:
mkdir -p ~/.virtualenvs
uv venv ~/.virtualenvs/rocm --python 3.12
echo "HSA_OVERRIDE_GFX_VERSION=11.0.0" > ~/.virtualenvs/rocm/.env               # CRITICAL
source ~/.virtualenvs/rocm/bin/activate
uv pip install torch torchvision torchaudio jupyter numpy pandas matplotlib scikit-learn --index-url https://download.pytorch.org/whl/rocm6.2

# CRITICAL
export HSA_OVERRIDE_GFX_VERSION=11.0.0
```

## Two workflows with uv

**1. Project-based (uses `uv add`):**
```bash
cd my-project/
uv init                    # Creates pyproject.toml
uv add torch jupyter       # Manages dependencies in pyproject.toml
```

**2. Traditional venv (uses `uv pip`):**
```bash
uv venv ~/.virtualenvs/rocm           
source ~/.virtualenvs/rocm/bin/activate
uv pip install torch jupyter         
```

## Python ROCm test

```python

import torch

print("PyTorch version:", torch.__version__)
print("ROCm available:", torch.cuda.is_available())  # Yes, it still uses .cuda API
print("ROCm version:", torch.version.hip if torch.cuda.is_available() else "N/A")
print("Number of GPUs:", torch.cuda.device_count())

if torch.cuda.is_available():
    print("GPU name:", torch.cuda.get_device_name(0))
    
    # Create a tensor on GPU
    x = torch.randn(3, 3)
    y = torch.randn(3, 3)
    
    # Simple operation
    z = x @ y  # Matrix multiplication
    
    print("\nMatrix multiplication test:")
    print("Result shape:", z.shape)
    print("Result device:", z.device)
    print("\nTest passed! ✓")
else:
    print("\nROCm not available. Check your installation.")

```
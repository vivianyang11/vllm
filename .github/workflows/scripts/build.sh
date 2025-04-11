#!/bin/bash
set -eux

python_executable=python$1
cuda_home=/usr/local/cuda-$2

# Update paths
PATH=${cuda_home}/bin:$PATH
LD_LIBRARY_PATH=${cuda_home}/lib64:$LD_LIBRARY_PATH

# Install requirements
$python_executable -m pip install -r requirements/build.txt -r requirements/cuda.txt

# Limit the number of parallel jobs to avoid OOM
export MAX_JOBS=1
export CMAKE_BUILD_PARALLEL_LEVEL=1  # 限制 cmake 内部并发

# ✅ 限制 PyTorch 编译使用的线程
export PYTORCH_BUILD_THREADS=1

# ✅ 限制 Ninja 编译线程（如果使用了 Ninja）
export NINJA_NUM_CORES=1

# ✅ 设置 CUDA 架构（可选优化）
export TORCH_CUDA_ARCH_LIST="7.0 7.5 8.0 8.6 8.9 9.0+PTX"
export VLLM_FA_CMAKE_GPU_ARCHES="80-real;90-real"

bash tools/check_repo.sh

# ✅ 建议显示输出当前内存状态，便于调试
free -h || true
df -h || true

# ✅ 执行构建命令
$python_executable setup.py bdist_wheel --dist-dir=dist

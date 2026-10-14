# Jupyter 公式の最小イメージ(内部は conda/mamba 構成)
FROM quay.io/jupyter/minimal-notebook:latest

# conda 環境を作成する
COPY environment.yml /tmp/environment.yml
RUN mamba env create -f /tmp/environment.yml \
 && mamba clean -afy

# pip パッケージは uv で入れる。ダウンロードはキャッシュして、再ビルド時に使い回す
COPY requirements.txt /tmp/requirements.txt
RUN --mount=type=cache,target=/home/jovyan/.cache/uv,uid=1000,gid=100 \
    UV_LINK_MODE=copy /opt/conda/envs/ml/bin/uv pip install \
      --python /opt/conda/envs/ml/bin/python \
      --torch-backend=cu126 \
      -r /tmp/requirements.txt \
 && /opt/conda/envs/ml/bin/python -m ipykernel install --user \
      --name ml --display-name "Python (ml)" \
 && fix-permissions "${CONDA_DIR}" \
 && fix-permissions "/home/${NB_USER}"

# サーバー設定(ルートを ./work にする、ノートブック移動時にカーネルの cwd を追従させる)
COPY jupyter/jupyter_server_config.py /usr/local/etc/jupyter/jupyter_server_config.py
COPY jupyter/follow_notebook_kernel.py /tmp/follow_notebook_kernel.py
RUN cp /tmp/follow_notebook_kernel.py "$(python -c 'import site; print(site.getsitepackages()[0])')/"

# TensorFlow 2.21 は cusolver の場所を検索パスに含めていないため、GPU を認識しない。
# PyTorch を先に import すれば動くが、TensorFlow 単独でも動くようにパスを足す
ENV LD_LIBRARY_PATH="/opt/conda/envs/ml/lib/python3.13/site-packages/nvidia/cusolver/lib"

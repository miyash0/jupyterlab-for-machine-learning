# Jupyter 公式の CUDA 対応 TensorFlow イメージ(内部は conda/mamba 構成)
ARG BASE_TAG=cuda12-latest
FROM quay.io/jupyter/tensorflow-notebook:${BASE_TAG}

# 追加パッケージは requirements.txt に書く(conda 環境 base にインストールされる)
COPY --chown=${NB_UID}:${NB_GID} requirements.txt /tmp/requirements.txt
RUN pip install --no-cache-dir -r /tmp/requirements.txt && rm /tmp/requirements.txt
